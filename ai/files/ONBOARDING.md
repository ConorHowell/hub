# Claude Code — Getting Started

## What is Claude Code?

Claude Code is Anthropic's CLI for Claude — a terminal-based AI assistant for software engineering tasks. It reads your project files, runs commands, and edits code directly.

Install: claude.ai/code or via the VS Code extension (search "Claude Code" by Anthropic).

---

## Zero to Equipped Bot — Quickstart

Ideal order for a new machine or new project:

**1. Install Claude Code**
VS Code: Extensions → search "Claude Code" by Anthropic
CLI: see claude.ai/code

**2. Set global rules** — `~/.claude/CLAUDE.md`
Download a template from this hub. Drop it at `~/.claude/CLAUDE.md`.
Global rules apply to every project. Put session-start behavior and safety rules here.

**3. Install Caveman first** (token savings from session 1)
```bash
npx skills add <path-to-caveman-skill-dir> -a claude-code -y
```
Skills install globally into `~/.claude/` — run once, active in all projects and sessions.

**4. Install remaining skills**
```bash
npx skills add <path-to-skill-dir> -a claude-code -y
# Repeat for each skill, or use a setup.sh loop
```

**5. Add a project CLAUDE.md**
Drop `CLAUDE.md` at your project root. Use a template from this hub.
Project rules override global rules.

**6. Design specialized prompts** with `/prompt-engineer`
For any specialized agent role — invoke and answer the 6 intake questions.

**7. Verify everything works**
Start a Claude Code session. Type `/caveman` — terse response confirms skills loaded.
Installed skills appear in the session context at session start.

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

Skills extend Claude Code with slash commands. They install **globally** — run the install command once from anywhere, and the skill is available in every project and session.

```bash
npx skills add <path-to-skill-directory> -a claude-code -y
```

`-a claude-code` targets the Claude Code app. `-y` skips confirmation. The skill is written to `~/.claude/` — not to the current project.

**Verify a skill installed:** start a session, run the trigger (e.g. `/caveman`). If it responds, it's active. Installed skills also appear listed in the session startup context.

**Common failure:** directory passed to `npx skills add` must contain a `SKILL.md` with valid frontmatter (`name:` and `description:` fields). Missing file or malformed frontmatter = silent failure.

**Start with Caveman** — cuts token usage ~75% and unlocks the full caveman suite.

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

## Subagent / Worktree Safety Rules

When using agents that spawn git worktrees, follow these rules to prevent silent failures:

**Use absolute paths with `-C` — never `cd`:**
```bash
# CORRECT — no CWD drift between bash calls
git -C /absolute/path/to/repo status
git -C /absolute/path/to/repo log --oneline -3

# WRONG — cd persists across bash calls, later git commands run against wrong repo
cd /some/path && git status
```

**Identify all git repos before delegating.** Subdirectories can have their own `.git`. Check:
```bash
ls <subdir>/.git  # exists = separate repo
```
Tell the agent explicitly which git repo each file belongs to when multiple repos exist in the tree.

**Worktree agents commit to a temp branch, not main.** After the agent finishes, merge explicitly:
```bash
git -C /abs/path log --oneline worktree-branch -3  # verify commit is there
git -C /abs/path merge worktree-branch --ff-only    # fast-forward into main
git -C /abs/path log --oneline -3                   # confirm main now has it
ls /abs/path/new-file                               # verify file is on disk
```

**Never assume "already up to date" means success** — it may mean the merge command ran against the wrong directory.

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
- Prompt Engineer + Persona Builder work best for designing prompts for specialized agents
- The `deploy-check` and `security-check` skills work on any project — pass your own project identifier as the argument
- Skills install globally — you only need to install them once per machine, not per project
