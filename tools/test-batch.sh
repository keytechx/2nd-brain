#!/usr/bin/env bash
#
# test-batch.sh — acceptance tests for run-batch.sh
#
# Covers acceptance tests 2 and 6-9 from the spec, plus the refusal cases.
# Tests 1, 3, 4, 5 and 10 involve running the script for real and are driven
# from the report in BATCH-RUN.md.
#
#   ./test-batch.sh

set -u

# Locate the harness next to this script, whatever the cwd.
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
RUN_BATCH="$SELF_DIR/run-batch.sh"
[ -f "$RUN_BATCH" ] || { echo "cannot find run-batch.sh next to $0" >&2; exit 1; }

PASS=0; FAIL=0
ok()    { PASS=$(( PASS + 1 )); printf '    PASS  %s\n' "$*"; }
bad()   { FAIL=$(( FAIL + 1 )); printf '    FAIL  %s\n' "$*"; }
head_() { printf '\n== %s\n' "$*"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Load the functions without running anything. This also sets PROJECT.
BATCH_LIB_ONLY=1 . "$RUN_BATCH"
cd "$PROJECT" || exit 1
detect_timeout
detect_date

# Sourcing skips main(), which is what creates these.
mkdir -p "$DONE_DIR" "$SESS_DIR" "$LOG_DIR" "$ARCHIVE_DIR"

# Preserve any real state so the tests cannot destroy a run in progress.
STASH="$TMP/stash"; mkdir -p "$STASH"
for f in "$DONE_DIR"/*.done "$SESS_DIR"/*.id; do
    [ -e "$f" ] && mv "$f" "$STASH/" 2>/dev/null
done
restore_state() {
    rm -f "$DONE_DIR"/*.done "$SESS_DIR"/*.id 2>/dev/null
    for f in "$STASH"/*.done; do [ -e "$f" ] && mv "$f" "$DONE_DIR/"; done
    for f in "$STASH"/*.id;   do [ -e "$f" ] && mv "$f" "$SESS_DIR/"; done
}
trap 'restore_state; rm -rf "$TMP"' EXIT

# ---------------------------------------------------------------------------
head_ "TEST 6 — rate-limit detection, both confirmed formats"
# ---------------------------------------------------------------------------
FUTURE=$(( $(date +%s) + 3600 ))

printf 'Claude AI usage limit reached|%s\n' "$FUTURE" > "$TMP/f1.log"
is_rate_limited "$TMP/f1.log" && ok "epoch form matches" || bad "epoch form MISSED"

printf "You've hit your session limit \302\267 resets 10pm (Asia/Ho_Chi_Minh)\n" > "$TMP/f2.log"
is_rate_limited "$TMP/f2.log" && ok "clock form matches (note: no 'at')" || bad "clock form MISSED"

for s in "rate limit exceeded" "status 429" "Too Many Requests" \
         "API Error: overloaded_error" "resets at 3:30pm" "5-hour limit reached"; do
    printf '%s\n' "$s" > "$TMP/v.log"
    is_rate_limited "$TMP/v.log" && ok "variant matches: $s" || bad "variant MISSED: $s"
done

for s in "Error: ENOENT no such file" "TypeError: undefined is not a function" \
         "fatal: not a git repository"; do
    printf '%s\n' "$s" > "$TMP/n.log"
    is_rate_limited "$TMP/n.log" && bad "false positive on: $s" || ok "correctly ignores: $s"
done

printf 'Error: Session ID abc is already in use.\n' > "$TMP/s1.log"
is_session_in_use "$TMP/s1.log" && ok "session-in-use detected" || bad "session-in-use MISSED"
is_rate_limited "$TMP/s1.log" && bad "session-in-use read as a rate limit" || ok "session-in-use not confused with a limit"

printf 'No conversation found with session ID: abc\n' > "$TMP/s2.log"
is_no_conversation "$TMP/s2.log" && ok "no-conversation detected" || bad "no-conversation MISSED"
is_rate_limited "$TMP/s2.log" && bad "no-conversation read as a rate limit" || ok "no-conversation not confused with a limit"

# ---------------------------------------------------------------------------
head_ "TEST 7 — reset-time parsing (run twice: GNU, then forced BSD)"
# ---------------------------------------------------------------------------

# Assert compute_wait against an independently-known target rather than a
# guessed range, so the test cannot pass for the wrong reason.
check_wait_epoch() { # label logfile target_epoch
    local label="$1" f="$2" target="$3" want got
    want=$(( target - $(date +%s) + WAIT_SLACK ))
    [ "$want" -gt "$MAX_PARSED_WAIT" ] && want="$MAX_PARSED_WAIT"
    got="$(compute_wait "$f")"
    if [ "$got" -ge $(( want - 5 )) ] && [ "$got" -le $(( want + 5 )) ]; then
        ok "$label -> ${got}s (target implies ~${want}s)"
    else
        bad "$label -> ${got}s but target implies ${want}s"
    fi
}

check_wait_exact() { # label logfile expected
    local got; got="$(compute_wait "$2")"
    [ "$got" = "$3" ] && ok "$1 -> ${got}s" || bad "$1 -> ${got}s (expected $3)"
}

IANA="$(readlink /etc/localtime 2>/dev/null | sed 's|.*/zoneinfo/||')"
[ -n "$IANA" ] || IANA="UTC"
printf '  local zone: %s (abbreviates to %s)\n' "$IANA" "$(date +%Z)"

for KIND in gnu bsd; do
    if [ "$KIND" = "bsd" ]; then
        BATCH_FORCE_BSD_DATE=1; export BATCH_FORCE_BSD_DATE
    else
        unset BATCH_FORCE_BSD_DATE 2>/dev/null || true
    fi
    detect_date
    printf '  -- date path: %s --\n' "$DATE_KIND"

    # (1) epoch form
    T=$(( $(date +%s) + 3600 ))
    printf 'Claude AI usage limit reached|%s\n' "$T" > "$TMP/e.log"
    check_wait_epoch "[$DATE_KIND] epoch form" "$TMP/e.log" "$T"

    # (2) bare 10-digit epoch anywhere in the message
    printf 'usage limit; retry after %s please\n' "$T" > "$TMP/b.log"
    check_wait_epoch "[$DATE_KIND] bare epoch" "$TMP/b.log" "$T"

    # (4) unparseable -> fixed fallback, the forward-progress guarantee
    printf 'You have hit your usage limit. Try later.\n' > "$TMP/u.log"
    check_wait_exact "[$DATE_KIND] unparseable -> RETRY_SLEEP" "$TMP/u.log" "$RETRY_SLEEP"

    # cap: a wildly future epoch clamps to 6h
    printf 'Claude AI usage limit reached|%s\n' "$(( $(date +%s) + 864000 ))" > "$TMP/cap.log"
    check_wait_exact "[$DATE_KIND] 10-day epoch clamps to 6h" "$TMP/cap.log" "$MAX_PARSED_WAIT"

    # (3) clock form. Pick a target 3 hours out and read its wall-clock hour.
    T3=$(( $(date +%s) + 10800 ))
    H24="$(date -r "$T3" +%H)"
    if   [ "$((10#$H24))" -eq 0 ];  then AP=am; H12=12
    elif [ "$((10#$H24))" -lt 12 ]; then AP=am; H12=$((10#$H24))
    elif [ "$((10#$H24))" -eq 12 ]; then AP=pm; H12=12
    else AP=pm; H12=$(( 10#$H24 - 12 )); fi

    # The core BSD bug check: the parsed time must be exactly :00:00, not
    # carrying the current clock's minutes and seconds.
    GOT="$(epoch_from_clock "$H12" "00" "$AP" "$IANA")"
    if [ "$(date -r "$GOT" +%M%S 2>/dev/null)" = "0000" ]; then
        ok "[$DATE_KIND] clock form lands on :00:00 (got $(date -r "$GOT" '+%H:%M:%S'))"
    else
        bad "[$DATE_KIND] clock form inherited the current clock: $(date -r "$GOT" '+%H:%M:%S') — the BSD date -j bug"
    fi

    printf "You've hit your session limit \302\267 resets %s%s (%s)\n" "$H12" "$AP" "$IANA" > "$TMP/c.log"
    check_wait_epoch "[$DATE_KIND] clock form, IANA zone" "$TMP/c.log" "$GOT"

    # No timezone at all -> must use the LOCAL zone, never an abbreviation.
    printf "You've hit your session limit \302\267 resets %s%s\n" "$H12" "$AP" > "$TMP/c2.log"
    check_wait_epoch "[$DATE_KIND] clock form, no zone given" "$TMP/c2.log" "$GOT"

    # "resets at H:MM pm" with explicit minutes
    printf 'rate limit; resets at %s:30%s (%s)\n' "$H12" "$AP" "$IANA" > "$TMP/c3.log"
    G30="$(epoch_from_clock "$H12" "30" "$AP" "$IANA")"
    check_wait_epoch "[$DATE_KIND] clock form with :30 minutes" "$TMP/c3.log" "$G30"

    # An abbreviation must be REJECTED, not used as a zone. TZ="+07" parses as
    # a zero-offset zone and would silently shift the answer.
    if tz_ok "$(date +%Z)"; then
        bad "[$DATE_KIND] tz_ok accepted the abbreviation '$(date +%Z)'"
    else
        ok "[$DATE_KIND] tz_ok rejects the abbreviation '$(date +%Z)'"
    fi
    tz_ok "$IANA" && ok "[$DATE_KIND] tz_ok accepts $IANA" || bad "[$DATE_KIND] tz_ok rejected $IANA"

    # rollover: a time already past today must mean tomorrow
    TP=$(( $(date +%s) - 7200 ))
    HP="$(date -r "$TP" +%H)"
    if   [ "$((10#$HP))" -eq 0 ];  then PAP=am; PH=12
    elif [ "$((10#$HP))" -lt 12 ]; then PAP=am; PH=$((10#$HP))
    elif [ "$((10#$HP))" -eq 12 ]; then PAP=pm; PH=12
    else PAP=pm; PH=$(( 10#$HP - 12 )); fi
    ROLL="$(epoch_from_clock "$PH" "00" "$PAP" "$IANA")"
    if [ -n "$ROLL" ] && [ "$ROLL" -gt "$(date +%s)" ]; then
        ok "[$DATE_KIND] past time rolls to tomorrow ($(date -r "$ROLL" '+%Y-%m-%d %H:%M'))"
    else
        bad "[$DATE_KIND] past time did NOT roll forward"
    fi
done
unset BATCH_FORCE_BSD_DATE 2>/dev/null || true
detect_date

# ---------------------------------------------------------------------------
head_ "TEST 8 — resume vs fresh decision"
# ---------------------------------------------------------------------------
TESTID="01"
OUT="$(unit_outpath "$TESTID")"
mkdir -p "$(dirname "$OUT")"

decide() {
    local sess w
    sess="$(read_session "$TESTID")"
    w="$(words_in "$OUT")"
    if [ -n "$sess" ] && transcript_exists "$sess" && [ "$w" -ge "$RESUME_MIN_WORDS" ]; then
        printf 'resume'
    else
        printf 'fresh'
    fi
}

: > "$OUT"
rm -f "$(session_id_file "$TESTID")"
[ "$(decide)" = "fresh" ] && ok "empty output -> fresh" || bad "empty output should be fresh"

U1="$(mint_session "$TESTID")"
[ -n "$U1" ] && ok "mint_session wrote a UUID ($U1)" || bad "mint_session produced nothing"
[ "$(read_session "$TESTID")" = "$U1" ] && ok ".id file is the authority" || bad ".id file not written"

awk 'BEGIN{for(i=0;i<600;i++) printf "word "}' > "$OUT"
[ "$(decide)" = "fresh" ] && ok "600 words but no transcript -> fresh" || bad "should be fresh without a transcript"

mkdir -p "$(transcript_dir)"
FAKE="$(transcript_dir)/$U1.jsonl"; : > "$FAKE"
[ "$(decide)" = "resume" ] && ok "600 words + transcript -> resume" || bad "should resume"

awk 'BEGIN{for(i=0;i<100;i++) printf "word "}' > "$OUT"
[ "$(decide)" = "fresh" ] && ok "100 words + transcript -> fresh (below RESUME_MIN_WORDS)" || bad "should be fresh below threshold"

# 8a — collision recovery mints a *different* id and persists it
U2="$(mint_session "$TESTID")"
[ "$U1" != "$U2" ] && ok "collision recovery mints a new UUID ($U2)" || bad "minted the same UUID twice"
[ "$(read_session "$TESTID")" = "$U2" ] && ok ".id overwritten on re-mint" || bad ".id not overwritten"

rm -f "$FAKE" "$OUT" "$(session_id_file "$TESTID")"

# ---------------------------------------------------------------------------
head_ "TEST 9 — dependency guard"
# ---------------------------------------------------------------------------
rm -f "$DONE_DIR"/*.done 2>/dev/null
deps_satisfied 99 && bad "aggregator ran with 0 prerequisites done" || ok "aggregator blocked at 0/3"
ts > "$DONE_DIR/01.done"; ts > "$DONE_DIR/02.done"
deps_satisfied 99 && bad "aggregator ran at 2/3 — silent hole" || ok "aggregator still blocked at 2/3 (missing:$(missing_deps 99))"
ts > "$DONE_DIR/03.done"
deps_satisfied 99 && ok "aggregator unblocked at 3/3" || bad "aggregator still blocked at 3/3"
deps_satisfied 01 && ok "unit with no deps is never blocked" || bad "dependency-free unit blocked"
rm -f "$DONE_DIR"/*.done 2>/dev/null

# ---------------------------------------------------------------------------
head_ "TEST 8d — refusals (API key)"
# ---------------------------------------------------------------------------
OUTP="$(ANTHROPIC_API_KEY=sk-test "$RUN_BATCH" 2>&1)"
if printf '%s' "$OUTP" | grep -q "REFUSING: ANTHROPIC_API_KEY is set"; then
    ok "refuses to start with ANTHROPIC_API_KEY set"
else
    bad "did NOT refuse with ANTHROPIC_API_KEY set"
fi

printf '\n===============================================\n'
printf '  %d passed, %d failed\n' "$PASS" "$FAIL"
printf '===============================================\n\n'
[ "$FAIL" -eq 0 ]
