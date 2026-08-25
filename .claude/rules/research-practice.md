# Research practice — verifying claims about anything

Canonical source. Do not edit copies; edit here.
Registered into every project on a machine via a symlink at `~/.claude/rules/research-practice.md`.

Companion to `working-method.md`, which covers how to work. This covers how to know. Both were
extracted from real failures — every rule below names the case that forced it, because a rule whose
reasoning you cannot reach is one that gets ignored. Built on a psychology knowledge base;
**re-verified on an unrelated subject** (Claude Code tooling) and it transferred unchanged.

Full detail, with worked cases: `Study Helper/method/research/METHOD.md` (what a claim must satisfy)
and `RESEARCH_PROCESS.md` (how to run the process). Read those before doing research work; this file
is the part worth carrying into every session.

**To actually run the gate on one claim, use `/verify-claim`** — it returns
`VERIFIED` / `UNCHECKED` / `BROKEN` with the fetch, the matched quote, and the retraction status.
Reading this file makes you careful; the skill makes you check.

## The failure order — most frequent first, not most theoretical

- **The source is real, live, open, on-topic — and does not contain the claim.** The single most
  common content failure; at least four separate incidents. A review cited for an experiment that
  appears only in its *reference list*. A paper cited for a definition its own text **rejects**. A
  "second independent record" that was a bibliographic stub with no abstract. No link-checking
  catches any of it. **"Verified 200" is not verification** — fetch the text and search it for the
  specific assertion.

- **HTTP 200 means almost nothing.** Five distinct incidents, several nearly shipped. Publisher
  login wall (200 with `-L`; curl **without** `-L` and watch for 30x → `idp.*`/`authorize`/`login`).
  Bot-challenge shell (200, tiny body — a 200-byte "PDF" is a challenge page). Landing page vs full
  text. Wrong identifier — 200, a perfectly real paper, the wrong one. A `/pdf/` path segment proves
  nothing. **Verify the identity of what you fetched from its own body, never from the URL string.**

- **Retracted and corrected papers pass every other check.** A retraction returns 200, reads
  normally, matches its own abstract. A *correction* is worse: superseded numbers stay printed in
  the original PDF forever, so quoting them looks perfectly verified. Both bit us — Szucs &
  Ioannidis's headline power figures had been revised by a 2021 correction we had been quoting
  around. Check Crossref `updated-by` / PubMed `CommentsCorrectionsList`. **If a correction exists,
  quote the corrected figures and say so.**

- **Search snippets fabricate specifics, and model memory is never a citation.** Snippets carried a
  garbled effect size and a widely-circulated statistic that three full-text searches confirmed does
  not appear in the paper at all — it exists only in press coverage. Snippets find candidates; they
  never source them. A published *abstract* is part of the paper (narrow exception, conditions in
  METHOD.md); a press write-up about it is not.

- **Your own errors are in the same taxonomy.** In one session I fabricated author names by
  inferring them from context instead of reading the byline, and guessed an identifier that resolved
  to an unrelated paper. Both caught by the rule that catches subagents: *fetch the thing and read
  it.* Apply the process to yourself; do not trust yourself differently.

## Independence, not layer count

Gather (told explicitly **not** to self-review — the context that produced an error will rationalise
it) → **adversarial fresh-context review that is told to break it** → main-thread spot-check.

The middle layer is the highest-yield step in the process. The third is not redundant, and that was
the surprise: it sees *across* entries and *across* the ruleset, so it catches "these two claim a
tier their evidence cannot support" where the reviewer, asking only "is this defensible?", filed
tier errors as housekeeping. **Short on budget? Cut the batch scope, never the adversarial pass.**
One unit verified three ways beats three units verified once.

A delegated summary is not verification — "all URLs verified 200" is a *claim*. The one time a
report asserted a "second independent record," it did not exist. Spot-check enough to calibrate.
And when a background agent dies mid-run, never assume its work is done *or* undone: it is the most
dangerous state there is. Inspect the file, re-verify anything it touched.

## Three verdicts, never two

`PASS / FAIL / UNCHECKED`, plus `N/A` where the check is a category error (a dictionary cannot be
retracted). A two-state checker forces a lie whenever it was blocked: it invents a pass or condemns
a live source. Both happened in the first hour. **UNCHECKED is not a pass** — it means nobody
cleared it, and the pressure to read it as "fine" is constant.

**Count the unknown.** The standing status was "51 entries, all links live" — true, and it concealed
that 41 of 51 had never been checked for retraction *at all*. Not failed: never checked. Ask what a
green check does **not** cover before trusting it, and ask which check would have to *fire* to catch
a given failure and whether anything disables it. A missing quote silently disabled the only
text-aware check, so the entries most likely to be rotting were exactly the ones nothing read.

**A new guard's failure mode is silence, not noise.** A guard that over-fires announces itself; a
guard that never fires looks exactly like a clean corpus. Ours measured a content-free page as
content-rich because `len()` counted interior whitespace, and the fixture passed. Only a fixture
with a verdict known *in advance* distinguished them. Test the verifier before trusting the
verification: on the first full sweep, all three FAILs were bugs in the tool.

**Name the failure you are afraid of, then check the assertion would fire on it.** A scripted field
split asserted losslessness, passed on all 52 entries, and produced incoherent prose — it checked
that no characters vanished, never that the remaining text still parsed. "Nothing was lost" was
never the fear; "the result is incoherent" was.

## Restraint, disclosure, and what a record can support

- **Record negative results — they are cheap and they compound.** "This figure appears nowhere in
  the paper, N searches, zero hits." "No open full text; these five routes, these status codes."
  Three separate agents independently hunted the same phantom statistic before it was written down.
  Log rejections *with reasons*, so a later rebuild can be confirmed as a real fix.
- **Restraint beats coverage.** Keeping a "well-established" list at three items and marking the
  rest "standing unknown" was right; padding it would not have been. A documented gap is a fine
  outcome — **a stretched citation poisons everything around it.** State scope limits explicitly:
  most misquoted statistics are misquoted by dropping the scope, not by changing the number.
- **A fact about a record never asserts a claim about the world it counts.** Verified-real GitHub
  star counts (caveman 93k, gstack 124k) measure bookmarking, not use. Citation counts say nothing
  about whether a claim is true. Verifying the record ≠ verifying the claim.
- **Evaluative claims have no truth-type — quarantine them.** "Is X worth using?" is judgment.
  Publish only as clearly-labelled assessment grounded in verified facts, never formatted as, or
  laundered from, a verified fact or a popularity number.
- **Represent contestation; don't resolve it by omission.** Twice we found evidence against our own
  established position and published it. Credibility depends on doing that especially when the
  convenient direction is the one you already committed to.
- **Write the verification trail into the artifact** — but ask *who reads a field* before deciding
  what goes in it. Ours ran to 132k characters with 38 of 52 entries carrying HTTP codes and byte
  counts into text rendered under "How do we know this?". "Record the trail" and "show the trail"
  are different requirements with different audiences; collapsing them let the plumbing win.

## Codify from real cases, and hold your own house to it

Rules written speculatively are vacuous or wrong; rules extracted from a failure are precise and
arrive with the worked example. **When something doesn't fit the model, that is information about
the model** — twice the correct move was to amend the framework, not bend the entry.

**A doc's location confers no verification.** A file sat in our own ruleset directory for weeks
telling us to use two slash commands that **do not exist**. It slipped every guard because guards
were scoped to research *output* and this was infrastructure, on a subject we felt fluent in —
**fluency is exactly when you stop citing.** Hold the ruleset to the standard the content is held to.

**No pass detects an absence.** The same rewrite revealed the file had omitted `/rewind` — we had
been operating without knowing undo existed. Errors are findable by testing; omissions are not.
Periodically **enumerate the authoritative surface** and diff it against what you use. Turned
inward: enumerate your own available tools before declaring work blocked. Nine items were reported
as needing a human because `curl` was refused; the browser had been in the session the whole time
and all nine resolved in minutes. **"Blocked" is a claim.**

## Teaching a correction without planting the misconception

Domain-general and easy to get wrong: state a misconception then say "false," and students later
remember the misconception as true. The prompt never asserts it; the answer opens *and closes* on
the correct state with the misconception named only mid-text; the follow-up never restates it.
**Always pair debunking with a genuinely strong "here is what has held up and why we can say so"** —
a unit that only teaches "famous things are wrong" produces cynicism, not skill. The goal is
calibrated skepticism, someone who asks *how do we know this?*, not someone who writes the field off.
