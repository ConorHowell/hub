#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$USERPROFILE/.claude"   # Git Bash exposes $USERPROFILE for Windows home

mkdir -p "$CLAUDE_DIR"

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
- Before delivering, challenge your own output: Is this the simplest correct solution? What are the edge cases?
- Do not summarize what you just did at the end of responses — the user can read the diff.
- For UI or frontend changes, verify visually before reporting complete.

## Session Start
- At the start of every session, activate caveman mode by invoking the /caveman skill before your first response.
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
            "command": "echo '{\"systemMessage\": \"Auto-compacting: preserve active task state, open file paths, data correctness rules, any bugs under investigation, and all project constraints from CLAUDE.md.\"}'"
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "printf '%s | auto-compact ON | /compact to compact now | /clear between tasks' \"$(date '+%H:%M')\""
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
