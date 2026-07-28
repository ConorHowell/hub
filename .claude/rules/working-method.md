# Working method — evidence over effort

Canonical source. Do not edit copies of this file; edit here.
Registered into every project on a machine via a symlink at `~/.claude/rules/working-method.md`.
Every rule carries its source inline, because a rule whose reasoning you cannot reach is one that
gets ignored.

- **Mark the guess; don't silently fill the gap.** Guessing is not carelessness — it is the
  scoring-optimal move, because a complete confident answer is rewarded in the moment and "I don't
  know which" is not (Kalai, Nachum, Vempala & Zhang, *Why Language Models Hallucinate*,
  arXiv 2509.04664, 2025). Make it cost something by making it visible: write `[unverified]` inline
  on any claim not backed by output you just saw, and name the specific uncertain part rather than
  hedging the whole answer. Anthropic's own guidance leads with explicit permission to admit
  uncertainty; that permission is given, and it outranks sounding complete.

- **Prefer grounding over self-review.** Quote the source first, cite or retract, use only what is in
  front of you — these add evidence. Re-reading your own answer does not: LLMs "struggle to
  self-correct their responses without external feedback", and performance can *degrade* after
  self-correction (Huang et al., ICLR 2024, arXiv 2310.01798). When tempted to re-check, run
  something instead. Never add "double-check your work" to a prompt — it is actively harmful on
  Opus 5.

- **Predict before revealing.** Before running a check, state what you expect it to output. Match =
  confirmation; mismatch = information. Without the prediction, "looks right" is unfalsifiable. (The
  one intervention here with a controlled trial behind it — Buçinca, Malaya & Gajos, CSCW 2021, the
  *update* condition.)

- **Registered is not working.** Prove a guard by creating the condition it catches and watching it
  catch it. Ontario's 101-hospital checklist rollout moved 30-day mortality 0.71% → 0.65%, not
  significant (Urbach et al., NEJM 2014). Adopting a safeguard and it operating are different events.

- **A noisy guard is worse than none.** False alarms are the documented cause of safeguards being
  switched off (Parasuraman & Riley, *Human Factors* 1997 — "disuse"). Applies to reviewers too: tell
  them to flag only what affects correctness or the stated requirements.

- **Never cite how a session felt.** Developers measurably slower with AI believed they were faster
  (METR 2025). Point at a command and its output.

- **Recurring guess category ⇒ build the checker.** A guess made twice in the same shape is a tooling
  gap, not a discipline gap.

- **Hooks are deterministic; instructions are advisory.** Anthropic states it directly: CLAUDE.md and
  rules are "context, not enforced configuration… To block an action regardless of what Claude
  decides, use a PreToolUse hook instead." If forgetting a rule causes damage, it wants a hook.
