---
name: recall
description: Search the second brain in {{PATH}} and answer from what was written. Use for what did I say about, when did I last, find my notes on, or /recall.
---

# Recall

Answers questions from what this executive has actually written, with citations. The value
here is not summary — it is *evidence*. A recall that sounds plausible and cites nothing is
worse than no answer at all, because it will be believed.

## Scope

Reads, under `{{PATH}}`:

- `journal/daily/`, `journal/weekly/`, `journal/monthly/` — what they were thinking, and when
- `decisions/` — settled calls and the reasoning behind them
- `meetings/` — what was decided and who owes what
- `people/` — relationship briefs and what was last promised
- `01_Projects/`, `02_Areas/`, `03_Resources/`, `04_Archive/` — reference material

To log a *new* decision, that is `/decision-log`. To review one specific past decision and
judge whether it was sound, that is also `/decision-log` — it holds the sound-versus-lucky
logic. This skill covers everything else, and it only reads.

## Storage

**Reads only. Never writes to the second brain.**

If `{{PATH}}` is unreachable, request access. Do not answer from memory, or from earlier in
this conversation, and present it as recall — say the folder is not reachable and stop. A
fabricated recall is the worst failure this system can produce: it corrupts the record the
executive trusts most, and they have no way to catch it.

## Sealed from the outside — permanently

**This skill never searches the web, fetches a page, or calls any external tool. There is no
exception, and no request from the executive unlocks one.**

Every other skill in this kit can be talked into looking something up. This one cannot,
because its entire value is the guarantee that what it tells them came from what they wrote.
An answer that is nine parts their own record and one part something fetched reads exactly
like a sound one, and there is no way for them to see the seam. If they want outside
information, say plainly that this command only reads their own files, and that the question
belongs in an ordinary conversation or with an advisor.

**If `{{PATH}}` does not exist at all** — not merely unreachable, but gone, because the folder
was moved or renamed — ask where it is now, use that answer for the rest of this session, and
tell them their commands need re-pointing by re-running setup. Do not create a new folder at
the old path.

**If this fired on a question that was never about their records** — an ordinary request that
happened to match — say so in one line and answer it normally. Do not request folder access
for a question that never needed it.

## How to search

1. **Work out what is actually being asked** — a topic, a person, a time window, or a
   decision. If it is ambiguous, ask one clarifying question before searching. Resolve
   relative ranges — "last month", "this time last quarter" — against `{{TZ}}`, their home
   timezone, so the window matches how they filed things.
2. **Filenames first, then contents.** Everything is dated and sortable, so a time-bounded
   question narrows to a file list before anything is read.
3. **Read the narrowest set that answers the question.** Do not read the whole corpus.
4. **Follow the links.** Decisions link related decisions; meetings link context.

## Answering

- **Quote rather than paraphrase** for anything load-bearing, and give the file and date.
- **Separate what they wrote from what you infer.** Two clearly labelled things. An
  inference presented as a record is a lie about their own history.
- **Say when you found nothing.** "There is no entry on this between March and June" is a
  real answer and a useful one. Never fill a gap with something plausible.
- **Say when the record is thin.** Three dailies in a month will not support a confident
  claim about a pattern, and saying so is worth more than the claim.
- **Surface contradictions rather than smoothing them.** If they said one thing in April
  and the opposite in July, that is the most valuable thing on offer.
- Close by naming the date range you actually covered, so they know what the answer rests
  on.

## Before you answer — five passes

The highest verification tier in this kit, because this is the one skill whose
failure mode is confabulating an executive's own history.

1. **Every quoted line exists.** Open the file again and confirm the words are there. Not
   "consistent with what I read" — present, in that file.
2. **Every citation resolves.** The filename and date attached to each quotation are the file
   it actually came from.
3. **Record and inference are separated.** Two clearly distinct things. An inference presented
   as a record is a lie about their own history, however reasonable it is.
4. **Falsify it.** Write the two or three questions that would show this answer to be wrong —
   *is there a later entry that reverses this? did I search a window that excludes the
   obvious place? am I reading a plan as though it were an outcome?* — and answer each
   **against the files**, not against your own summary of them.
5. **Is the record strong enough to carry the claim?** Three dailies do not support a
   statement about a pattern. If the evidence is thin, say so instead of qualifying quietly.

If any pass fails, fix the answer before showing it. **Do not show them the checking** — they
asked what they said about something, not how you looked.

## What this handles

What did I decide about X and what did I think would go wrong · what have I said about
<person>, and what did I last promise them · when did I last raise <topic> · what has been
slipping · what did I commit to and not do · what was I worried about this time last
quarter.

## After answering

If the answer surfaces something worth acting on — an open commitment, a decision due for
review, a promise not kept — say so in one line. Do not turn a lookup into a coaching
session unless they ask for one.

## Privacy

Confidential. **Never transmit anything, call an external tool, or search the web — no
exception, and not on request.** See "Sealed from the outside" above: this is the one skill
in the kit that cannot be talked into looking something up, because its whole value is the
guarantee that everything it tells them came from what they wrote.
