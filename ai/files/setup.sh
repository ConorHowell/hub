#!/usr/bin/env bash
#
# Windows (Git Bash) only, and it must sit INSIDE a repo that already has
# .agents/skills/ — the skill links point at siblings of this script. Downloading it
# on its own will fail at the link step, after the config files have been written.
# If you just want skills, use install-skills.sh instead: it works anywhere and
# needs no repo.
#
# It also enables the third-party `caveman` plugin from github.com/JuliusBrussee/caveman
# (not Anthropic). Plugin skills and hooks run in your session with your privileges.
# Read it before running this, or delete the enabledPlugins block below.
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── OS guard ──────────────────────────────────────────────────
# This script is Windows/Git-Bash only: it uses $USERPROFILE for the home
# directory and `mklink /J` for the skill links. Neither exists elsewhere.
if [ -z "${USERPROFILE:-}" ] || ! command -v cmd >/dev/null 2>&1; then
  echo "setup.sh is for Windows (Git Bash) only." >&2
  echo "" >&2
  echo "On macOS or Linux, do the same three things by hand:" >&2
  echo "  1. Write your rules to ~/.claude/CLAUDE.md" >&2
  echo "  2. Write your hooks to ~/.claude/settings.json" >&2
  echo "  3. Symlink each skill:  ln -sfn <skill-source-dir> ~/.claude/skills/<name>" >&2
  echo "" >&2
  echo "Or run install-skills.sh, which handles step 3 on every platform." >&2
  exit 1
fi

CLAUDE_DIR="$USERPROFILE/.claude"   # Git Bash exposes $USERPROFILE for Windows home

mkdir -p "$CLAUDE_DIR"

# ── Back up anything we are about to overwrite ────────────────
# `cat >` destroys an existing global config silently. Keep a timestamped copy.
backup() {
  [ -f "$1" ] || return 0
  local dest="$1.backup.$(date '+%Y%m%d-%H%M%S')"
  cp "$1" "$dest"
  echo "  backed up: $dest"
}

backup "$CLAUDE_DIR/CLAUDE.md"
backup "$CLAUDE_DIR/settings.json"

# ── Global CLAUDE.md ──────────────────────────────────────────
cat > "$CLAUDE_DIR/CLAUDE.md" << 'EOF'
# Global Claude Rules

## Before Any Task
- If the task is non-trivial, ask clarifying questions before writing code or making changes.
- For any task with more than one valid approach, present the options with tradeoffs before proceeding.
- For destructive or hard-to-reverse actions, confirm with the user before executing.

## Execution
- Break work into small atomic steps. Complete and verify each before moving to the next.
- Prefer editing existing files over creating new ones.
- Do not add features, abstractions, error handling, or refactoring beyond what the task explicitly requires.

## Every Edit
- Scan for dead code, unused variables, empty rules, and unreachable branches on every edit.
- Write no comments unless the WHY is non-obvious and would surprise a future reader.
- Write secure code — no command injection, XSS, SQL injection, or OWASP top 10 vulnerabilities.

## Output Quality
- Do not summarize what you just did at the end of responses — the user can read the diff.
- For UI or frontend changes, verify visually before reporting complete.

## Model and Effort
- Use the short model alias (opus, sonnet, haiku), not a pinned full ID — an alias tracks the newest model in its tier and cannot silently go stale.
- Pick model and effort at the START of a session. Both are part of the prompt-cache key, so changing either mid-session recomputes the whole conversation.
- Keep the main thread at high effort; push cheap work to subagents with their own model in frontmatter.

## Session Start
- Read any project handoff notes before starting work, and write them back at session end.
EOF

# ── settings.json ─────────────────────────────────────────────
cat > "$CLAUDE_DIR/settings.json" << 'EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "[ -f \"CLAUDE.md\" ] || [ -f \".claude/CLAUDE.md\" ] || echo '{\"systemMessage\": \"No context file found in this project. Run /init to generate a project map before starting work.\"}'"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "auto",
        "hooks": [
          {
            "type": "command",
            "command": "printf '{\"hookSpecificOutput\":{\"hookEventName\":\"PreCompact\",\"additionalContext\":\"PRESERVE DURING COMPACTION: active task state, open file paths, data correctness rules, any bugs under investigation, and all project constraints from CLAUDE.md.\"}}'"
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "printf '%s | /context to inspect | /clear between tasks | /rewind to undo' \"$(date '+%H:%M')\""
  },
  "extraKnownMarketplaces": {
    "caveman": {
      "source": {
        "source": "github",
        "repo": "JuliusBrussee/caveman"
      }
    }
  },
  "effortLevel": "high",
  "autoCompactEnabled": true,
  "enabledPlugins": {
    "caveman@caveman": true
  }
}
EOF

# ── Skill junctions (.claude/skills/ → .agents/skills/) ───────
# ln -s is unreliable on Windows without Developer Mode.
# mklink /J (directory junction) needs no privileges.
mkdir -p "$REPO_DIR/.claude/skills"
SKILLS=(caveman caveman-help caveman-review caveman-stats caveman-commit caveman-compress cavecrew ship-review)
for skill in "${SKILLS[@]}"; do
  junction="$REPO_DIR/.claude/skills/$skill"
  source="$REPO_DIR/.agents/skills/$skill"
  if [ ! -e "$junction" ]; then
    # Convert to Windows paths for mklink
    win_junction=$(cygpath -w "$junction")
    win_source=$(cygpath -w "$source")
    cmd /c "mklink /J \"$win_junction\" \"$win_source\"" > /dev/null
    echo "  linked: .claude/skills/$skill"
  fi
done

echo ""
echo "Done. Open Claude Code in this directory."
echo "Caveman plugin will auto-install on first launch."
