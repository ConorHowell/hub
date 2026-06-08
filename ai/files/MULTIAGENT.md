# Multiagent Workflow — Decision Guide

Reference for Claude Code sessions. Use the simplest level that works. Higher = more cost.

---

## The Complexity Ladder

| Level | Use when | Tools |
|-------|----------|-------|
| 1. Main thread | Single known-path read, quick answer, coordinating subagents | inline |
| 2. Skills | Repeatable workflows, slash commands | `/caveman`, `/ship-review`, `/prompt-engineer` |
| 3. Cavecrew | Locate code, 1-2 file edits, diff review | `cavecrew-investigator`, `cavecrew-builder`, `cavecrew-reviewer` |
| 4. Worktree agents | 3+ file edits, new features, cross-cutting refactors | `general-purpose` (worktree isolation) |
| 5. Dynamic workflows | 5+ independent parallel tasks, each discrete | `/workflows` |

**Rule:** Default to level 3 (cavecrew) for any task touching >1 file. Only go higher when scope demands it.

---

## Native Subagent Definitions (`.claude/agents/`)

Claude Code supports reusable subagent blueprints stored as `.claude/agents/<name>.md` files. These differ from skills (slash commands) in three key ways:

| | Skills (`.agents/skills/`) | Native agents (`.claude/agents/`) |
|---|---|---|
| Invoked by | Slash command | Claude delegates automatically OR by name |
| Runs in | Main context | Isolated context window |
| Tool restriction | No | Yes — per-agent allowlist |
| Model control | No | Yes — route cheap tasks to Haiku |
| Context impact | Floods main thread | Output stays isolated |

### How to define an agent

```markdown
---
name: investigator
description: When to use this agent — Claude reads this to decide when to route tasks here.
tools:
  - Read
  - Grep
  - Bash
model: claude-haiku-4-5-20251001
---

Agent system prompt goes here.
```

### Model routing guide

| Task type | Model |
|-----------|-------|
| Search, grep, read-only investigation | `claude-haiku-4-5-20251001` |
| Code review, implementation, reasoning | `claude-sonnet-4-6` |
| Security review, architecture, complex synthesis | `claude-sonnet-4-6` |

### Recommended agent types

| Agent | Scope | Tools | Model |
|-------|-------|-------|-------|
| `investigator` | Read-only code location | Read, Grep, Bash | Haiku |
| `reviewer` | Adversarial diff review | Read, Grep, Bash | Sonnet |
| `security-reviewer` | OWASP / auth / access control | Read, Grep, Bash | Sonnet |
| `<project>-specialist` | Project-specific context + build | Read, Edit, Write, Bash, Grep | Sonnet |

Place global agents in `.claude/agents/`. Place project-specific agents in `<ProjectDir>/.claude/agents/`.

---

## Level Decision Triggers

**→ cavecrew-investigator** (never inline grep):
- "where is X defined / what calls Y / list uses of Z"
- any search touching more than one file
- context is already mid-session or heavy

**→ cavecrew-builder** (never inline edit when scope is clear):
- ≤2 files, exact path already known
- mechanical change: rename, config tweak, single function rewrite

**→ cavecrew-reviewer** (never inline review):
- reviewing any diff before ship
- auditing a file for bugs or issues

**→ general-purpose worktree** (not cavecrew):
- 3+ files
- new feature or new file
- cross-file refactor

**→ dynamic workflow** (not worktree):
- task splits into 5+ independent, non-overlapping pieces
- all pieces can run truly in parallel with no shared state
- explicit user ask: "set up a dynamic workflow to..."

**→ never dynamic workflow**:
- sequential work (use `/goal` loop instead)
- anything you're not sure decomposes cleanly
- cost matters more than speed on this task

---

## Dynamic Workflow Invocation

**Trigger phrase** (say this to Claude to initiate):
```
Set me up a dynamic workflow to [task description]
```

**Check active or historical workflows:**
```
/workflows
```

**Save location:** Claude defaults to a system directory. Always specify your project folder explicitly:
```
Save the workflow file to /path/to/project/workflows/
```

**vs `/goal`:**
| `/goal` | Dynamic workflow |
|---------|-----------------|
| Depth — loops until done-criteria met | Width — many agents run once in parallel |
| Single agent, multiple passes | Many agents, each handles one piece |
| Use for: iterative refinement, retry until passing | Use for: parallel independent subtasks |

**UltraCode warning:** UltraCode mode defaults to dynamic workflows silently. It also uses Extra High effort reasoning and may bypass manual permission checks. Do not enable UltraCode unless you explicitly want workflow-first behavior.

**Cost reality:** Dynamic workflows are the most expensive pattern. One poorly-scoped workflow session can consume half a monthly API budget. Confirm with user before initiating.

---

## Token-Saving Rules

Apply these at every level.

### CLAUDE.md files
- Keep under 2k tokens. Pointers to skill files, not content.
- No code examples inline — reference file paths instead.
- `.claudeignore`: exclude `node_modules/`, `.next/`, `dist/`, `build/`, `*.lock`

### Prompts
- Always include: file path, line number, function name, exact symptom
- Never include: conversational framing, background the agent already has, vague task descriptions
- Group related questions into one message — each round-trip costs a full context read

### Context management
- `/compact` after any exploration phase — before you start building
- `/clear` when switching to an unrelated task
- `/effort low` for mechanical tasks (renaming, formatting, comment removal)
- `/context` to audit what's eating your window if sessions feel heavy

### Subagents
- Any task producing more than one screenful of output → subagent (keeps verbose output out of main context)
- Cavecrew output is ~60% smaller than vanilla Explore — prefer it for all locate/build/review tasks
- Parallel cavecrew calls in one message: 2-3 investigator agents on different angles simultaneously

### Cache
- Prompt cache TTL: 5 minutes. Work in focused bursts — don't let a session go idle then resume
- Don't restart a session mid-task unless you compact first

### Session memory
- End of session: write checkpoint to `docs/progress.md`
- Start of session: load `@CLAUDE.md` + `@docs/progress.md` only — nothing else until needed
- Mid-session: `/compact` every ~40 messages or after any large exploration

---

## Token Budget Awareness

An agent picking up a workflow should check context pressure and adapt:

**Light (early session):**
- Single known-path file reads OK inline
- Everything else → cavecrew or subagent

**Heavy (mid/late session):**
- `/compact` immediately after any exploration phase
- All reads → subagent
- Prefer `cavecrew-builder` over inline edits (smaller tool results)
- Finish current atomic task cleanly; don't start the next one

**Near limit:**
- `/compact` now, before anything else
- Complete only the current atomic task
- Write checkpoint to `docs/progress.md`
- Surface to user — don't attempt another task

---

## Worktree Recovery

> Run this check before trusting any worktree agent result: `git diff main..HEAD --stat`. Unexpected `-` lines on source files = agent worked on stale base. Do not merge.

### Failure Modes

**A — Stale base:** Worktree branched from an older commit. Check: `git log --oneline -3` in worktree tops out before recent commits on main. Fix: rebase before merging.

**B — Out-of-lane edits:** Agent modified files outside its assigned scope. Fix: cherry-pick only the intended files, reject the rest.

**C — Uncommitted changes:** `git diff main..HEAD` looks clean but `git diff HEAD` shows modifications — agent left work unstaged. Fix: commit the unstaged work first.

**D — Duplicate declarations:** Stale base + symbol already committed on main → duplicate `const`/`function`. Causes runtime crash. Fix: run `node --check <file>` (or language equivalent) on all modified files before merging.

### Recovery Steps

```bash
git log --oneline -3          # 1. Confirm base commit
git diff HEAD                 # 2. Find any uncommitted work — commit it
git rebase main               # 3. Rebase onto main, resolve conflicts
# 4. Run syntax check on modified files (node --check, python -m py_compile, etc.)
git merge --no-commit --no-ff <branch>   # 5. Inspect staged diff before committing
git diff --cached             # 6. Final review — then commit
```

### Agent Reporting Protocol

Every worktree agent must end with a **Shipping Status block** — main thread reads this to decide next action:

```
## Shipping Status
- Committed: yes | no — <hash or "none">
- Pushed to GitHub: yes | no
- Deployed to server: yes | no
- publish.sh used: yes | no
```

**Deploy ownership:** agents commit + push only. Main thread runs `./publish.sh` — never the agent. Agents deploying independently bypass the ship-review gate and can cause double-deploys.

---

## Chaining Patterns

**Locate → fix → verify** (most common):
1. `cavecrew-investigator` returns site list
2. Main thread picks 1-2 sites → `cavecrew-builder`
3. `cavecrew-reviewer` audits the diff

**Parallel scout** (broad investigation):
Spawn 2-3 `cavecrew-investigator` calls in one message (defs vs callers vs tests). Aggregate in main thread.

**Single-shot edit** (path already known):
Skip investigator. Hand `path:line` directly to `cavecrew-builder`.

**Plan → build → ship**:
1. Main thread plans (or `/prompt-engineer` for complex prompts)
2. `general-purpose` worktree agent builds
3. `cavecrew-reviewer` reviews diff
4. `./publish.sh <project> "message"` ships


---

## Agent Teams

Agent Teams allow multiple subagents to work in parallel with shared coordination. Enable with:

```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```
in `.claude/settings.json`.

### When to use

| Pattern | When |
|---------|------|
| **Parallel review** | 3 reviewers (security, performance, tests) audit the same diff simultaneously |
| **Competing hypotheses** | Multiple agents test different bug theories independently |
| **Cross-layer feature** | Frontend agent + backend agent + test-writer agent work in parallel |
| **Worktree agent** | One domain, sequential work — use this instead |

**Decision rule:** Use agent teams when work has ≥2 independent domains that benefit from cross-agent communication. Use worktree agents when work is sequential or touches only one domain.

### Parallel review pattern (most common)

Spawn 3 reviewer subagents in one message, each with a different lens:

1. **Security reviewer** — OWASP, auth, injection
2. **Logic reviewer** — correctness, edge cases, regression risk
3. **Test reviewer** — test coverage gaps, assertions that could fail silently

Aggregate findings in main thread before shipping.

### Cost reality

Agent teams multiply token usage. A 3-agent parallel review costs ~3x a single review. Use when the risk of a missed bug exceeds the cost. Skip for low-risk mechanical changes.

---

## Managed Agents API (building AI products)

For applications built with the Anthropic SDK — not for Claude Code sessions.

**Architecture:**
- Coordinator (Opus) orchestrates; specialist agents (Sonnet/Haiku) execute
- Shared filesystem + vault credentials; isolated context per thread
- Max: 25 concurrent threads, 20 agents in roster

**Model routing:**
- Planning, architecture, synthesis → Opus
- Execution, edits, tool calls → Sonnet
- Simple lookups, search, classification → Haiku

**Patterns:**
- **Parallelization:** fan out independent subtasks, coordinator synthesizes
- **Specialization:** domain-scoped agents (security, docs, test-writer) with only needed tools
- **Escalation:** route hard subtasks to a more capable model mid-session

**MCP scoping:** Each agent declares only the servers it needs. Session-level `vault_ids` supply credentials to all threads automatically. Tool permission events bubble up to the primary thread — handle them there.

**Thread management:** Archive idle threads when done to free against the 25-thread limit. Interrupt before archiving if thread isn't idle.

---

## Quick Reference

```
Task type                     → Level
─────────────────────────────────────
Single known file              → inline
Find where X is defined        → investigator agent
Find code (multi-file)         → investigator agent
Fix 1-2 files (path known)    → cavecrew-builder
Review a diff (fresh context)  → reviewer agent
Security audit                 → security-reviewer agent
Project-specific build         → <project>-specialist agent
3+ file feature/refactor       → worktree agent
5+ parallel independent tasks  → dynamic workflow
Design a prompt                → /prompt-engineer
Pre-ship review                → /ship-review
Build an AI product            → Managed Agents API
```
