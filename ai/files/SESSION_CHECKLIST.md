# Session Checklist

## New Project (One-Time Setup)
- [ ] Fill all `[Project Name]` placeholders in `CLAUDE.md`, `_SYSTEM/CONTEXT.md`, `_SYSTEM/BOT_RULES.md`
- [ ] Add deploy slug + live URL to `CLAUDE.md` Quick Start
- [ ] Populate Key Files table
- [ ] Delete placeholder comment lines when sections are filled
- [ ] Run `/init` to verify Claude Code picks up CLAUDE.md
- [ ] `git init` in your hub/workspace directory (enables worktrees for future sessions)

## Session Start
- [ ] Read `docs/progress.md` — in-flight state and task queue from previous session
- [ ] Non-trivial task → Shift+Tab (Plan Mode) before writing code
- [ ] State task clearly so context loads correctly

## During Session
- [ ] Drifting responses? `/context` — check token bloat
- [ ] Switching tasks? `/clear` — reset frame
- [ ] Wrong direction? `/rewind` (or double-tap Esc) — rolls back both code and conversation to a checkpoint. Checkpoints are taken after plan approval and around code review.
- [ ] Complex decision? Ask: alternatives + edge cases
- [ ] UI work: paste screenshot, not description
- [ ] Frontend bug: paste DevTools console error directly
- [ ] Context ~60% full? `/compact` now — don't wait for auto-compact. `/context` shows context usage, `/usage` shows cost.

## End of Session
- [ ] Overwrite `docs/progress.md` with active state (task, changed files, blockers, next action, completed + remaining tasks)
- [ ] Update `_SYSTEM/CONTEXT.md` in-place if architecture/state changed (bump version)
- [ ] New pattern or gotcha discovered? Add to `_SYSTEM/CONTEXT.md` Known Gotchas
- [ ] Run `git worktree prune`
- [ ] Delete any `/tmp` files created this session
- [ ] `/compact` before closing — next session starts lean
