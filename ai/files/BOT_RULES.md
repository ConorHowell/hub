# Bot Operating Rules — [Project Name]

> Hard rules for agents working on this project.
> Read alongside `.claude/CLAUDE.md` and `_SYSTEM/CONTEXT.md`.
> Rules marked HARD RULE have zero tolerance for exceptions.

---

## Before Any Task

- Read `_SYSTEM/CONTEXT.md` before starting.
- Non-trivial task: enter Plan Mode (Shift+Tab) before writing code.
- Check `docs/progress.md` for in-flight work from the previous session.

---

## Worktree Safety Protocol

> **HARD RULE: before spawning a worktree agent, `git rev-list --count origin/main..main` must print `0`.** Worktree agents branch from `origin/main` — the last *pushed* commit — not local `HEAD`. Unpushed commits mean the agent starts on a stale base and its diff reads as deletions of your own work.

> **HARD RULE: before merging any agent result, run `git diff main..<branch> --stat`.** Unexpected deletions of existing source files = stale base. Do not merge — rebase first.

Full choreography, the four known failure modes, and the recovery sequence: **`workflow/` on the AI hub**.

---

## Agent Reporting Protocol

> **HARD RULE: every worktree agent MUST end its final message with a Shipping Status block.** "Done", or a summary table without the block, is not sufficient — the main session reads the block to decide the next action. Format: `workflow/` on the AI hub.

---

## Deploy Ownership

> **HARD RULE: worktree agents do NOT deploy.**

**Agent:** edit files → list what changed → stop. Does not commit, push, or deploy.
**Main session:** read the Shipping Status block → review the diff → commit, push, run the deploy script.

Rationale: only the main session knows the full set of what is shipping, and agent-initiated deploys bypass the pre-ship review gate.

---

## Session Hygiene

- `/clear` when switching to an unrelated task.
- `/compact` only when one long task actually overflows the window — see `EFFICIENCY.md`.
- Never paste raw logs into the main thread — subagent or summarize first.

---

## End of Session

- Overwrite `docs/progress.md` with current state.
- Update `_SYSTEM/CONTEXT.md` in-place if architecture or state changed (bump version).
- Record completed + remaining tasks in `docs/progress.md`.
- Run `git worktree prune`.

---

## Self-Cleanup

> **HARD RULE: Leave the repo cleaner than you found it.**

- `git worktree prune` before closing.
- Delete all `/tmp` files created this session.
- Never leave a worktree branch with uncommitted changes — merge it or discard it before closing.
- Leftover worktrees slow future bots and pollute `git worktree list`.
