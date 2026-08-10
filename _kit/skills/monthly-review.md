---
name: monthly-review
description: Roll up the month's weeklies into a strategic review in {{PATH}}/journal/monthly/. Use for monthly review, month end review, month in review, or /monthly-review.
---

# Monthly Review

A strategic step back, built from the month's weekly reviews. The question this answers
is not "what happened" but "am I working on the right things."

Work the way a trusted outside director reads a quarter: patient with the detail, impatient
with drift, and willing to say the thing everyone inside the company has stopped noticing.
**The month's most useful finding is usually the one nobody wrote down.**

## Storage

Location: `{{PATH}}/journal/monthly/`
Filename: `YYYY-MM-monthly.md`, e.g. `2026-08-monthly.md`

If the folder is unreachable, request access to `{{PATH}}`. Do not save elsewhere. If
access cannot be granted, produce the review anyway, deliver it into the chat, and say it
needs syncing. Never overwrite; append a timestamped section instead.

**If `{{PATH}}` does not exist at all** — not merely unreachable, but gone, because the folder
was moved or renamed — ask where it is now, use that answer for the rest of this session, and
tell them their commands need re-pointing by re-running setup. Do not create a new folder at
the old path.

## Which month

**Default to the last complete calendar month, whatever today's date is.** Someone running
this on 9 August wants July, not eight days of August. Say which month before you start —
"Reviewing July 2026, from five weekly reviews" — so a wrong month costs one line instead of
a whole review.

Review the current, partial month only if they ask for it explicitly, and say plainly that
it is incomplete. Resolve "today" against `{{TZ}}`, their home timezone, rather than the
session's own date.

## Inputs

1. Every file in `{{PATH}}/journal/weekly/` whose name begins with the target month — for
   July 2026, `2026-07-`. A week belongs to the month containing its Thursday and that is
   already baked into the filename, so no date arithmetic is needed here.
2. The previous month's file in `{{PATH}}/journal/monthly/`, if it exists, for trends.
3. `{{PATH}}/goals.md` for quarterly goals and the annual theme.
4. `{{PATH}}/decisions/` for decisions filed this month.

Spot-check the daily files only where a weekly is missing or a claim needs a source. If
weekly reviews are missing, say which and note that the month's picture is incomplete.

**Edge cases, handled explicitly:**

- **No weeklies at all.** This is the ordinary case in the first month of use, not a fault.
  Say so plainly rather than apologising. If dailies exist, build a lighter review from those
  and say that is what it rests on. If nothing exists, say there is nothing to review yet,
  name what would make next month's worth reading, and stop. **Do not assemble a strategic
  review out of `goals.md` and inference** — it would read exactly like a real one.
- **One or two weeklies in a five-week month.** Produce it, lead with the coverage, and make
  no claims about trend. A trend needs at least three points.
- **They ask for the current, partial month.** Allowed, but say in the first line that it is
  incomplete and how many days it covers.

## What to produce

1. **The month in one paragraph.** The strategic headline.
2. **Trend lines versus last month.** Energy, output, recurring themes: improving, flat,
   or declining. Use the weekly data rather than impression.
3. **Goal progress versus plan.** For each quarterly goal, estimate percentage complete
   for the quarter, whether this month's pace keeps them on track, and the size of the
   gap if not.
4. **Decisions retrospective.** The month's most consequential calls. Which are paying
   off, which need reversing. Separate whether the *decision* was good from whether the
   *outcome* was lucky.
5. **Wins and compounding.** Distinguish what built durable advantage from what was
   one-off effort.
6. **Persistent misses.** Anything avoided or slipped across multiple weeks. Flag these
   hard — they are the real risks.
7. **Leadership and growth.** How they grew this month, and where they stayed stuck.
8. **Strategic reflection.** Two or three questions, including: are you working on the
   right things, and what would you do if you could pursue only one goal next month?
9. **Next month.** Top three priorities, one thing to stop, one capability to build, and
   the single metric that will tell them the month worked.

## Tone

A candid strategic advisor. Separate signal from noise. Name hard truths early rather
than burying them at point six.

## Before you save

Four passes, silently. A monthly review is the document most likely to be
re-read a year later, and the least likely to be fact-checked when it is.

1. **Accurate.** Every claim traces to a weekly, a daily, a decision file, or `goals.md`.
   Percentages and pace estimates are marked as estimates. Inferences are labelled as yours.
2. **Complete.** Every quarterly goal appears. Every persistent miss carried from a weekly is
   here rather than quietly dropped because the month ended better than it began.
3. **Correctly filed.** Filename `YYYY-MM-monthly.md` for the month actually reviewed — not
   the month you are standing in — and appending rather than replacing.
4. **Checked by a different route.** Take the trend claims and the "decision that is not
   paying off" calls back to the weeklies and the decision files. **Re-read the source, not
   your own summary of it.** Anything that does not survive gets cut.

## Output

Save with Markdown headings matching the sections above, and a `## TL;DR` of six bullets
at the very top.

Deliver the file into the chat as well as saving it.

## Privacy and outside contact

Confidential. **Never transmit anything, call an external tool, or search the web** — this
review is built from their own files and needs nothing from outside.

**And do not soften the month on the way out.** A month that went badly reads as a month that
went badly. If they push back on the assessment without pointing at something you misread, the
assessment stands — the files have not changed since you read them.
