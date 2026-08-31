# BATCH-RUN — operating notes for `run-batch.sh`

An unattended, limit-resilient Claude Code batch runner. It runs a multi-part
job overnight, sleeps through usage limits, and resumes the work it was already
doing rather than starting over.

Built from `specs/live-testing/prompt-build-research-harness-macos.md`.
Verified on this machine, 31 August 2026 — Darwin 25.5.0, `/bin/bash` 3.2.57,
Homebrew coreutils 9.5, `claude` 2.1.251.

---

## Launch

**You have to launch this yourself, from your own terminal.** Claude cannot
start it from inside a session: auto permission mode blocks launching an
autonomous agent loop started with `--dangerously-skip-permissions`.

```bash
cd ~/Seminars/second-brain
mkdir -p .batch-run
nohup caffeinate -ims 2nd-brain/tools/run-batch.sh > .batch-run/nohup.out 2>&1 &
```

The harness lives in `2nd-brain/tools/`, but its **project root is the repo's
parent** — the folder you run it from. That is deliberate: `build-release.sh`
excludes `tools/` from the release but ships everything else at the repo root,
so runtime output written into the repo could reach an executive's download.
`.batch-run/`, `outputs/` and `prompts/` therefore live one level up, outside
the kit. Override with `BATCH_PROJECT` if you keep the work elsewhere.

Then close the terminal and walk away.

### Three rules for the machine

1. **Plug in.** Non-negotiable, not advice. On battery this Mac is set to
   `sleep 1` — it suspends after **one minute** idle. Preflight refuses to
   start on battery rather than warning.
2. **Leave the lid open**, or run true clamshell (external display *and*
   power). `caffeinate` does not prevent lid-close sleep. There is no flag that
   does.
3. On AC this Mac is already set to `sleep 0`, so system sleep is disabled
   before `caffeinate` even loads. `caffeinate` is belt-and-braces.

If the machine does suspend anyway, **nothing is lost.** Every completed unit
is checkpointed and every in-flight unit has a resumable session. Rerun the
same command and it picks up where it stopped. A suspended run looks alarming
and is not data loss.

---

## Monitoring — watch word counts, never the logs

```bash
2nd-brain/tools/run-batch.sh --status
```

**`claude -p` buffers.** It prints nothing until the invocation completes, so
`.batch-run/logs/<unit>.log` stays **empty for the entire time a unit is
running**. That looks exactly like a hang and invites killing a healthy job.

The live progress signal is **the output file growing**. `--status` reports
word counts for that reason. `--status` never takes the lock, so it always
answers, even mid-run.

For the running narrative:

```bash
tail -f .batch-run/logs/run.log
```

---

## Commands

```bash
2nd-brain/tools/run-batch.sh                # run every outstanding unit
2nd-brain/tools/run-batch.sh 03 05          # run only these
2nd-brain/tools/run-batch.sh --status       # completion table, then exit
2nd-brain/tools/run-batch.sh --reset 03 05  # archive output + clear checkpoints
```

`--status` and `--reset` are handled **before** the lock is taken, so the one
query you actually want mid-run is the one query that always works.

### `--reset` archives, it never deletes

Clearing the checkpoint alone is not enough — the output file stays on disk,
the resume rule then sees a large file and "continues" a document that is
already finished, and the reset silently does nothing. So `--reset` moves the
output to `.batch-run/archive/<name>.<timestamp>.md` first.

It never deletes, because regeneration produces a *different* document, not
strictly a better one. Keeping the old copy is what lets you diff what actually
improved — and recover a strong pass that the regeneration lost.

---

## Setting up the work

**1. Edit the `UNITS` table** near the top of `2nd-brain/tools/run-batch.sh`:

```
id | label | output file (relative to project) | comma-separated deps
```

Keep units sequential and independently checkpointable. Prefer **more, smaller
units** over one large unit — that is the whole design.

**2. Write one brief per unit** at `prompts/<id>.md`. The harness substitutes
`{{OUTFILE}}`, `{{UNIT_ID}}` and `{{LABEL}}` before sending. Preflight refuses
to start if any outstanding unit is missing its brief.

**3. Say whether the unit may delegate.** Claude Code spawns sub-agents on its
own initiative, and the harness has no say in it. Unless a unit genuinely needs
fan-out, tell it to work directly. If it may fan out, cap it explicitly and
raise that unit's timeout — `UNIT_TIMEOUT` is the only real bound.

**4. Tell each unit to write incrementally.** The output file is the only
durable artefact between checkpoints. A unit that composes everything in
context and writes once at the end has no partial credit, and the "watch the
file grow" signal silently stops being true.

---

## Tunables

All environment-overridable: `MODEL=sonnet 2nd-brain/tools/run-batch.sh`

| Variable | Default | Meaning |
|---|---|---|
| `MODEL` | `opus` | passed to `--model` |
| `EFFORT` | `high` | passed to `--effort` |
| `RETRY_SLEEP` | `900` | fallback backoff when a reset time cannot be parsed |
| `MAX_ATTEMPTS` | `40` | per unit |
| `MAX_HOURS` | `11` | hard stop for the whole run |
| `UNIT_TIMEOUT` | `150m` | kill a hung invocation; also the only bound on fan-out |
| `HARD_FAIL_RETRIES` | `2` | retries for failures that are *not* rate limits |
| `MIN_WORDS` | `3000` | below this, a "successful" unit is treated as incomplete |
| `RESUME_MIN_WORDS` | `500` | below this, never resume — start fresh instead |
| `MAX_PARSED_WAIT` | `21600` | cap a parsed wait at 6h so a misparse cannot idle the night |
| `WAIT_SLACK` | `120` | slack past a stated reset |

---

## How it handles a usage limit

Claude Code does not auto-resume after a limit. When you are rate-limited the
model is not running, so it cannot sleep and retry itself. Only a process
outside the session can notice, wait, and re-invoke. That is this script.

On a non-zero exit the harness classifies **the current attempt's log only** —
never the accumulated unit log, because one early limit message would make
every later unrelated failure look like a limit and retry forever.

Wait time, in priority order:

1. Epoch form — `Claude AI usage limit reached|1786492800`
2. A bare 10-digit epoch anywhere in the message
3. Clock form — `resets 10pm (Asia/Ho_Chi_Minh)`, honouring the stated zone
4. Otherwise `RETRY_SLEEP`

Plus 2 minutes slack, capped at 6 hours. **The fixed fallback is what
guarantees forward progress** — parsing is an optimisation, never a dependency.

### Failure classes

Every failure exits **rc=1** — rate limits, session collisions, missing
conversations, unrecognised models are indistinguishable by exit status. Only
rc 0 and rc 124 carry information, so the text classifier does all the work.

| Outcome | Action | Counts as a hard failure? |
|---|---|---|
| rc 0, words ≥ `MIN_WORDS` | checkpoint, next unit | — |
| rc 0, words < `MIN_WORDS` | retry (model stopped early) | no |
| rc 124 | brief sleep, retry (resumes) | no |
| rate limited | sleep until reset, retry | **no** |
| `Session ID … already in use` | mint a new UUID, retry at once | **no** |
| `No conversation found` | fall back to a fresh session | **no** |
| anything else | retry, then abandon the unit | yes |

One broken unit never consumes the whole night.

---

## Resume, and why session IDs are minted not derived

Each unit's session ID lives in `.batch-run/sessions/<unit>.id`, and **that
file is the sole authority**. It is generated with `uuidgen` on every fresh
start and overwritten — never derived from the unit name.

That matters because `--session-id` on an ID that already exists returns
`Error: Session ID … is already in use.` and rc=1. A reproducible ID would make
the fresh-start branch fail in about a second, twice, and the unit would be
abandoned.

A unit resumes only when **all three** hold: the `.id` file exists, its
transcript exists on disk, and the output file has at least
`RESUME_MIN_WORDS`. Otherwise it mints a new session and re-sends the full
brief — because "continue where you left off" sent to a model with no
instructions produces nothing.

---

## Permission mode — bypass, and the trade-off

The harness runs `--dangerously-skip-permissions`. Be clear about what that
means: **child agents act without approval checks.** The blast radius is scoped
by keeping the work inside the project directory.

Auto mode looks safer and is worse here. Denials persist for the entire run —
in non-interactive mode there is no turn boundary, so one bad classifier
verdict on a data host at 1am locks that unit out of it permanently, silently,
while the model "works around it" and produces weaker output. The classifier
can also fail closed.

If you want the narrower option, replace the flag with:

```
--permission-mode acceptEdits \
--allowedTools "Read Write Edit Glob Grep WebSearch WebFetch Bash(python3 *) Bash(curl *)"
```

---

## Credentials

**Never set `ANTHROPIC_API_KEY`.** Preflight refuses to start if it is set.

`claude` here authenticates by Keychain OAuth against your subscription.
Setting an API key would silently move an eleven-hour unattended run onto
metered API billing, and nothing in the logs would announce it.

A `.env` at the project root is sourced for **third-party** keys a unit needs
(search or data APIs). Keep it to those and `chmod 600` it. The harness logs
which variable *names* were loaded, never their values.

The login keychain is set `no-timeout`, so it will not lock overnight and block
a background run. If auth starts failing mid-night for no clear reason, check
that with `security show-keychain-info`.

---

## Troubleshooting

**Unit logs are empty while a unit runs.** Expected — `claude -p` buffers. Use
`--status`.

**"Another run-batch.sh is already running".** Check with `--status`. If the
pid is gone the lock is stale and the next run reclaims it automatically; to
clear it by hand, `rm -rf .batch-run/.lock`.

**A unit finished with fewer words than a mid-run sample.** Usually a good
sign when the work involves self-verification — the verify pass removed
material rather than padding.

**Editing the script while it runs** is safe if your editor replaces the file
atomically (new inode); the running shell keeps reading the original through
its open descriptor. It is *not* safe with in-place truncating writes.

**A run stopped an hour before the limit cleared.** Look for a limit message
the regex missed. Match broadly on "limit" and "resets", never on exact
sentences — the live message says `resets 10pm`, with no "at".

**Preflight refuses.** It refuses on battery, with `ANTHROPIC_API_KEY` set,
with no `timeout` binary, with no `claude` on `PATH`, with a missing prompt
file, or when the derived project path differs from the one recorded in
`.batch-run/project-path`. That last one is the case-sensitivity guard: the
filesystem is case-insensitive but the Claude transcript directory name is
not, so a different spelling would silently break every `--resume`. Each
prints the reason and the fix.

---

## Tests

```bash
2nd-brain/tools/test-batch.sh
```

Covers rate-limit classification (both confirmed formats plus variants and
false-positive guards), reset-time parsing on **both** the GNU and the forced
BSD path, the resume/fresh decision, session-collision recovery, the dependency
guard, and the API-key refusal.

`BATCH_FORCE_BSD_DATE=1` forces the BSD date branch. This matters: `gdate` is
installed here, so without forcing it the fallback would never execute in
testing — and the fallback is where the bug was.
