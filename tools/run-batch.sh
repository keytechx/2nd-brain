#!/usr/bin/env bash
#
# run-batch.sh — unattended, limit-resilient Claude Code batch runner (macOS)
#
# Built from specs/live-testing/prompt-build-research-harness-macos.md
# (the version re-verified on this machine, 31 August 2026).
#
# Lives at <project>/2nd-brain/tools/run-batch.sh. Launch from the project root:
#     nohup caffeinate -ims 2nd-brain/tools/run-batch.sh > .batch-run/nohup.out 2>&1 &
#
# See BATCH-RUN.md for operating notes. A human must launch this — Claude
# cannot start it from inside a session.

set -u

# ---------------------------------------------------------------------------
# Project root — derived, never hardcoded.
#
# This script lives at <project>/2nd-brain/tools/run-batch.sh, so the project
# root is two levels up. Override with BATCH_PROJECT to keep the work elsewhere.
#
# It must NOT be the kit repo root. tools/build-release.sh excludes tools/ from
# the release but ships everything else at the root, so runtime output written
# there would reach an executive's download.
#
# APFS is case-insensitive but the Claude transcript directory name is a
# literal string, so ~/Seminars/... and ~/seminars/... yield two different
# transcript directories and break every resume. A hardcoded constant used to
# guarantee one spelling; now the first run records the spelling it saw and
# every later run asserts against it (see check_project_path).
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
PROJECT="${BATCH_PROJECT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

# ---------------------------------------------------------------------------
# 1. Configuration — every value environment-overridable
# ---------------------------------------------------------------------------
MODEL="${MODEL:-opus}"                       # --model
EFFORT="${EFFORT:-high}"                     # --effort
RETRY_SLEEP="${RETRY_SLEEP:-900}"            # fallback backoff, seconds
MAX_ATTEMPTS="${MAX_ATTEMPTS:-40}"           # per unit
MAX_HOURS="${MAX_HOURS:-11}"                 # hard stop for the whole run
UNIT_TIMEOUT="${UNIT_TIMEOUT:-150m}"         # kill a hung single invocation
HARD_FAIL_RETRIES="${HARD_FAIL_RETRIES:-2}"  # for failures that are NOT limits
MIN_WORDS="${MIN_WORDS:-3000}"               # below this, "success" is suspect

# Secondary tunables (spec-derived, rarely changed)
RESUME_MIN_WORDS="${RESUME_MIN_WORDS:-500}"  # below this, never resume — restart
MAX_PARSED_WAIT="${MAX_PARSED_WAIT:-21600}"  # cap a parsed wait at 6h
WAIT_SLACK="${WAIT_SLACK:-120}"              # slack past a stated reset
MIN_WAIT="${MIN_WAIT:-60}"                   # never sleep less than this
TIMEOUT_RETRY_SLEEP="${TIMEOUT_RETRY_SLEEP:-30}"

# ---------------------------------------------------------------------------
# 2. Unit definitions
#
#   id | label | output file (relative to PROJECT) | comma-separated deps
#
# No associative arrays — /bin/bash here is 3.2 and does not have them.
# The brief for each unit lives in prompts/<id>.md; the harness substitutes
# {{OUTFILE}}, {{UNIT_ID}} and {{LABEL}} into it before sending.
#
# >>> REPLACE THE ROWS BELOW WITH THE REAL UNIT LIST. <<<
# ---------------------------------------------------------------------------
UNITS='
01|Example unit one|outputs/01-example-one.md|
02|Example unit two|outputs/02-example-two.md|
03|Example unit three|outputs/03-example-three.md|
99|Aggregate the above|outputs/99-aggregate.md|01,02,03
'

# ---------------------------------------------------------------------------
# Derived paths
# ---------------------------------------------------------------------------
STATE="$PROJECT/.batch-run"
DONE_DIR="$STATE/done"
SESS_DIR="$STATE/sessions"
LOG_DIR="$STATE/logs"
ARCHIVE_DIR="$STATE/archive"
LOCK="$STATE/.lock"
RUNLOG="$LOG_DIR/run.log"
PROMPT_DIR="$PROJECT/prompts"
PATH_RECORD="$STATE/project-path"

TIMEOUT_BIN=""
DATE_KIND=""     # "gnu" (gdate) or "bsd"
GDATE_BIN=""
RUN_DEADLINE=0
LOCK_HELD=0

# ---------------------------------------------------------------------------
# Small helpers — all BSD-safe
# ---------------------------------------------------------------------------

# Portable ISO timestamp. BSD date on Darwin 25 does support -Iseconds, but
# this form works on every macOS and on Linux.
ts() { date +%Y-%m-%dT%H:%M:%S%z; }

now() { date +%s; }

log() {
    if [ -d "$LOG_DIR" ]; then
        printf '%s  %s\n' "$(ts)" "$*" | tee -a "$RUNLOG"
    else
        printf '%s  %s\n' "$(ts)" "$*"
    fi
}

die() { log "FATAL: $*"; exit 1; }

# Word count, whitespace-stripped. macOS `wc -w` pads with leading spaces;
# `test` tolerates that in numeric comparison, but string use and log
# formatting do not.
words_in() {
    if [ -f "$1" ]; then
        wc -w < "$1" | tr -d ' '
    else
        printf '0'
    fi
}

# --- unit table access -----------------------------------------------------

unit_lines() {
    printf '%s\n' "$UNITS" | grep -v '^[[:space:]]*$' | grep -v '^[[:space:]]*#'
}

all_unit_ids() { unit_lines | awk -F'|' '{print $1}'; }

unit_exists() { all_unit_ids | grep -qx "$1"; }

unit_label()   { unit_lines | awk -F'|' -v i="$1" '$1==i {print $2; exit}'; }
unit_outfile() { unit_lines | awk -F'|' -v i="$1" '$1==i {print $3; exit}'; }
unit_deps()    { unit_lines | awk -F'|' -v i="$1" '$1==i {print $4; exit}'; }

unit_outpath() { printf '%s/%s' "$PROJECT" "$(unit_outfile "$1")"; }

is_done() { [ -f "$DONE_DIR/$1.done" ]; }

# ---------------------------------------------------------------------------
# 3. Preflight — detect, print, and refuse
# ---------------------------------------------------------------------------

detect_timeout() {
    if command -v timeout >/dev/null 2>&1; then
        TIMEOUT_BIN="$(command -v timeout)"
    elif command -v gtimeout >/dev/null 2>&1; then
        TIMEOUT_BIN="$(command -v gtimeout)"
    else
        TIMEOUT_BIN=""
    fi
}

detect_date() {
    if command -v gdate >/dev/null 2>&1; then
        GDATE_BIN="$(command -v gdate)"
        DATE_KIND="gnu"
    else
        GDATE_BIN=""
        DATE_KIND="bsd"
    fi
    # BATCH_FORCE_BSD_DATE=1 forces the fallback path so acceptance test 7 can
    # exercise it. Without this, gdate shadows the branch and it ships untested.
    if [ "${BATCH_FORCE_BSD_DATE:-0}" = "1" ]; then
        DATE_KIND="bsd"
    fi
}

# The project path must stay byte-identical across runs. The filesystem is
# case-insensitive; the transcript directory name is not. First run records,
# every later run asserts.
check_project_path() {
    local recorded
    if [ -f "$PATH_RECORD" ]; then
        recorded="$(cat "$PATH_RECORD" 2>/dev/null)"
        if [ "$recorded" != "$PROJECT" ]; then
            printf '  REFUSING: project path differs from the one this state was created with.\n'
            printf '            recorded: %s\n' "$recorded"
            printf '            derived:  %s\n' "$PROJECT"
            printf '            The transcript directory name is case-sensitive, so a\n'
            printf '            different spelling silently breaks every --resume.\n'
            printf '            Invoke via the recorded path, or set BATCH_PROJECT.\n\n'
            return 1
        fi
    else
        printf '%s' "$PROJECT" > "$PATH_RECORD"
    fi
    return 0
}

preflight() {
    local ok=1 bashver claude_bin claude_ver

    detect_timeout
    detect_date

    bashver="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
    claude_bin="$(command -v claude 2>/dev/null || true)"
    claude_ver="$( [ -n "$claude_bin" ] && "$claude_bin" --version 2>/dev/null | head -1 || true)"

    printf '\n  preflight — %s\n' "$(ts)"
    printf '  %-22s %s\n' "bash"            "$bashver ($BASH)"
    printf '  %-22s %s\n' "timeout binary"  "${TIMEOUT_BIN:-<none>}"
    printf '  %-22s %s\n' "date"            "$( [ "$DATE_KIND" = gnu ] && printf 'GNU via %s' "$GDATE_BIN" || printf 'BSD fallback' )"
    printf '  %-22s %s\n' "claude"          "${claude_bin:-<not found>} ${claude_ver}"
    printf '  %-22s %s\n' "project"         "$PROJECT"
    printf '  %-22s %s\n' "cwd"             "$PWD"
    printf '  %-22s %s\n' "prompts dir"     "$( [ -d "$PROMPT_DIR" ] && printf '%s' "$PROMPT_DIR" || printf '%s (MISSING)' "$PROMPT_DIR" )"
    printf '  %-22s %s\n' "power"           "$(pmset -g batt 2>/dev/null | head -1 | sed 's/^Now drawing from //')"
    printf '\n'

    # --- hard refusals ------------------------------------------------------

    # 1. Battery. This Mac has `sleep 1` on battery — it suspends after one
    #    minute idle. A warning is not enough.
    if pmset -g batt 2>/dev/null | grep -q "Battery Power"; then
        printf '  REFUSING: on battery power.\n'
        printf '            This Mac suspends after 1 minute idle on battery.\n'
        printf '            Plug in and rerun.\n\n'
        ok=0
    fi

    # 2. Path stability. We already cd'd to PROJECT, so this asserts the
    #    derived path matches the one the run state was created with.
    check_project_path || ok=0
    if [ "$PWD" != "$PROJECT" ]; then
        printf '  REFUSING: working directory is not the project path.\n'
        printf '            expected: %s\n' "$PROJECT"
        printf '            actual:   %s\n' "$PWD"
        ok=0
    fi

    # 3. API key would move the run off the subscription onto metered billing.
    if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
        printf '  REFUSING: ANTHROPIC_API_KEY is set.\n'
        printf '            This would bill the API instead of the subscription.\n'
        printf '            Unset it (and remove it from .env) and rerun.\n\n'
        ok=0
    fi

    # 4. No timeout binary. Deliberately a refusal, not a shell fallback —
    #    see BATCH-RUN.md. A hung invocation would consume the whole night.
    if [ -z "$TIMEOUT_BIN" ]; then
        printf '  REFUSING: no timeout/gtimeout on PATH.\n'
        printf '            brew install coreutils\n\n'
        ok=0
    fi

    # 5. claude itself.
    if [ -z "$claude_bin" ]; then
        printf '  REFUSING: claude is not on PATH.\n\n'
        ok=0
    fi

    # 6. Every outstanding unit needs a brief.
    local id missing=""
    for id in $(all_unit_ids); do
        is_done "$id" && continue
        [ -f "$PROMPT_DIR/$id.md" ] || missing="$missing $id"
    done
    if [ -n "$missing" ]; then
        printf '  REFUSING: missing prompt file(s) for outstanding unit(s):%s\n' "$missing"
        printf '            expected at %s/<id>.md\n\n' "$PROMPT_DIR"
        ok=0
    fi

    [ "$ok" -eq 1 ] || exit 1
    printf '  preflight OK\n\n'
}

# ---------------------------------------------------------------------------
# 4. Lock — mkdir is atomic; macOS has no flock
# ---------------------------------------------------------------------------

acquire_lock() {
    if mkdir "$LOCK" 2>/dev/null; then
        printf '%s' "$$" > "$LOCK/pid"
        LOCK_HELD=1
        trap release_lock EXIT INT TERM
        return 0
    fi

    local pid=""
    [ -f "$LOCK/pid" ] && pid="$(cat "$LOCK/pid" 2>/dev/null)"

    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
        printf 'Another run-batch.sh is already running (pid %s).\n' "$pid"
        printf 'Use --status to check progress; it does not take the lock.\n'
        exit 1
    fi

    log "stale lock from pid ${pid:-unknown} — reclaiming"
    rm -rf "$LOCK"
    if mkdir "$LOCK" 2>/dev/null; then
        printf '%s' "$$" > "$LOCK/pid"
        LOCK_HELD=1
        trap release_lock EXIT INT TERM
        return 0
    fi
    die "could not acquire lock at $LOCK"
}

release_lock() {
    [ "$LOCK_HELD" -eq 1 ] && rm -rf "$LOCK"
    LOCK_HELD=0
}

# ---------------------------------------------------------------------------
# 5. Rate-limit detection and wait computation
#
# Classify against the CURRENT ATTEMPT's log only. Grepping the accumulated
# unit log means one early limit message makes every later unrelated failure
# in that unit look like a limit, and it retries forever (reference bug 2).
# ---------------------------------------------------------------------------

LIMIT_RE='usage limit|rate limit|session limit|limit reached|hit your .*limit|resets( at)? *[0-9]|rate_limit|too many requests|status (429|529)|overloaded'

is_rate_limited() { grep -Eiq "$LIMIT_RE" "$1" 2>/dev/null; }

is_session_in_use() {
    grep -Eiq 'Session ID .* is already in use' "$1" 2>/dev/null
}

is_no_conversation() {
    grep -Eiq 'No conversation found with session ID' "$1" 2>/dev/null
}

# Is $1 a timezone we can actually use?
#
# Only an IANA name (Asia/Ho_Chi_Minh) or UTC/GMT. NEVER an abbreviation: the
# local zone here abbreviates to "+07", and TZ="+07" is parsed as a POSIX zone
# with a ZERO offset — silently shifting every computed reset by the local UTC
# offset. Falling back to `date +%Z` for an unknown zone reintroduced exactly
# the class of silent misparse this harness exists to avoid.
tz_ok() {
    [ -n "${1:-}" ] || return 1
    case "$1" in
        */*|UTC|GMT) ;;
        *) return 1 ;;
    esac
    [ -n "$(TZ="$1" date +%Z 2>/dev/null)" ]
}

# Run date (or gdate) in $ZONE when set, otherwise in the machine's local zone.
zdate()  { if [ -n "${ZONE:-}" ]; then TZ="$ZONE" date "$@"; else date "$@"; fi; }
zgdate() { if [ -n "${ZONE:-}" ]; then TZ="$ZONE" "$GDATE_BIN" "$@"; else "$GDATE_BIN" "$@"; fi; }

# epoch_from_clock <hour> <min> <ampm> <tz>  -> epoch on stdout, or empty
epoch_from_clock() {
    local h="$1" m="$2" ap="$3" tz="${4:-}" target today tomorrow
    local ZONE=""
    if tz_ok "$tz"; then
        ZONE="$tz"
    fi

    if [ "$DATE_KIND" = "gnu" ]; then
        target="$(zgdate -d "today $h:$m$ap" +%s 2>/dev/null)"
        if [ -n "$target" ] && [ "$target" -le "$(now)" ]; then
            target="$(zgdate -d "tomorrow $h:$m$ap" +%s 2>/dev/null)"
        fi
    else
        # BSD date -j fills every field the format does not mention FROM THE
        # CURRENT TIME. A partial format like "%I%p" therefore returns 22:31:42
        # instead of 22:00:00. Always build a complete format with explicit
        # zeros, and compute the date in the target timezone.
        today="$(zdate +%Y-%m-%d)"
        target="$(zdate -j -f "%Y-%m-%d %I:%M:%S%p" "$today $h:$m:00$ap" +%s 2>/dev/null)"
        if [ -n "$target" ] && [ "$target" -le "$(now)" ]; then
            tomorrow="$(zdate -v+1d +%Y-%m-%d 2>/dev/null)"
            target="$(zdate -j -f "%Y-%m-%d %I:%M:%S%p" "$tomorrow $h:$m:00$ap" +%s 2>/dev/null)"
        fi
    fi
    printf '%s' "${target:-}"
}

# compute_wait <attempt log> -> seconds to sleep, on stdout
compute_wait() {
    local f="$1" msg epoch clock h m ap tz wait target

    msg="$(tr -d '\r' < "$f" 2>/dev/null | grep -Ei "$LIMIT_RE" | head -5)"

    # (1) Epoch form: "Claude AI usage limit reached|1786492800"
    epoch="$(printf '%s' "$msg" \
        | grep -Eio 'limit reached\|[0-9]{10}' \
        | grep -Eo '[0-9]{10}' | head -1)"

    # (2) Bare 10-digit epoch anywhere in the message
    if [ -z "$epoch" ]; then
        epoch="$(printf '%s' "$msg" | grep -Eo '(^|[^0-9])[0-9]{10}([^0-9]|$)' \
            | grep -Eo '[0-9]{10}' | head -1)"
    fi

    if [ -n "$epoch" ]; then
        target="$epoch"
    else
        # (3) Clock form: "resets 10pm (Asia/Ho_Chi_Minh)" / "resets at 3:30pm".
        #     Note there is no "at" in the live message — match it optional.
        clock="$(printf '%s' "$msg" \
            | grep -Eio 'resets( at)? *[0-9]{1,2}(:[0-9]{2})? *(am|pm)' | head -1)"
        if [ -n "$clock" ]; then
            h="$(printf '%s' "$clock" | grep -Eo '[0-9]{1,2}(:[0-9]{2})?' | head -1)"
            m="00"
            case "$h" in
                *:*) m="${h#*:}"; h="${h%%:*}" ;;
            esac
            ap="$(printf '%s' "$clock" | grep -Eio '(am|pm)' | head -1 | tr 'A-Z' 'a-z')"
            # IANA name, or UTC/GMT. An abbreviation like (+07) is
            # deliberately NOT captured — see tz_ok.
            tz="$(printf '%s' "$msg" \
                | grep -Eo '\(([A-Za-z]+/[A-Za-z0-9_+-]+|UTC|GMT)\)' \
                | head -1 | tr -d '()')"
            target="$(epoch_from_clock "$h" "$m" "$ap" "$tz")"
        else
            target=""
        fi
    fi

    # (4) Fallback. This is what guarantees forward progress; parsing is an
    #     optimisation and must never be a dependency.
    if [ -z "$target" ]; then
        printf '%s' "$RETRY_SLEEP"
        return
    fi

    wait=$(( target - $(now) + WAIT_SLACK ))
    [ "$wait" -lt "$MIN_WAIT" ] && wait="$MIN_WAIT"
    [ "$wait" -gt "$MAX_PARSED_WAIT" ] && wait="$MAX_PARSED_WAIT"
    printf '%s' "$wait"
}

# ---------------------------------------------------------------------------
# 6. Session handling
# ---------------------------------------------------------------------------

transcript_dir() {
    printf '%s/.claude/projects/%s' "$HOME" "$(printf '%s' "$PROJECT" | sed 's|/|-|g')"
}

new_session_id() { uuidgen | tr 'A-Z' 'a-z'; }

session_id_file() { printf '%s/%s.id' "$SESS_DIR" "$1"; }

# The .id file is the SOLE authority. Never derive an ID from the unit name —
# reusing an existing --session-id returns "already in use" and rc=1, which
# would make the fresh-start branch fail every time.
mint_session() {
    local id="$1" uuid f
    uuid="$(new_session_id)"
    f="$(session_id_file "$id")"
    mkdir -p "$(dirname "$f")"
    printf '%s' "$uuid" > "$f" || die "cannot write session id to $f"
    # If the write silently failed the caller would proceed with an ID that was
    # never persisted, mint another next attempt, and never resume.
    [ "$(cat "$f" 2>/dev/null)" = "$uuid" ] || die "session id did not persist to $f"
    printf '%s' "$uuid"
}

read_session() {
    local f
    f="$(session_id_file "$1")"
    [ -f "$f" ] && cat "$f" || printf ''
}

transcript_exists() {
    [ -n "$1" ] && [ -f "$(transcript_dir)/$1.jsonl" ]
}

# ---------------------------------------------------------------------------
# 7. Prompt assembly
# ---------------------------------------------------------------------------

build_prompt() {
    local id="$1" outfile="$2" label="$3"
    sed -e "s|{{OUTFILE}}|$outfile|g" \
        -e "s|{{UNIT_ID}}|$id|g" \
        -e "s|{{LABEL}}|$label|g" \
        "$PROMPT_DIR/$id.md"
}

resume_prompt() {
    local outfile="$1"
    cat <<EOF
Continue exactly where you left off. Your work in progress is at $outfile —
read it first, then carry on from the end of it. Do not restart, do not
re-plan, and do not rewrite sections that are already complete. Append to the
file as you go rather than holding the whole document in context.
EOF
}

# ---------------------------------------------------------------------------
# 8. Per-unit execution loop
# ---------------------------------------------------------------------------

deps_satisfied() {
    local id="$1" deps dep
    deps="$(unit_deps "$id")"
    [ -z "$deps" ] && return 0
    for dep in $(printf '%s' "$deps" | tr ',' ' '); do
        [ -z "$dep" ] && continue
        is_done "$dep" || return 1
    done
    return 0
}

missing_deps() {
    local id="$1" deps dep out=""
    deps="$(unit_deps "$id")"
    for dep in $(printf '%s' "$deps" | tr ',' ' '); do
        [ -z "$dep" ] && continue
        is_done "$dep" || out="$out $dep"
    done
    printf '%s' "$out"
}

run_unit() {
    local id="$1"
    local label outfile outpath attempt=0 hard_fails=0
    local sess mode prompt rc w attempt_log unit_log wait

    label="$(unit_label "$id")"
    outfile="$(unit_outfile "$id")"
    outpath="$(unit_outpath "$id")"
    attempt_log="$LOG_DIR/$id.attempt.log"
    unit_log="$LOG_DIR/$id.log"

    if is_done "$id"; then
        log "[$id] already complete — skipping"
        return 0
    fi

    # Dependency guard. Without this an aggregation unit will happily consume a
    # partial set, mark itself done, and ship a deliverable with a silent hole.
    if ! deps_satisfied "$id"; then
        log "[$id] DEFERRED — waiting on:$(missing_deps "$id") (stays pending, no output written)"
        return 0
    fi

    mkdir -p "$(dirname "$outpath")"

    while [ "$attempt" -lt "$MAX_ATTEMPTS" ]; do
        attempt=$(( attempt + 1 ))

        if [ "$(now)" -ge "$RUN_DEADLINE" ]; then
            log "[$id] global time budget (${MAX_HOURS}h) exhausted — stopping"
            return 2
        fi

        # --- decide fresh vs resume ---------------------------------------
        # Only resume when there is real work to continue. A unit that died
        # four seconds in has a session but no instructions in it, and
        # "continue where you left off" to an empty context produces nothing.
        sess="$(read_session "$id")"
        w="$(words_in "$outpath")"

        if [ -n "$sess" ] && transcript_exists "$sess" && [ "$w" -ge "$RESUME_MIN_WORDS" ]; then
            mode="resume"
        else
            mode="fresh"
            sess="$(mint_session "$id")"
        fi

        log "[$id] attempt $attempt/$MAX_ATTEMPTS — $mode (session ${sess%%-*}…, ${w} words on disk)"

        if [ "$mode" = "resume" ]; then
            prompt="$(resume_prompt "$outfile")"
        else
            prompt="$(build_prompt "$id" "$outfile" "$label")"
        fi

        # --- invoke --------------------------------------------------------
        : > "$attempt_log"
        if [ "$mode" = "resume" ]; then
            "$TIMEOUT_BIN" "$UNIT_TIMEOUT" claude -p "$prompt" \
                --resume "$sess" \
                --model "$MODEL" --effort "$EFFORT" \
                --dangerously-skip-permissions \
                > "$attempt_log" 2>&1
            rc=$?
        else
            "$TIMEOUT_BIN" "$UNIT_TIMEOUT" claude -p "$prompt" \
                --session-id "$sess" \
                --model "$MODEL" --effort "$EFFORT" \
                --dangerously-skip-permissions \
                > "$attempt_log" 2>&1
            rc=$?
        fi

        {
            printf '===== attempt %s rc=%s %s (%s) =====\n' \
                "$attempt" "$rc" "$(ts)" "$mode"
            cat "$attempt_log"
            printf '\n'
        } >> "$unit_log"

        w="$(words_in "$outpath")"

        # --- classify ------------------------------------------------------
        # Every failure mode exits rc=1 — rate limits, session collision,
        # missing conversation, unrecognised model. Only rc 0 and rc 124 carry
        # information, so the text classifier does all the real work.

        if [ "$rc" -eq 0 ] && [ "$w" -ge "$MIN_WORDS" ]; then
            ts > "$DONE_DIR/$id.done"
            log "[$id] COMPLETE — $w words"
            return 0
        fi

        if [ "$rc" -eq 0 ]; then
            log "[$id] clean exit but only $w words (need $MIN_WORDS) — treating as incomplete, retrying"
            continue
        fi

        if [ "$rc" -eq 124 ]; then
            log "[$id] TIMEOUT after $UNIT_TIMEOUT — sleeping ${TIMEOUT_RETRY_SLEEP}s then resuming"
            sleep "$TIMEOUT_RETRY_SLEEP"
            continue
        fi

        if is_rate_limited "$attempt_log"; then
            wait="$(compute_wait "$attempt_log")"
            log "[$id] RATE LIMITED — sleeping ${wait}s (until ~$(date -r $(( $(now) + wait )) '+%Y-%m-%d %H:%M %Z' 2>/dev/null))"
            log "[$id]   message: $(grep -Ei "$LIMIT_RE" "$attempt_log" | head -1 | cut -c1-160)"
            sleep "$wait"
            continue    # does NOT count against HARD_FAIL_RETRIES
        fi

        if is_session_in_use "$attempt_log"; then
            log "[$id] session ID collision — minting a new one and retrying immediately"
            mint_session "$id" >/dev/null
            continue    # does NOT count against HARD_FAIL_RETRIES
        fi

        if is_no_conversation "$attempt_log"; then
            log "[$id] transcript missing for session $sess — falling back to a fresh session"
            mint_session "$id" >/dev/null
            continue    # does NOT count against HARD_FAIL_RETRIES
        fi

        hard_fails=$(( hard_fails + 1 ))
        log "[$id] HARD FAILURE $hard_fails/$HARD_FAIL_RETRIES (rc=$rc): $(head -3 "$attempt_log" | tr '\n' ' ' | cut -c1-200)"
        if [ "$hard_fails" -ge "$HARD_FAIL_RETRIES" ]; then
            log "[$id] giving up after $hard_fails hard failures — moving to the next unit"
            return 1
        fi
        sleep 10
    done

    log "[$id] exhausted MAX_ATTEMPTS ($MAX_ATTEMPTS) — moving on"
    return 1
}

# ---------------------------------------------------------------------------
# 9. --status  (must NOT take the lock — this is the one query you want
#               mid-run, and taking the lock was reference bug 1)
#
# Reports word counts, not log sizes: `claude -p` buffers, so a unit's log
# stays empty while it runs. The live progress signal is the output file.
# ---------------------------------------------------------------------------

cmd_status() {
    local id label outpath w state deps
    printf '\n  %-4s %-34s %-10s %9s  %s\n' "UNIT" "LABEL" "STATE" "WORDS" "OUTPUT"
    printf '  %s\n' "------------------------------------------------------------------------------------"
    for id in $(all_unit_ids); do
        label="$(unit_label "$id")"
        outpath="$(unit_outpath "$id")"
        w="$(words_in "$outpath")"
        if is_done "$id"; then
            state="done"
        elif ! deps_satisfied "$id"; then
            state="blocked"
        elif [ "$w" -gt 0 ]; then
            state="in progress"
        else
            state="pending"
        fi
        printf '  %-4s %-34s %-10s %9s  %s\n' \
            "$id" "$(printf '%.34s' "$label")" "$state" "$w" "$(unit_outfile "$id")"
    done
    printf '\n'

    if [ -d "$LOCK" ] && [ -f "$LOCK/pid" ]; then
        local pid; pid="$(cat "$LOCK/pid" 2>/dev/null)"
        if kill -0 "$pid" 2>/dev/null; then
            printf '  a run is active (pid %s)\n' "$pid"
        else
            printf '  stale lock present (pid %s is gone)\n' "$pid"
        fi
    else
        printf '  no run active\n'
    fi
    printf '  tail -f %s\n\n' "${RUNLOG#$PROJECT/}"
}

# ---------------------------------------------------------------------------
# 10. --reset  (also before the lock)
#
# Clearing the checkpoint alone is not enough: the output file stays on disk,
# the resume rule then sees a large file and "continues" a document that is
# already finished, and the reset silently does nothing. We archive it.
# We never delete — regeneration produces a different document, not strictly
# a better one, and the old copy is what makes that recoverable.
# ---------------------------------------------------------------------------

cmd_reset() {
    local id outpath base tag dest
    [ "$#" -gt 0 ] || die "--reset needs at least one unit id"
    tag="$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$ARCHIVE_DIR"
    for id in "$@"; do
        unit_exists "$id" || die "unknown unit: $id"
        outpath="$(unit_outpath "$id")"
        if [ -f "$outpath" ]; then
            base="$(basename "$outpath")"
            dest="$ARCHIVE_DIR/${base%.md}.$tag.md"
            mv "$outpath" "$dest"
            printf '  [%s] archived %s -> %s (%s words)\n' \
                "$id" "$base" "${dest#$PROJECT/}" "$(words_in "$dest")"
        fi
        rm -f "$DONE_DIR/$id.done" "$(session_id_file "$id")"
        printf '  [%s] checkpoint and session cleared\n' "$id"
    done
    printf '\n'
}

# ---------------------------------------------------------------------------
# 11. Main
# ---------------------------------------------------------------------------

usage() {
    cat <<'EOF'
Usage (from the project root):
  2nd-brain/tools/run-batch.sh                run every outstanding unit
  2nd-brain/tools/run-batch.sh 03 05          run only these units
  2nd-brain/tools/run-batch.sh --status       completion table, then exit
  2nd-brain/tools/run-batch.sh --reset 03 05  archive output + clear checkpoints

Launch unattended (plugged in, lid open):
  nohup caffeinate -ims 2nd-brain/tools/run-batch.sh > .batch-run/nohup.out 2>&1 &
EOF
}

main() {
    # cd to the canonical spelling before anything else, so the child `claude`
    # always sees one transcript directory.
    cd "$PROJECT" 2>/dev/null || die "project directory not found: $PROJECT"

    mkdir -p "$DONE_DIR" "$SESS_DIR" "$LOG_DIR" "$ARCHIVE_DIR"

    case "${1:-}" in
        --status) cmd_status; exit 0 ;;
        --reset)  shift; cmd_reset "$@"; exit 0 ;;
        -h|--help) usage; exit 0 ;;
    esac

    # Credentials: third-party keys only. ANTHROPIC_API_KEY is refused in
    # preflight — setting it would move the run off the subscription onto
    # metered API billing, silently.
    if [ -f "$PROJECT/.env" ]; then
        set -a; . "$PROJECT/.env"; set +a
        log "loaded .env: $(grep -Eo '^[A-Za-z_][A-Za-z0-9_]*=' "$PROJECT/.env" | tr -d '=' | tr '\n' ' ')"
    fi

    preflight

    local targets
    if [ "$#" -gt 0 ]; then
        local t
        for t in "$@"; do
            unit_exists "$t" || die "unknown unit: $t"
        done
        targets="$*"
    else
        targets="$(all_unit_ids | tr '\n' ' ')"
    fi

    acquire_lock

    RUN_DEADLINE=$(( $(now) + MAX_HOURS * 3600 ))

    log "=========================================================="
    log "run starting — pid $$"
    log "model=$MODEL effort=$EFFORT min_words=$MIN_WORDS unit_timeout=$UNIT_TIMEOUT"
    log "units: $targets"
    log "deadline: $(date -r "$RUN_DEADLINE" '+%Y-%m-%d %H:%M %Z' 2>/dev/null) (${MAX_HOURS}h)"
    log "NOTE: claude -p buffers — unit logs stay empty while a unit runs."
    log "      Watch word counts with --status, not the logs."
    log "=========================================================="

    local id rc
    for id in $targets; do
        run_unit "$id"
        rc=$?
        if [ "$rc" -eq 2 ]; then
            log "time budget exhausted — stopping the run"
            break
        fi
    done

    log "----------------------------------------------------------"
    log "run finished"
    # Release before the closing table, or --status reports the run as active.
    release_lock
    cmd_status | tee -a "$RUNLOG"
}

# Sourcing guard: BATCH_LIB_ONLY=1 loads the functions without running
# anything, so the acceptance tests can exercise the classifier and the
# reset-time parser directly.
if [ "${BATCH_LIB_ONLY:-0}" != "1" ]; then
    main "$@"
fi
