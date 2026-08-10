# Second Brain for Executives

**For people with a wide surface of responsibility and a steady stream of high-stakes calls.**

A Claude-powered second brain that holds your goals, your decisions, and the reasoning behind
them — plus a bench of advisors engineered to disagree with you, and reviews that run daily,
weekly, and monthly.

**One folder. One command a day. No coding, ever.**

Setup is a guided interview that takes about thirty minutes, once. After that the whole system
is: open one project, type one command.

---

## The problem

You make consequential calls at speed, across more surface area than one person can hold in
their head. Three things go wrong, quietly.

**The reasoning evaporates.** Six months on you remember the decision but not the bet you were
making — so you cannot tell a good call that went badly from a bad call that got lucky.

**Nobody tells you no.** The more senior you get, the fewer people left who will say "that
assumption is doing all the work here."

**Context scatters.** What you promised someone, what you decided last quarter, what you were
worried about this time last year — all real, none of it findable when you need it.

---

## What this actually is

Most notes systems are filing cabinets. This one can reason. It reads what you have
written, compares it, challenges it, and remembers what you decided and why.

Three layers:

**A second brain** — your decisions, meeting notes, priorities, and briefs, held in a
folder Claude can read and write.

**A bench of advisors** — a Devil's Advocate who attacks positions you already hold, a
Strategy Sounding Board that pressure-tests plans before you commit resources, a coach
who holds you to what you said you would do. You choose which ones you want and they are
built to your situation.

**Five commands** — a short daily reflection, a weekly review that reads the week, a monthly
review that reads the weeks, a decision log that captures your reasoning before hindsight
rewrites it, and a recall command that answers questions from what you have actually written,
citing the files.

It is a thinking partner and a fast, fallible analyst. It is not an oracle, and it does
not replace a human mentor, lawyer, doctor, or therapist.

---

## Built to disagree — on purpose

Anthropic's own research, across roughly a million conversations, found about **9% of
personal-guidance exchanges were sycophantic**, rising sharply in some domains.

An AI that agrees with a senior person is worse than no AI at all, because senior people
already have a shortage of honest counsel.

So the advisors here are engineered against it. They hold an assessment under pressure. They
name the weakest assumption rather than the easiest one. And when a plan is sound they say so
plainly, then say exactly what would have to change for it to stop being sound — because an
advisor that manufactures objections is as useless as one that flatters.

There is a standing test suite that re-checks all of this after each model update.

---

## Setup

You need the **Claude desktop app** — download it at
[claude.com/download](https://claude.com/download) — installed and signed in, on **Pro, Max,
Team, or Enterprise**. Cowork is not available on the free plan. Team or Enterprise is
recommended if you handle board material or anything market-sensitive, because on those plans
your inputs are not used for training by default.

Two settings to check first:

- **Settings → Features → code execution** must be on. The commands this installs will not
  work without it. On a work account your IT administrator may control this.
- **On Pro or Max: Settings → Privacy → "Help improve our AI models" — turn it
  off.** Otherwise your chats can be used to train future models, and setup begins with an
  interview about your priorities and your weaknesses. Do it before you start, because the
  setting is not retroactive. On Team or Enterprise it is already off by default.

This runs on the desktop app. The web and mobile apps can pick up a session you started
on your computer, but setup happens here.

**1. Download this folder.**

Go to the [Releases page](../../releases) and download the latest **`2nd-brain.zip`**. Unzip
it.

> ⚠️ **Download `2nd-brain.zip`, not GitHub's "Source code (zip)".** The source archive
> unpacks to a folder with the branch name on the end — `2nd-brain-main` — and that name gets
> written into every command you install. You would be renaming it by hand at step 2 anyway,
> and if you miss it the next update lands beside your work instead of updating it.

> **A word on trust.** The commands this installs can read and write files on your computer.
> That is the point — and it also means installing one is closer to installing software than
> to saving a document. Only run a kit like this from a source you would trust with your
> laptop. If someone sends you a copy from anywhere other than the Releases page above, do
> not run it.

**2. Move it to your Desktop.**

Drag the `2nd-brain` folder to your **Desktop**. Anywhere else in your home folder works,
but the Desktop is recommended — you will see it every day, and being able to open your own
journal in Finder is half the point. Do not leave it in Downloads.

Check the folder is named exactly `2nd-brain`. If it has a version number or a `2` on the
end, rename it now, before setup — that name gets written into your commands.

> Once you have run setup, **do not move or rename this folder.** Its location gets
> written into your commands. If you do move it, re-run setup and they will be rebuilt.

**3. Open Claude and create a project.**

In the Claude desktop app, open Cowork and create a new project.

- **Name:** `Second Brain`
- **Description:** `My executive second brain — journal, decisions, advisors, and reference material.`
- Choose **Use a folder** and select the `2nd-brain` folder you just moved.

**4. Start setup.**

In that project, paste exactly this:

```
Please review the onboarding.md file and guide me through the setup
```

Claude takes it from there — an interview about you and your work, choosing your
advisors, then it builds and installs everything and runs your first journal entry with
you.

---

## Using it

Open the Second Brain project and type any of these:

| Command | What it does |
|---|---|
| `/daily-journal` | A short reflection interview, saved to `journal/daily/` |
| `/weekly-review` | Reads the week's entries, produces an honest review |
| `/monthly-review` | Reads the month's weekly reviews, steps back strategically |
| `/decision-log` | Captures a decision and the reasoning, before hindsight rewrites it |
| `/recall` | Answers questions from what you have written, citing the files |

Plus whichever advisors you chose during setup. You can call one by name, or just
describe the problem and Claude will bring in the right one.

You do not have to use a command at all. The project has your context loaded, so you can
also just start talking — draft the board deck, build the model, think out loud.

---

## On your phone

Start a session on your computer with this project open. Work continues in the cloud even
after you close the laptop, and you can pick up the same session on your phone.

Files created while your computer is off are held in the conversation. To get them onto your
Mac:

1. Open the laptop, with the Claude desktop app running.
2. Reopen **the same conversation** from the Second Brain project's task list. Not a new
   task — your files live in that conversation.
3. Say **"sync it."**

Mobile captures. The desktop commits.

If anything looks stuck, every file Claude made can be downloaded straight from the chat, so
you can always drop it into the folder yourself.

---

## Back it up

This folder lives only on your computer. There is no cloud sync and no automatic backup.
If the laptop dies, your journal dies with it.

Turn on Time Machine, or point whatever backup you already use at this folder. Do it now
rather than later.

---

## What's in here

```
2nd-brain/
├── README.md            this file
├── onboarding.md        the setup script Claude follows
├── VERSION
├── _kit/                templates and command sources — leave this alone
├── CLAUDE.md            created during setup: how Claude works with you
├── goals.md             created during setup: your goals and focus rotation
├── 01_Projects/         live, time-bound initiatives
├── 02_Areas/            ongoing responsibilities
├── 03_Resources/        reference material
├── 04_Archive/          done or inactive
├── decisions/           one file per decision
├── meetings/            one file per meeting
├── people/              briefs on the people who matter
└── journal/             daily, weekly, monthly
```

The four top-level content folders follow **PARA** — organise by how actionable something
is, not by subject. Anything with an end date is a Project. Anything ongoing is an Area.
Everything else is a Resource until it is an Archive.

---

## Updating

Kit files — `README.md`, `onboarding.md`, `VERSION`, and everything in `_kit/` — can be
replaced wholesale from a newer release.

**Everything else is yours and must never be overwritten**: `CLAUDE.md`, `goals.md`, and
all your content folders.

---

## Where this came from

Built by **Kenny Bench at KeytechX** — first for his own use, then for the executives he
trains.

That order is the point. The brief was a system that would say *"that's the wrong call, and
here's the assumption you haven't checked"* — and nothing available did it, because almost
everything in this space is designed to be agreeable. So this one is engineered in the
opposite direction, and the research below is why.

Find Kenny at **[linkedin.com/in/kennethbench](https://www.linkedin.com/in/kennethbench/)** —
for questions, a rollout inside your own team, or the seminar this came from.

---

## The research behind this

This started as a research question rather than a product idea: what does the evidence
actually say about how an executive should use an AI, and how much of it survives a real week?

**Sixty-five sources, eight of them peer-reviewed**, across five streams.

**Whether the idea holds up at all.** Clark & Chalmers' *extended mind* (1998) argued that an
external store you consult reliably becomes part of your cognition — not a filing cabinet,
part of the thinking. That is the intellectual foundation, and it is considerably older and
more serious than the productivity industry built on top of it.

**How to organise it.** Three canonical frameworks, each contributing one thing worth keeping.
**PARA** (Tiago Forte) — file by how actionable something is, not by subject. That is the
single most useful rule in this system and it is why your folders are numbered the way they
are. **Zettelkasten** (Niklas Luhmann) — one idea per note, written in your own words, because
a note that paraphrases someone else captures none of your judgement. **Evergreen notes** (Andy
Matuschak) — a note's title works like an index: *"Organise by actionability, not subject"* is
retrievable; *"Notes 3/14"* is not. The full discipline of the last two is far too heavy for an
executive week, so only the transferable parts were kept.

**Why the load is a real risk rather than a complaint.** A systematic review of 87 studies
(Arnold, Goldschmitt & Rigotti, 2023) found information overload follows an inverted-U — more
information improves decisions up to a point, then degrades them and raises strain — with
around 22% of surveyed workers naming it a primary workplace stressor. That makes a second
brain a structural mitigation, not a productivity tip.

**Whether an AI can actually coach.** A systematic review of 16 studies (*Journal of
Work-Applied Management*, 2025) found AI coaching can match human coaches on specific
structured tasks, while lacking affective empathy and crisis judgement. Complementary to a
human mentor, never a replacement — which is why this kit says so in several places instead of
pretending otherwise.

**And the finding that shaped everything else.** Anthropic's own research, across roughly a
million conversations, found about 9% of personal-guidance exchanges were sycophantic, rising
sharply in some domains. An AI that agrees with a senior person is worse than no AI at all,
because senior people already have a shortage of honest counsel. Every advisor here is
engineered against it deliberately, and there is a standing test suite that checks it still
holds after each model update.

**One working reference implementation informed the architecture.** Garry Tan, President and
CEO of Y Combinator, open-sourced *gstack* — a pack of specialist AI roles built for software
engineering. It is a coding tool and this is not, but the shape transferred: a bench of expert
personas rather than one general assistant, and layered durable memory. The productivity
claims made around it are self-reported, and were treated that way.

---

## What did not survive

Most of it, which is the more useful half of the story.

**Scheduled reminders** were designed in full — daily, weekly, monthly — and then abandoned
outright rather than deferred. A daily nudge is muted inside a fortnight, and an unattended
interview produces a blank form rather than a reflection. You are an adult with a calendar; if
you want a prompt, put it there, where your other commitments already live.

**A retrieval command was nearly cut** on the grounds that four rituals were enough. It went
back in, and it will probably become the thing you use most, because capture without retrieval
is half a second brain.

**Several ideas failed their first live test** on a real machine and were dropped on the spot.

Every one of those was designed in full before it was cut, and the reasoning was written down
rather than quietly forgotten. What you have installed is the residue — the parts that held.

---

## Troubleshooting

**A command does not appear when I type `/`.** Check Customize → Skills first. If it is not
listed, the save did not take — ask Claude to re-deliver it and tap **Save skill** on the
card. If it is listed, type `/` and pick it from the menu rather than typing the whole name.
If it is listed and still does nothing, start a new task in the Second Brain project and try
again there. And remember: pasting the text of a skill into a chat does not install it.

**Claude cannot find my files.** The folder is not connected to this session, or it was
moved after setup. Reconnect it, or re-run setup if the path changed.

**Nothing saved while I was on my phone.** Expected — your computer was asleep. Open the
laptop with the desktop app running, return to the same conversation, and say "sync it." If
Claude says it cannot reach your computer, the connection has dropped rather than the machine
being asleep; opening the desktop app usually restores it. Worst case, download the file from
the chat and drop it into the folder yourself.

---

## Licence

MIT. Use it, fork it, adapt it for your team.
