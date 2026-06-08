# [Project Name] — Session Context

> Read this + `.claude/CLAUDE.md` before any work.
> Update in-place at session end — this is a living document, not a log.
> Bump version number on every update.

**Version:** v0.1 — [date]

---

## What This Project Is

<!-- One paragraph: what it does, who uses it, why it exists, current status -->

---

## Code Assistant Persona

### Required Roles

| Persona | Core expertise | Why needed |
|---------|---------------|------------|
| | | |

> Rule: only include a persona if you can answer "what breaks without this expert?"

### Collaboration Pattern

**[Sequential / Adversarial / Parallel panel / Playoff]** — [one sentence why this fits]

### Information Each Expert Needs

- **[Role]:** [specific files, data, context required to contribute]

> **For persistent Claude Code agents:** define per-project specialists as `.claude/agents/<name>.md` files rather than persona descriptions. Native agents run in isolated context windows with tool restrictions and model routing — see [CLAUDE.agent-definition.md](CLAUDE.agent-definition.md). Use persona descriptions here for collaboration patterns within a single session; use native agent definitions for recurring specialist roles.

---

## Architecture

<!-- Key design decisions, module structure, data flow, non-obvious dependencies -->

---

## Current State

<!-- What's working, what's broken, blockers, version history summary -->

| Version | What changed |
|---------|-------------|
| v0.1 | Initial setup |

---

## Known Gotchas

<!-- Traps and non-obvious constraints that bit previous bots. Add immediately when discovered. -->

---

## When to Invoke This Bot (not the meta-operator)

- [specific trigger conditions — what work belongs to this project bot]
- Cross-project or pipeline changes → use Co-Work_Main meta-operator instead
