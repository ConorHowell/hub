# Bot Operating Rules — [Project Name]

> Hard rules for agents working on this project.
> Read alongside `.claude/CLAUDE.md` and `_SYSTEM/CONTEXT.md`.
> Rules marked HARD RULE have zero tolerance for exceptions.

---

## Before Any Task

- Read `_SYSTEM/CONTEXT.md` + `_SYSTEM/NEXT_STEPS.txt` before starting.
- Non-trivial task: enter Plan Mode (Shift+Tab) before writing code.
- Check `docs/progress.md` for in-flight work from the previous session.

---

## Worktree Safety Protocol

> **HARD RULE: Before merging any agent result, run `git diff main..HEAD --stat` inside the worktree. Unexpected deletions of existing source files = agent worked on stale base. Do not merge — rebase first.**

### Known Failure Modes

**A — Stale base:** Worktree branches from an older commit. Symptom: `git log --oneline -3` in worktree tops out before recent commits. Check `git diff main..HEAD --stat` for unexpected `-` lines on source files.

**B — Out-of-lane edits:** Agent modifies files outside its assigned scope. Reject those changes before merging.

**C — Uncommitted changes:** Agent leaves work unstaged — `git diff main..HEAD` looks clean but `git diff HEAD` shows modifications. Always check both.

**D — Duplicate declarations:** Stale base + symbol already committed on main → duplicate `const`. Causes runtime crash. Check with `node --check <file>` for JS projects.

### Recovery Steps

1. `git log --oneline -3` in worktree — confirm base commit
2. `git diff HEAD` — commit any uncommitted work first
3. `git rebase main` — resolve conflicts (keep both when in doubt)
4. Run project-specific syntax check on all modified files
5. `git merge --no-commit --no-ff <branch>` → inspect staged diff → commit

---

## Agent Reporting Protocol

> **HARD RULE: Every worktree agent MUST end its final message with a Shipping Status block.**

```
## Shipping Status
- Committed: yes | no — <commit hash or "none">
- Pushed to GitHub: yes | no
- Deployed to server: yes | no
- publish.sh used: yes | no
```

"Done" or a summary table without this block is not sufficient. Main session reads this to decide next action.

---

## Deploy Ownership

> **HARD RULE: Worktree agents do NOT deploy to the server.**

**Agent responsibility:** edit files → commit → push → stop.

**Main session responsibility:** read Shipping Status block → if "Deployed: no" → run `./publish.sh <project> "message"`.

Rationale: only the main session has full context of what was shipped. Agent-initiated deploys cause double-deploys and bypass the ship-review gate.

---

## Session Hygiene

- `/compact` around 60% context — don't wait for auto-compact.
- `/clear` when switching to an unrelated task.
- Never paste raw logs into the main thread — subagent or summarize first.

---

## End of Session

- Overwrite `docs/progress.md` with current state.
- Update `_SYSTEM/CONTEXT.md` in-place if architecture or state changed (bump version).
- Update `_SYSTEM/NEXT_STEPS.txt` with completed + remaining tasks.
- Run `git worktree prune`.

---

## Self-Cleanup

> **HARD RULE: Leave the repo cleaner than you found it.**

- `git worktree prune` before closing.
- Delete all `/tmp` files created this session.
- Never leave uncommitted changes in a worktree branch — commit + push or discard.
- Leftover worktrees slow future bots and pollute `git worktree list`.
