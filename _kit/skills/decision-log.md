---
name: decision-log
description: Capture a decision, its rationale and confidence, in {{PATH}}/decisions/. Use for log this decision, decision journal, what did we decide about, or /decision-log.
---

# Decision Log

Captures a decision and the reasoning behind it, at the moment it is made — before
hindsight rewrites the story. This is the highest-leverage habit in the whole system: it
separates decision *quality* from outcome *luck*, and it gives every future session the
*why* behind past calls.

Work like a clerk of the court rather than an advisor: your job is an accurate record of what
was known and believed **on the day**, not a better version of it. **The temptation to
improve the reasoning while writing it down is the one thing that would make this file
worthless**, because a record that flatters the thinking cannot be learned from.

## Storage

Location: `{{PATH}}/decisions/`
Filename: `YYYY-MM-DD-short-slug.md`, e.g. `2026-08-09-move-to-usage-pricing.md`

Date it against `{{TZ}}`, their home timezone, not the session's own date — a cloud session
runs in UTC. State the date you are using. The same applies to the computed `Review date`.

If the folder is unreachable, request access to `{{PATH}}`. Do not save elsewhere. If
access cannot be granted, capture the decision anyway, deliver it into the chat, and say
it needs syncing.

Never overwrite. If a file with that name already exists, extend the slug rather than
replacing it — a superseded decision is evidence, not clutter.

**If `{{PATH}}` does not exist at all** — not merely unreachable, but gone, because the folder
was moved or renamed — ask where it is now, use that answer for the rest of this session, and
tell them their commands need re-pointing by re-running setup. Do not create a new folder at
the old path.

## Two modes

**Logging a decision.** The default. Work through the interview below.

**Reviewing past decisions.** If they ask what they decided about something, or want to
revisit a call, search `{{PATH}}/decisions/`, surface the relevant entries, and compare
what was expected against what happened. When reviewing, always separate whether the
decision was sound from whether the outcome was lucky.

## Interview

One question at a time. Keep it to six or seven — the point is a durable record, not a
workshop. If they are logging a decision already made, do not relitigate it; capture it.

Do not accept vague answers on rationale, assumptions, or confidence. "It felt right" is
not a rationale, and a record that flatters the reasoning is worthless at review time —
the whole value of this file is that it is honest about what was known on the day. Push
once for something concrete, then take what you are given.

1. What is the decision, in one sentence?
2. What forced it? What changes if you do nothing?
3. Why this and not the alternatives — what were the real options?
4. What has to be true for this to work? Name the assumption it most depends on.
5. What outcome do you expect, and how confident are you, one to ten?
6. When should you revisit this, and what evidence would tell you it is going wrong?

Before saving, check `{{PATH}}/decisions/` for related prior decisions and link them.
If this one contradicts an earlier decision, say so — that is worth knowing.

## When it is not quite a decision

- **It is a preference, a plan, or a task.** Say so in one line and offer the right home for
  it rather than filing it here. A decisions folder full of to-dos stops being searchable.
- **It was made months ago.** Log it, dated to when it was actually taken, not today, and say
  in the entry that it was recorded in retrospect. Confidence and expected outcome recorded
  after the fact are worth much less, and the file should admit that.
- **They cannot name an alternative.** Push once: a decision with no rejected option was
  probably not a decision. If there genuinely was none, record that — it is a finding.
- **`{{PATH}}/decisions/` is empty or missing.** Ordinary on first use. Create the entry
  without comment; do not treat the absence of prior decisions as an error.
- **They start and then disappear.** Do not leave it unwritten — a decision is captured at the
  moment it is made or it is captured wrong. Save what you have, mark `Status: proposed`, put
  the unanswered questions in the file each followed by a blank `> ` line, and tell them it is
  saved and ready to finish. A half-filled record beats a remembered one a fortnight later.

## Before you save

Three passes, silently.

1. **Accurate.** Every line is what they said, not a tidier version of it. Their confidence
   number is theirs. No reasoning has been added that they did not give you.
2. **Complete.** Rationale, alternatives, the load-bearing assumption, expected outcome,
   confidence, tripwires and a review date are all present. A missing tripwire makes the
   entry unreviewable later, which defeats the file.
3. **Correctly filed.** Date resolved against `{{TZ}}`, slug descriptive, and an existing
   filename extended rather than overwritten.

**When reviewing a past decision rather than logging one**, add two more passes: go back to
the original file rather than working from what you remember of it earlier in this
conversation, and separate explicitly what the entry actually says from what you are
inferring about how it turned out.

## Entry format

```markdown
# Decision: <short declarative title>

Date: YYYY-MM-DD | Status: {proposed | made | revisit}
Reversible: {two-way door | one-way door}

## Context
<one paragraph — what forced the choice>

## Decision
<what we are doing>

## Rationale
<the load-bearing reasons>

## Alternatives considered
<A, B, C — and why each was rejected>

## Assumptions — what must be true

## Expected outcome
<what success looks like> — Confidence: <n>/10

## Tripwires
<evidence that would mean this is not working>

## Review date
YYYY-MM-DD

## Actual outcome
<left blank; filled in at review>

## Related
<links to prior decisions>
```

## After saving

Deliver the file into the chat as well as saving it.

## Privacy and outside contact

Confidential. **Never transmit anything, call an external tool, or search the web**.
A decision record is a record of what *they* believed; anything fetched from outside would
be a fact from today contaminating an account of what was known on the day.

**And write down the reasoning they gave, not the reasoning that reads well.** The pull to
tidy it up is strongest here at the end, once the shape of the entry is clear — a thin
rationale recorded as thin is the most valuable line in the file at review time, because it
is the one that tells them the call was luckier than it felt. If they ask you to soften
something they already said, keep the original and note the revision underneath it.
