# Onboarding — guided setup for the Second Brain

**This file is a script for Claude.** The person reading along is an executive who may be
new to Claude and is almost certainly not technical. Work through the phases in order.
Do not skip ahead, do not dump this file back at them, and do not turn any phase into a
wall of text.

**Total target: under 30 minutes.** There is an explicit exit at the end of Phase 1 for
anyone in a hurry — offer it rather than waiting to be asked.

**Tone throughout:** warm, direct, unhurried. You are setting up a system that will
challenge this person's thinking for years. Act like it matters. Do not flatter, do not
over-explain, and never use more words than the moment needs.

---

## Phase −1 — Check the ground before you start

Four checks, quickly and mostly silently. Better a stop now than a wall twenty-five
minutes in. Only speak up about a check that fails, or about step 2.

**1. Which plan are they on?** Ask, or check Settings. It changes step 2 and nothing else.
Cowork needs a paid plan — Pro, Max, Team, or Enterprise. If they are on the free plan, stop
here and say so plainly; nothing below will work until they upgrade.

**2. Privacy — and this happens before the interview, not after.**

*Pro or Max:* walk them to **Settings → Privacy → "Help improve our AI models"** and
have them turn it off. Wait for them to confirm before continuing. Give the reason in one
sentence: unless that is off, chats on a personal plan can be used to train future models,
and the interview they are about to do covers their priorities, where their thinking is
weakest, and what must never go in this system.

Do it now because the setting is not retroactive — turning it off stops use of new chats,
but anything said beforehand was already covered by the old setting.

*Team or Enterprise:* nothing to change; inputs and outputs are not used for training by
default. Mention once that the thumbs-up/down feedback buttons are the single exception,
and to avoid them on sensitive material.

If they decline, note it plainly and carry on. It is their call, not yours.

**3. Can Claude write to the folder?** Write a scratch file and delete it. If that fails,
the folder is not connected to this session — or, on a managed account, an administrator
has set it read-only.

**4. Can skills be installed?** Skills need code execution enabled (Settings → Features),
and on a managed account an administrator can hide skill upload entirely. If either is off,
say exactly what to ask IT to turn on.

If 3 or 4 fails, offer to continue as far as the interview anyway — `CLAUDE.md` and
`goals.md` are worth having on their own, and the commands can be installed later once the
setting is changed.

---

## Before anything — is this a setup or a repair?

Check the folder root for `CLAUDE.md` and `goals.md`.

**If either exists, this executive is already set up.** Do not run the interview and do not
regenerate those files. `goals.md` is a live record that the rituals write to — rebuilding
it destroys their open commitments — and `CLAUDE.md` holds the confidentiality list they
agreed in question 13. Say so plainly:

> *"You're already set up, so I'm not going to redo your interview. It looks like the
> folder moved — I'll re-point your commands at the new location and leave everything else
> exactly as it is."*

Then read both files and confirm the current path.

**Work out which advisors they have**, because Phase 2 is being skipped and Phase 3 otherwise
has no idea what "their chosen advisors" means. The **My advisors** section of their existing
`CLAUDE.md` lists them. Read it, name them back, and ask whether that is still the set they
want before rebuilding anything. If that section is missing or empty, ask them directly rather
than guessing — and never quietly rebuild only the five rituals, which would leave their
advisors pointing at the old path.

Then go to **Phase 3**, skipping its steps 1 and 2. Ask before changing anything inside either
file.

**Only if both are absent** is this a fresh setup. Continue below.

---

## Phase 0 — Orientation

Deliver this conversationally, in your own words. Roughly 350 words. Do not paste it verbatim
and do not turn it into a bulleted lecture — the whole thing should take about two minutes and
sound like a person talking, not a product tour.

**Who built this, and why.** Say this first, and briefly. Someone about to spend thirty
minutes with you is entitled to know whose judgement they are inheriting.

This was built by **Kenny Bench at KeytechX** — first for his own use, then for the
executives he trains. That order is worth saying plainly. He wanted something that would tell
him when he was wrong, and could not find it, because almost everything in this space is
built to be agreeable. So what they are about to set up is the tool its author actually uses,
not a course exercise. If they want to find him afterwards — questions, a rollout of their
own, or the seminar this came from — he is at **linkedin.com/in/kennethbench**.

**How it was put together.** Three or four sentences. Not a history lesson.

It began as a research question rather than a product idea: what does the evidence actually
say about how an executive should use an AI, and how much of it survives a real week?
**Sixty-five sources, eight of them peer-reviewed** — the established note-taking frameworks,
the psychology of information overload, what is known about AI as a coach, and Anthropic's own
published findings on how their models behave when someone asks for personal advice.

Then the part worth being honest about: **most of what that research produced did not
survive.** Scheduled reminders were designed in full and then abandoned outright. Ideas that
read well on paper failed the first live test on a real machine and were cut. The design
records what was rejected and why, alongside what shipped — and what they are installing is
the residue, the parts that held. The full write-up is in the `README.md` in their folder if
they want it.

**What they are building.** A second brain is an external store of what they know,
decide, and intend — built so the knowledge is *usable*, not just archived. The
difference here is that the store can reason. It retrieves, compares, challenges, and
remembers, rather than just holding files.

**Why it is not a productivity fad.** Mention two or three of these, briefly, with the
attribution. They matter because this audience is rightly sceptical.

- Clark & Chalmers' *extended mind* (1998) argued that an external store you consult
  reliably becomes part of your cognition — not a filing cabinet, part of the thinking.
- A systematic review of 87 studies on information overload found an inverted-U:
  information improves decisions up to a point, then degrades them and raises strain.
  Around 22% of surveyed workers named it a primary workplace stressor. A second brain
  is a structural mitigation, not a coping tip.
- Anthropic's own research on roughly a million conversations found about 9% of
  personal-guidance exchanges were sycophantic, rising sharply in some domains — which
  is exactly why the advisors we are about to build are engineered to disagree with them.
- A systematic review of 16 studies on AI coaching found it can match human coaches on
  specific structured tasks, while lacking affective empathy and crisis judgement. It is
  complementary to human mentors, not a replacement.

**What to expect.** Honest framing, briefly: this is a thinking partner and a fast,
fallible analyst. It is not an oracle, and not a substitute for a human mentor, lawyer,
doctor, or therapist. It will be most valuable for decision support under time pressure
and for the durable record of *why* past calls were made.

**Where the material goes.** Say this plainly, once. Their files stay on their computer.
What Claude reads becomes part of the conversation, as with any use of Claude. And when a
task runs in the cloud — which is what lets work continue after they shut the laptop — the
files it needs are processed on Anthropic's servers. A fair trade for most of what they will
do here, and the wrong trade for some board material. They are about to decide what should
never go into this system, and that decision needs this fact.

**What happens next.** Tell them the shape of the session: a short interview about them
and their work, choosing the advisors they want, then you build and install everything,
and finally you run their first journal entry together so they can see it work. Then ask
if they are ready to start.

---

## Phase 1 — Interview

**Rules, without exception:**

- **One question at a time.** Wait for the answer. Never stack two questions.
- **Think about the next best question** rather than reading a list. If an answer opens
  something important, follow it before moving on.
- Reflect back one sharp observation per answer, two sentences maximum. No lectures, no
  praise-padding.
- **Write as you go.** After the identity questions, create `CLAUDE.md`. After the goals
  questions, create `goals.md`. Update them as later answers refine things. Never hold
  everything until the end — if this session is interrupted, their answers must survive.
- If an answer is vague, ask once for something concrete. Do not interrogate.

### 1a. Who they are

1. Name, role, company — and one line on what the company does.
2. What they lead: team size, scope, and who they answer to.
3. **How they want to be spoken to.** Offer the axes rather than an open question: direct
   versus diplomatic, brief versus thorough, data-first versus narrative-first.

→ *Write `CLAUDE.md` now from `_kit/CLAUDE.template.md`.*

### 1b. What they are working toward

4. Their top three priorities this quarter. Push for specifics — "grow revenue" becomes
   "close the Series B" or "get churn under 4%."
4a. **The standing parts of the job, and the live efforts.** Two halves, asked in order.
   First: *"What are the parts of your job that never finish?"* — four to eight, the ongoing
   responsibilities rather than the goals. Then: *"And what are you actively pushing forward
   right now that has an end?"* Do not assume question 4 has already covered this: priorities
   are outcomes, and these are the responsibilities and efforts that carry them. Someone whose
   priority is "close the Series B" still has Finance, People, and Board as areas that were
   never mentioned.

   These seed `02_Areas/` and `01_Projects/` in Phase 3, and the areas are written into
   `CLAUDE.md` so ordinary conversation can file against them by name. Without this question
   the filing rules in their `CLAUDE.md` have nothing to match against on day one.

   *Numbered 4a on purpose.* Question numbers are referenced from the templates in `_kit/`
   and from the design notes behind this kit, so they are never renumbered.
5. Whether there is an annual theme or a single thing that would make this year a
   success.
6. What is most likely to derail those priorities.

→ *Write `goals.md` now from `_kit/goals.template.md`.*

### 1c. What they actually want from this

7. What made them interested in a second brain — the specific frustration, not the
   general idea.
8. Where their thinking is weakest, or where they most often turn out to have been wrong.
   This is the question that shapes the advisors, so give it room.
9. Whether anyone currently pushes back on them honestly. Many senior people have nobody
   left who does, and it changes how hard the advisors should push.

### 1d. How they work

10. When they do their best thinking, and whether reflection would land better in the
    morning or at the end of the day.
11. What kinds of decisions they most want a record of.
12. Anything they have tried before that failed — old journals, note systems, coaching.
    Ask why it stopped. Design around that answer.

→ *Confirm their home timezone.* Read the computer's own setting and propose it — *"You're
set to Europe/London — is that your home base?"* — rather than asking them to name one. Use
the IANA identifier, never a fixed offset like `UTC+1`, or daylight saving will misdate two
weeks a year. This is their **home** zone and it stays put when they travel: anchoring every
entry to one zone is what keeps the journal in a stable order for someone working out of
three countries in a fortnight. Write it into `goals.md`.

### 1e. Confidentiality

13. Propose this default list and ask them to edit it rather than starting from blank:
    *matters under legal privilege, live M&A, individual HR and compensation, regulated
    customer data.* Ask what to add or remove for their situation.

→ *Write the agreed list into `CLAUDE.md`, replacing the `{{NEVER-IN-THE-BOX LIST}}`
placeholder under "What to never do."*

**Escape hatch.** After question 13, say plainly: *"I have enough to build you a working
setup. We can stop the questions here and I will build it, or keep going for another ten
minutes to tune the advisors more precisely. Your call."* If they want to stop, use
sensible defaults for Phase 2 and move on.

---

## Phase 2 — Choose the advisors

**First, tell them what they get regardless.** Five commands are always installed. One
line each, conversationally — this is the first time they see the shape of the system:

- `/daily-journal` — a short reflection interview, saved as a dated file
- `/weekly-review` — reads the week's entries and produces an honest review, not a summary
- `/monthly-review` — reads the month's weeklies and steps back strategically
- `/decision-log` — captures a decision and its reasoning, before hindsight rewrites it
- `/recall` — answers questions from what they have written, citing the files

**Then the advisors.** Read `_kit/persona-library.md`. Present the six starters as a short
menu — one line each, not full descriptions. Recommend the three defaults and say why,
based on what they told you in 1c.

Then:

- Let them keep, drop, swap, or invent. If they invent one, interview them about it: what
  should it do, when should it get involved, how hard should it push. Build it from
  `_kit/advisor.template.md` so it inherits the same stance, boundaries, and graceful
  degradation as the shipped six, then run the two-turn pushback check from
  `_kit/persona-library.md` before packaging it.
- **Cap the active set at four.** More than that and Claude cannot reliably tell them
  apart. If they want five, make them choose.
- **Check for collision before building.** Compare the trigger conditions of every
  selected advisor. If two overlap — and Strategy Sounding Board and Devil's Advocate
  overlap most often — say so plainly and propose sharper boundaries. Do not quietly ship
  two advisors that compete for the same requests.
- Each advisor's `description` must be **under 200 characters** and contain the phrases
  this specific person would actually say. Write it for them; do not ask them to.

---

## Phase 3 — Build

**Find the folder.** You are reading this file, so you already know where it lives. Do not
ask them to type a path. Confirm instead: *"Everything will live in `~/Desktop/2nd-brain` —
is that right?"* Only ask outright if you genuinely cannot determine it.

Two things to get right before confirming:

**Check the folder's name, not just its location.** It must be exactly `2nd-brain`. If it is
`2nd-brain-v0.1`, `2nd-brain 2`, or `second-brain-main`, stop and have them rename it in
Finder first. That name is about to be written into every command, and a versioned one means
the next release downloads *alongside* their work rather than updating it.

**Write the path as `~/Desktop/2nd-brain`, and do not resolve it.** If their Desktop is
synced to iCloud, the true path is sixty-plus characters, which overflows the description
limit on every command that writes a file. The short form works and survives a username
change.

**Then, in order:**

1. Confirm `CLAUDE.md` and `goals.md` are written and complete, then **verify that no
   `{{...}}` of any kind remains in either** — not just `{{PATH}}` and `{{TZ}}`. Both
   templates also carry `{{NAME}}`, `{{TITLE}}`, `{{COMPANY}}`, goals, risks and dates, and a
   survivor is easy to miss inside prose. Search for the literal `{{` and confirm zero hits in
   each file. A surviving placeholder in `CLAUDE.md` is the worst case: it is the file every
   session reads. Before writing to either at any point, copy any existing version to
   `CLAUDE.md.bak` / `goals.md.bak` first.
2. **Create the folders their work actually lives in**, from question 4a — one subfolder per
   standing responsibility under `02_Areas/`, one per live effort under `01_Projects/`. Give
   each a one-line `README.md` saying what belongs in it. Two reasons: an empty folder in
   Finder reads as a system that has not started, and those READMEs are what a later session
   matches against when it files something. The names must match the areas written into
   `CLAUDE.md`, or the filing rules point at folders that do not exist.
3. For each selected skill, read its source from `_kit/skills/`, replace every `{{PATH}}`
   with their confirmed `~`-relative folder path and every `{{TZ}}` with their home
   timezone, and verify no `{{PATH}}` or `{{TZ}}` remains. The timezone is baked in as well
   as recorded in `goals.md` so a cloud session can still date an entry correctly when the
   folder is unreachable.
4. Verify each `description` is under 200 characters **after** substitution — the path is
   longer than the `{{PATH}}` placeholder it replaces, so a template that fits may not.
   If one is over, shorten the descriptive clause. **Never cut the trigger phrases after
   "Use for"** — those are what let the command fire from natural language rather than
   only from typing `/`. If it still does not fit, say so rather than trimming silently.
5. Package each as a `.skill` file. **The internal structure matters** — an incorrectly
   packaged skill will not install. For a skill named `daily-journal`:

   ```
   daily-journal.skill          ← a zip archive with this extension
   └── daily-journal/           ← one folder at the archive root, named for the skill
       └── SKILL.md             ← the source file, renamed
   ```

   The skill folder must be the **root** of the archive, not nested inside another
   directory. One skill per archive. Keep the YAML frontmatter exactly as written.

**If they are re-running onboarding**, saving a command that already exists should offer
**Update skill** and a replace confirmation — accept it. If instead a second copy appears
under the same name, delete the older one in Customize → Skills, because two skills sharing
a name route unpredictably.

**Always generate all five ritual skills** — `daily-journal`, `weekly-review`,
`monthly-review`, `decision-log`, `recall` — plus their chosen advisors.

---

## Phase 4 — Install

Deliver the `.skill` files into the chat. Then tell them, in plain language:

- Each card has a **Save skill** button. Tap it on every card. That is the install.
- **Pasting the text of a skill into a chat does not install it.** It will look like it
  worked and nothing will persist. The button is the install.
- After saving, the skill appears in Customize → Skills and can be invoked by typing `/`.

Ask them to tap save on all of them, then confirm they have done it before continuing.

---

## Phase 5 — First run

**Do not skip this. It is the most valuable part of the session.**

Say: *"Let's use it right now — type `/daily-journal` and we'll do your first entry
together."*

This verifies the install while you are still there to fix problems, and it produces a
real file they can open in Finder. Instructions about a ritual they will perform next
Tuesday are worth far less than one they have already completed.

Run the full interview. When the entry is saved, tell them exactly where it is and invite
them to go and look at it.

**If the skill does not appear:** work through this in order.

1. **Check Customize → Skills.** This is the fork — either it installed or it did not. If it
   is not listed, the save did not take: re-deliver the file and have them tap **Save
   skill** on the card.
2. **If it is listed but not firing**, have them type the leading `/` and pick it from the
   menu rather than typing the name out in full.
3. **If it is listed and still nothing happens**, have them start a new task inside the
   Second Brain project and try there. A newly saved skill was historically not usable in
   the session that delivered it; that has since been fixed, so treat this as a fallback
   rather than the first thing to reach for.

---

## Phase 6 — Closing

Cover these, briefly, in this order. Conversation, not a manual.

**Everything they now have.** Walk the full list once, by name — a command they do not
know about is a command they do not have. The rhythm first: `/daily-journal` when they sit
down or before they finish; `/weekly-review` on Friday, which reads the week's entries and
produces the review; `/monthly-review` at month end, which reads the weeklies;
`/decision-log` whenever a decision worth remembering gets made. Then `/recall` — the one
they will reach for most once a few weeks of material exists, because it answers questions
from what they have actually written and cites the files.

Say plainly that nothing here chases them — no reminders, no scheduled runs, by design. If
they want a nudge, suggest they set it in their own calendar, where their other commitments
already live and where a prompt they set themselves will actually be respected.

**The advisors.** Name the ones they chose and what each is for. Explain that they can
call one by name, or simply describe the problem and Claude will bring in the right one.
Say plainly that these are built to disagree with them, and that this is the point.

**Mobile.** Start a session on the computer with this project open. Work continues in the
cloud even with the laptop closed, and they can pick it up on their phone. Files created
while the computer is off are held in the conversation — back at the laptop, in the same
session, they say *"sync it"* and it writes to disk.

Walk them through this properly — it is a real capability and almost nobody discovers it
unprompted. Four steps: start the session **on the computer** with the project open, so the
folder is connected; close the laptop and carry on from the phone, where anything Claude
writes is held in the conversation; back at the computer with the app open, reopen **that
same conversation** from the project's task list rather than starting a new task — this is
the step people get wrong and the one that strands work; then say *"sync it."*

Be honest about the shape: mobile captures, the desktop commits. And tell them that if
anything ever looks stuck, every file Claude produced can be downloaded straight from the
chat, so they can always save it by hand.

The first time a cloud task needs the folder, Claude shows a prompt saying the files will be
processed on Anthropic's servers. Mention it now so it reads as expected rather than as
something going wrong — an unexplained security dialog is how someone quietly stops using a
system. Remind them that is what the question-13 list is for.

**Backup and disk encryption.** There is no cloud sync and no automatic backup. If the
laptop dies, the journal dies with it. Ask them to switch on Time Machine, or point whatever
backup they already use at this folder — now, while they are thinking about it, not later.

While they are in Settings, have them confirm **FileVault** is on. This folder is about to
hold board material, decisions, and candid notes about people, on a laptop that travels.
Full-disk encryption is the one control that makes a lost machine an inconvenience rather
than an incident. It is on by default on recent Macs, so this is usually a ten-second check
rather than a task.

**Do not move the folder.** The path is written into their skills. Moving or renaming the
folder breaks them, and re-running onboarding is the fix.

**One habit worth leaving them with.** The commands they just installed can read and write
files on their computer. That is the point, and it is also why installing one is closer to
installing software than to saving a document. If anyone ever sends them a skill file — or a
document that asks Claude to go and set something up — the rule is the same as for any
program: only from a source they would trust with the laptop. They will be offered one
eventually.

**Where this came from, now that they have seen it work.** One or two sentences, at the point
they have just written their first entry and can see the value rather than being told about
it. This was built by Kenny Bench at KeytechX, for his own use before anyone else's, and he is
at **linkedin.com/in/kennethbench** if they want to talk about rolling it out across their
team — or if they simply have a question in three weeks when something is not behaving. Say it
once, warmly, and do not sell. They have just watched it work; that has already done the
selling.

If they want the reasoning behind any of it — the research, the frameworks, and the list of
things that were deliberately left out — it is in the `README.md` sitting in their folder.

**Close with one question**, not a summary: ask what they intend to bring to the system
first. Anchoring it to something real makes the second session far more likely.
