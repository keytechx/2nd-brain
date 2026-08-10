#!/usr/bin/env bash
#
# build-release.sh — cut the distributable archive.
#
# Implements §VI.6.4 of MASTER_REPORT_v2.md. The archive layout is a hard
# requirement: nothing downstream can recover from an archive that is wrong, and
# the executive will not notice until much later.
#
#   2nd-brain.zip
#   └── 2nd-brain/          exactly one root folder, named exactly this
#       ├── README.md
#       ├── onboarding.md
#       ├── VERSION
#       ├── _kit/
#       └── content folders, each with its README.md
#
# The five rules from §VI.6.4, and where each is enforced below:
#
#   1. The asset is named 2nd-brain.zip.               — the zip line
#   2. The root folder is 2nd-brain, never versioned.  — dist/2nd-brain
#   3. No user files (CLAUDE.md, goals.md).            — rsync --exclude, then re-checked
#   4. Content folder READMEs are included.            — checked before packing
#   5. No .DS_Store.                                   — rsync --exclude, then re-checked
#
# Note on rule 1: GitHub's auto-generated "Source code (zip)" must never be the
# advertised download — it extracts to <repo>-<tag>/, which produces a versioned
# folder. Attach this archive to the release and link to it directly.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [ ! -f ./onboarding.md ] || [ ! -d ./_kit ]; then
  echo "error: run this from the repo root — no ./onboarding.md or ./_kit here" >&2
  exit 1
fi

# --- §VI.6.4, as written ---------------------------------------------------

# The repo root IS the kit, so the exclusions carry the whole difference between what
# is version-controlled and what an executive receives. tools/ and .gitignore are
# repo furniture; CLAUDE.md and goals.md are user files that must never ship.
rm -rf dist && mkdir -p dist/2nd-brain
rsync -a --exclude '.DS_Store' --exclude 'CLAUDE.md' --exclude 'goals.md' \
      --exclude 'dist' --exclude 'tools' --exclude '.git' --exclude '.gitignore' \
      --exclude '__pycache__' --exclude '*.pyc' \
      ./ dist/2nd-brain/

# --- verify the staged tree before it is sealed ----------------------------

fail=0

# Rule 3. The rsync excludes are unanchored, so they drop a user file at any
# depth — but this is the rule that silently breaks onboarding, so re-check it
# rather than trusting the flags.
while IFS= read -r stowaway; do
  echo "error: user file must never ship: ${stowaway#dist/}" >&2
  fail=1
done < <(find dist -type f \( -name 'CLAUDE.md' -o -name 'goals.md' \))

# Rule 5.
while IFS= read -r junk; do
  echo "error: ${junk#dist/} must not ship" >&2
  fail=1
done < <(find dist -name '.DS_Store')

# Rule 4. Git does not track empty directories, so these READMEs are what make
# the structure survive a download at all (§VI.1).
for folder in 01_Projects 02_Areas 03_Resources 04_Archive \
              decisions meetings people \
              journal journal/daily journal/weekly journal/monthly; do
  if [ ! -f "dist/2nd-brain/$folder/README.md" ]; then
    echo "error: missing content folder README: $folder/README.md" >&2
    fail=1
  fi
done

for unwanted in tools .gitignore dist; do
  if [ -e "dist/2nd-brain/$unwanted" ]; then
    echo "error: repo furniture must not ship: $unwanted" >&2
    fail=1
  fi
done

for required in README.md onboarding.md VERSION LICENSE _kit/CLAUDE.template.md \
                _kit/goals.template.md _kit/advisor.template.md \
                _kit/persona-library.md; do
  if [ ! -f "dist/2nd-brain/$required" ]; then
    echo "error: missing kit file: $required" >&2
    fail=1
  fi
done

skill_count=$(find dist/2nd-brain/_kit/skills -name '*.md' -type f | wc -l | tr -d ' ')
if [ "$skill_count" -ne 11 ]; then
  echo "error: expected 11 skills in _kit/skills, found $skill_count" >&2
  fail=1
fi

# The placeholders are substituted during onboarding, not here. An archive that
# has resolved them is broken.
if ! grep -rq '{{PATH}}' dist/2nd-brain; then
  echo "error: {{PATH}} placeholder is missing from the staged kit" >&2
  fail=1
fi
if ! grep -rq '{{TZ}}' dist/2nd-brain; then
  echo "error: {{TZ}} placeholder is missing from the staged kit" >&2
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "release aborted; dist/ left in place for inspection" >&2
  exit 1
fi

# --- pack ------------------------------------------------------------------

(cd dist && zip -rq 2nd-brain.zip 2nd-brain)

version=$(tr -d '[:space:]' < dist/2nd-brain/VERSION)
echo "built dist/2nd-brain.zip  (VERSION $version, $(find dist/2nd-brain -type f | wc -l | tr -d ' ') files)"
echo "attach this file to the GitHub release and link to it directly."
