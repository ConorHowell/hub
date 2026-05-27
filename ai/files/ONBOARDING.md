# Claude Code — Getting Started

## What is Claude Code?

Claude Code is Anthropic's CLI for Claude — a terminal-based AI assistant for software engineering tasks. It reads your project files, runs commands, and edits code directly.

Install: claude.ai/code or via the VS Code extension (search "Claude Code" by Anthropic).

---

## Bot Templates (CLAUDE.md files)

A `CLAUDE.md` file at your project root tells Claude who it is, how to behave, and what the project is. Drop one in and Claude reads it at every session start.

**What to include:**
- Role and persona in this project
- Project structure and key files
- Rules — what to always do, what to never do
- Next Steps — current in-progress work so any bot can pick up immediately

**Two scopes:**
- `~/.claude/CLAUDE.md` — global rules, apply across all projects
- `<project>/CLAUDE.md` — project-specific rules, override globals

---

## Skills (slash commands)

Skills extend Claude Code with slash commands. Install from a skill directory:

```bash
npx skills add <path-to-skill-directory> -a claude-code -y
```

**Start with Caveman** — it cuts token usage ~75% and unlocks the full caveman suite.

### Skills available here

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `/caveman` | "caveman mode", "be brief" | Terse output mode (~75% token reduction) |
| `/caveman-commit` | "write a commit" | Conventional commits generator |
| `/caveman-review` | "review this PR" | One-line PR review comments |
| `/caveman-compress FILE` | "compress memory file" | Compress .md files in-place |
| `/caveman-stats` | — | Real token usage from session log |
| `/caveman-help` | — | Quick skill reference card |
| `/cavecrew` | "delegate to subagent" | Decision guide for subagent delegation |
| `/ship-review` | automatic | Pre-commit diff gate — flags bugs before they ship |
| `/deploy-check <project>` | "audit deploy" | Audits your deploy pipeline — flags, excludes, paths, sensitive files |
| `/security-check <project>` | "security audit" | XSS, CSP, SRI, auth, OWASP Top 10 |
| `/prompt-engineer` | "engineer a prompt" | 5-phase prompt design: intake → draft → adversarial review → output |
| `/persona-builder` | "build a persona" | Expert team assembly for any prompt domain |

---

## Writing Your Own Skill

A skill is two files in `.agents/skills/<name>/`:

**SKILL.md** (the prompt + frontmatter):
```yaml
---
name: my-skill
description: >
  What this skill does and when to activate it. Include trigger phrases here.
---

[Your skill prompt here]
```

**README.md** — short human summary of what it does and how to trigger it.

Register after creating:
```bash
npx skills add ./.agents/skills/<name> -a claude-code -y
```

---

## Pre-ship Review Pattern

A useful pattern: run a skill automatically before committing to catch bugs.

In your deploy or commit script:
```bash
REVIEW=$(echo "$DIFF" | claude --print "$REVIEW_PROMPT")
VERDICT=$(echo "$REVIEW" | head -1 | tr '[:lower:]' '[:upper:]')
[ "$VERDICT" = "APPROVE" ] || read -p "Issues flagged. Ship anyway? (y/N): " CONFIRM
```

The `/ship-review` skill provides a ready-made review prompt for this pattern.

---

## Tips

- `/caveman` at session start reduces context bloat on long sessions
- Prompt Engineer + Persona Builder skills work best for designing prompts for specialized agents
- The `deploy-check` and `security-check` skills work on any project — pass your own project identifier as the argument
