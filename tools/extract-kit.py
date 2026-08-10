#!/usr/bin/env python3
"""
extract-kit.py — kept for provenance. DO NOT RUN.

The kit was originally embedded inside a design document, and this script performed
the one-time extraction into the real files that now live in this repository. Those
files have since been edited directly and have deliberately diverged from that
document, so re-running this would silently discard every change made since.

**This repository is the source of truth for every kit file.** Edit them here.
The script is retained only so the origin of the initial import is auditable.

The one trap worth stating: **fence width varies**. A file whose own content
contains a ``` fence is embedded in a four-backtick block rather than a three.
A naive three-backtick split truncates those files mid-content, silently. This
parser reads the opening fence, measures its width, and closes only on a fence of
at least that width at column 0.

Nothing is written until every file has been parsed successfully, so a failed run
aborts rather than half-applying.

Usage:
    python3 tools/extract-kit.py                 # write to ./2nd-brain/
    python3 tools/extract-kit.py --check         # parse and report, write nothing
    python3 tools/extract-kit.py --out DIR       # write somewhere else
    python3 tools/extract-kit.py --doc PATH      # different source document
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# Where this script lives: <repo>/tools/extract-kit.py
REPO_ROOT = Path(__file__).resolve().parent.parent

DEFAULT_DOC = REPO_ROOT.parent / "research" / "06_IMPLEMENTATION_DESIGN.md"
DEFAULT_OUT = REPO_ROOT / "2nd-brain"

APPENDIX_HEADING = re.compile(r"^## 16\. ")
NEXT_SECTION = re.compile(r"^## (?!16\.)")
FILE_HEADING = re.compile(r"^#### `([^`]+)`\s*$")
FENCE = re.compile(r"^(`{3,})(.*)$")

# Files that must never ship — they are generated during onboarding, and a fresh
# download containing them makes the setup-or-repair check conclude the executive
# is already set up (MASTER_REPORT_v2.md section VI.6.4, rule 3).
FORBIDDEN = {"CLAUDE.md", "goals.md"}

EXPECTED_FILE_COUNT = 29


class ParseError(RuntimeError):
    pass


def find_appendix(lines: list[str]) -> tuple[int, int]:
    """Return the [start, end) line range of section 16, ignoring fenced content."""
    start = None
    end = len(lines)
    i = 0

    while i < len(lines):
        line = lines[i]

        # Skip whole fenced blocks — the document quotes markdown containing
        # headings, and a `## ` inside a code block is content, not structure.
        opening = FENCE.match(line)
        if opening:
            i = skip_block(lines, i, len(lines))[1]
            continue

        if start is None:
            if APPENDIX_HEADING.match(line):
                start = i
        elif NEXT_SECTION.match(line):
            end = i
            break

        i += 1

    if start is None:
        raise ParseError("could not find the '## 16. Appendix A' heading")
    return start, end


def skip_block(lines: list[str], i: int, end: int) -> tuple[list[str], int, bool]:
    """
    Consume the fenced block opening at line `i`.

    Returns (body lines, index of the line after the closing fence, closed?).
    The closing fence must be at column 0 and at least as wide as the opening
    one — that is what stops a ``` inside a ```` block from closing it early.
    """
    opening = FENCE.match(lines[i])
    assert opening is not None
    width = len(opening.group(1))
    body: list[str] = []
    i += 1

    while i < end:
        candidate = FENCE.match(lines[i])
        if (
            candidate
            and len(candidate.group(1)) >= width
            and candidate.group(2).strip() == ""
        ):
            return body, i + 1, True
        body.append(lines[i])
        i += 1

    return body, i, False


def parse_appendix(lines: list[str]) -> list[tuple[str, str, int, int]]:
    """
    Walk section 16 and return (path, content, heading_lineno, fence_width) per file.

    Line numbers are 1-based, for error messages and the audit report.
    """
    start, end = find_appendix(lines)

    files: list[tuple[str, str, int, int]] = []
    i = start
    pending: tuple[str, int] | None = None  # (path, heading line number)

    while i < end:
        line = lines[i]

        heading = FILE_HEADING.match(line)
        if heading:
            if pending is not None:
                raise ParseError(
                    f"line {i + 1}: heading for '{heading.group(1)}' arrived before "
                    f"the code block for '{pending[0]}' (line {pending[1]})"
                )
            pending = (heading.group(1), i + 1)
            i += 1
            continue

        opening = FENCE.match(line)
        if opening:
            width = len(opening.group(1))
            fence_line = i + 1
            body, i, closed = skip_block(lines, i, end)

            if not closed:
                raise ParseError(
                    f"line {fence_line}: unterminated {width}-backtick fence "
                    f"(no closing fence of width >= {width} before the end of section 16)"
                )

            if pending is None:
                # Every fenced block in section 16 belongs to a file heading. An
                # unclaimed one means the fences have gone out of step — which is
                # what a mis-measured fence width looks like from here, and it
                # truncates a file rather than failing loudly. Refuse to guess.
                raise ParseError(
                    f"line {fence_line}: fenced block with no preceding "
                    f"'#### `path`' heading. The fences in section 16 are out of "
                    f"step — most likely a file whose content contains a ``` fence "
                    f"is wrapped in three backticks instead of four."
                )

            path, heading_lineno = pending
            content = "".join(body)
            files.append((path, content, heading_lineno, width))
            pending = None
            continue

        i += 1

    if pending is not None:
        raise ParseError(
            f"line {pending[1]}: heading for '{pending[0]}' has no code block after it"
        )

    return files


def validate(files: list[tuple[str, str, int, int]]) -> list[str]:
    """Return a list of problems. An empty list means the extraction is sound."""
    problems: list[str] = []

    seen: dict[str, int] = {}
    for path, content, lineno, _width in files:
        if path in seen:
            problems.append(
                f"duplicate file heading '{path}' at line {lineno} "
                f"(first seen at line {seen[path]})"
            )
        seen[path] = lineno

        p = Path(path)
        if p.is_absolute() or ".." in p.parts:
            problems.append(f"unsafe path '{path}' at line {lineno}")
        if p.name in FORBIDDEN:
            problems.append(
                f"'{path}' at line {lineno} is a user file and must never ship "
                "(MASTER_REPORT_v2.md section VI.6.4, rule 3)"
            )
        if not content.strip():
            problems.append(f"'{path}' at line {lineno} is empty")

        # A file whose own content contains a ``` fence must be wrapped in four
        # backticks. If a three-backtick block still holds one, the block closed
        # somewhere other than where it should have.
        if _width == 3 and any(FENCE.match(l) for l in content.splitlines()):
            problems.append(
                f"'{path}' at line {lineno} is in a 3-backtick block but its "
                "content contains a fence — it needs four backticks"
            )

        # The eleven skills are the routing layer. Their frontmatter is
        # length-constrained and must survive byte-exact.
        if path.startswith("_kit/skills/"):
            if not content.startswith("---\n"):
                problems.append(f"'{path}' does not open with '---' frontmatter")
                continue
            closing = content.find("\n---\n", 3)
            if closing == -1:
                problems.append(f"'{path}' has no closing '---' on its frontmatter")
                continue
            front = content[4:closing + 1]
            for key in ("name:", "description:"):
                if not any(l.startswith(key) for l in front.splitlines()):
                    problems.append(f"'{path}' frontmatter has no '{key}' line")

    if len(files) != EXPECTED_FILE_COUNT:
        problems.append(
            f"expected {EXPECTED_FILE_COUNT} files, parsed {len(files)}"
        )

    return problems


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--doc", type=Path, default=DEFAULT_DOC,
                    help="the retired design document to extract from")
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT,
                    help="the kit folder to write (default: <repo>/2nd-brain)")
    ap.add_argument("--check", action="store_true",
                    help="parse and report without writing anything")
    args = ap.parse_args()

    if not args.doc.is_file():
        print(f"error: no such document: {args.doc}", file=sys.stderr)
        return 2

    lines = args.doc.read_text(encoding="utf-8").splitlines(keepends=True)

    try:
        files = parse_appendix(lines)
    except ParseError as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1

    problems = validate(files)
    if problems:
        print("error: extraction rejected —", file=sys.stderr)
        for problem in problems:
            print(f"  - {problem}", file=sys.stderr)
        return 1

    width_counts: dict[int, int] = {}
    for _path, _content, _lineno, width in files:
        width_counts[width] = width_counts.get(width, 0) + 1

    print(f"parsed {len(files)} files from {args.doc}")
    for width in sorted(width_counts):
        print(f"  {width}-backtick blocks: {width_counts[width]}")

    if args.check:
        for path, content, lineno, width in files:
            print(f"  {len(content):>7} bytes  {width}`  line {lineno:>5}  {path}")
        return 0

    # Nothing is written until every file has parsed and validated.
    for path, content, _lineno, _width in files:
        target = args.out / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")

    print(f"wrote {len(files)} files to {args.out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
