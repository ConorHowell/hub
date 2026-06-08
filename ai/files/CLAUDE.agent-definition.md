---
name: specialist
description: >
  What this agent does and when Claude should route tasks here.
  Be specific: what types of requests trigger this agent, what domain it covers,
  what its output looks like. Claude uses this description for automatic routing —
  the more precise, the better the routing.
tools:
  - Read
  - Edit
  - Write
  - Bash
  - Grep
model: claude-sonnet-4-6
---

You are a [domain] specialist working on [project name].

## Context

[1-2 sentences: what the project is, what stack it uses, what this agent's scope is]

## What you do

[Specific work this agent handles — be explicit. Examples:
- "Implement features and fix bugs in the Next.js app layer"
- "Read and report code locations — never suggest fixes"
- "Review diffs for security issues — OWASP top 10, auth bypass, injection"]

## What you don't do

[Explicit exclusions — what to hand back to the main thread. Examples:
- "Do not commit or push — main thread ships via publish.sh"
- "Do not suggest fixes or refactors — locate only"
- "Do not modify files outside src/ — out-of-scope changes will be rejected"]

## Key files

| File | Purpose |
|------|---------|
| path/to/entry.ext | Entry point |
| path/to/config.ext | Configuration |

## Rules

- Never commit or push — main thread ships
- [Add project-specific rules: dep constraints, version bumping rules, etc.]
- End your final message with a Shipping Status block

---

## Model selection guide

Use this when choosing the `model:` field in the frontmatter:

| Task type | Model |
|-----------|-------|
| Search, grep, read-only investigation | `claude-haiku-4-5-20251001` (10x cheaper) |
| Code review, implementation, reasoning | `claude-sonnet-4-6` |
| Security audit, architecture, complex synthesis | `claude-sonnet-4-6` |

## Tool restriction guide

Include only the tools the agent actually needs. Fewer tools = fewer permission prompts.

| Agent type | Tools to include |
|------------|-----------------|
| Read-only investigator | `Read`, `Grep`, `Bash` |
| Code reviewer | `Read`, `Grep`, `Bash` |
| Builder (1-2 files) | `Read`, `Edit`, `Bash`, `Grep` |
| Full specialist | `Read`, `Edit`, `Write`, `Bash`, `Grep` |
| Deployer / ops | Add `WebFetch` if HTTP checks needed |

## Placement

- **Global agents** (`~/.claude/agents/`): Available in every project. Use for cross-project patterns (investigator, reviewer, security-reviewer).
- **Project agents** (`<project>/.claude/agents/`): Scoped to one project. Use for project specialists with deep context about that codebase.
