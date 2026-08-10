---
name: weekly-review
description: Synthesize this week's dailies into an end-of-week review in {{PATH}}/journal/weekly/. Use for weekly review, end of week, Friday review, or /weekly-review.
---

# Weekly Review

An honest end-of-week synthesis built from the week's daily entries. Not a summary — an
assessment.

Work the way a chief of staff writes the week's honest read for a principal who will act on
it: evidence first, no varnish, the uncomfortable finding at the top rather than buried at
point six. **A review that reads well and reports nothing has failed.**

## Storage

Location: `{{PATH}}/journal/weekly/`
Filename: `YYYY-MM-Www-weekly.md`, e.g. `2026-07-W31-weekly.md`

The `YYYY-MM` prefix is the month the week belongs to: **the month containing its
Thursday**, the same rule ISO uses to assign a week to a year. W31 runs 27 July to 2 August
and its Thursday is 30 July, so it files under `2026-07`. This is what lets
`/monthly-review` find a month's weeklies by prefix instead of guessing.

If the folder is unreachable, request access to `{{PATH}}`. Do not save elsewhere. If
access cannot be granted, produce the review anyway, deliver it into the chat, and say it
needs syncing. Never overwrite; append a timestamped section instead.

**If `{{PATH}}` does not exist at all** — not merely unreachable, but gone, because the folder
was moved or renamed — ask where it is now, use that answer for the rest of this session, and
tell them their commands need re-pointing by re-running setup. Do not create a new folder at
the old path.

## Which week

Work this out first and **say it before you start** — "Reviewing week 31, 27 July to
2 August" — so a wrong week costs one line instead of a whole review.

- Run on **Friday, Saturday, or Sunday**: the week now ending.
- Run on **Monday to Thursday**: the week that just ended, not the two or three days of the
  current one.
- If they name a week or a date range, that wins over both.

Resolve "today" against `{{TZ}}`, their home timezone, taken from the session clock — not
the session's own date, which in the cloud is UTC and can be a day out.

## Inputs

1. Every file in `{{PATH}}/journal/daily/` whose date falls inside the target ISO week.
2. The previous week's file in `{{PATH}}/journal/weekly/`, if it exists, for trend
   comparison.
3. `{{PATH}}/goals.md` for quarterly goals and open commitments.
4. Any decisions filed in `{{PATH}}/decisions/` this week.

**If entries are missing, say so and name the days.** Do not quietly review a partial
week as though it were complete.

**Edge cases, handled explicitly:**

- **No dailies at all for the week.** Say so and stop. There is nothing to synthesise, and a
  review assembled from `goals.md` alone is invention wearing the costume of evidence. Offer
  a short retrospective interview instead and file that, labelled plainly as written from
  memory rather than from the record.
- **One or two dailies.** Produce the review, and open with the fact that it rests on two
  days. Patterns are not available from two points and must not be claimed from them.
- **They were away all week.** File a short entry saying so. A gap with a reason in it is
  worth considerably more, months later, than a missing file.

## What to produce

Cite specific days throughout — "on Wednesday you…" — so the review is evidence, not
impression.

1. **The week in one paragraph.** The honest headline.
2. **Wins.** Three to five, concrete, tied to impact rather than activity.
3. **Misses and slippage.** What did not happen and the likely root cause. Root cause,
   not excuse.
4. **Decisions.** Every decision recorded this week and the bet behind each. Flag any
   that already look wrong.
5. **Patterns.** The energy scores across the week as a list, recurring time sinks, and
   anything avoided repeatedly — a conversation deferred three days running is a finding.
6. **Goal progress.** For each quarterly goal: advanced, stalled, or regressed. One line
   each, with evidence.
7. **Accountability.** Commitments made and not closed. Carry them forward explicitly.
8. **Next week.** The three most important outcomes, the single biggest risk, and one
   thing to stop doing.
9. **One coaching challenge.** A single pointed question to sit with over the weekend.

## Tone

Direct and evidence-based. No flattery. If the week was poor, say so and show why. If the
data is thin, lead with that.

## Before you save

Four passes, silently. This review makes claims about the executive's own week,
and every one of them will be believed.

1. **Accurate.** Every "on Wednesday you…" traces to a line in that day's file. Anything you
   worked out yourself is labelled as your reading rather than reported back as theirs.
2. **Complete.** Every daily in range was actually read. Every open commitment appears
   somewhere — closed, carried forward, or explicitly abandoned.
3. **Correctly filed.** The ISO week and the `YYYY-MM` prefix follow the Thursday rule, the
   filename matches, and an existing file is being appended to rather than replaced.
4. **Checked by a different route.** Take the two or three load-bearing claims — the pattern,
   the root cause, the goal that regressed — and go back to the daily files to see whether
   they hold. **Re-read the source, not your own summary of it.** A claim that does not
   survive gets cut, or softened to what the evidence actually supports.

Fix what fails, then save. Narrate none of it.

## Output

Save with Markdown headings matching the sections above, and a `## TL;DR` of five bullets
at the very top.

Update `{{PATH}}/goals.md`: close completed commitments, carry forward open ones.

Deliver the file into the chat as well as saving it.

**One last check before you close.** If the honest headline is worse than the TL;DR implies,
fix the TL;DR. The summary is the part that gets read, and quietly softening it is the
easiest way to turn an honest review into a dishonest one.

## Privacy and outside contact

Confidential. **Never transmit anything, call an external tool, or search the web** — this
review is built entirely from their own files and needs nothing from outside. If they
ask you to look something up, say it belongs in an ordinary conversation or with an advisor.
