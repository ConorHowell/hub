# Co-Work_Main Onboarding

## Projects & Deploy
| Dir | Repo | Slug | Auth |
|-----|------|------|------|
| Hub/ | ConorHowell/hub | /hub/ | none |
| Neon Odyssey/ | ConorHowell/gm-tools | /neon/ | HTTP Basic: neon |
| Champions Helper/ | ConorHowell/champions-helper | /champ/ | HTTP Basic: champ |
| Morrowind Quest Helper/ | ConorHowell/morrowind-quest-helper | /morrowind/ | none |

Server: AWS Lightsail — details in `_PRIVATE/server-access.md`

**NEVER commit/push/deploy manually. Always:** `./publish.sh <slug> "message"`

## Rules
- Session start: invoke `/caveman` before first response.
- ALL file searches/greps/dir listings → `Explore` subagent.
- ALL edits (even 1 line) → `general-purpose` subagent via worktree.
- Read single known-path file inline ONLY for immediate value in current turn.
- Credentials: `_PRIVATE/server-access.md` — never hardcode.
- New apps: follow Adding a New Project pattern in CLAUDE.md.
- Session end: update Next Steps in CLAUDE.md + run `git worktree prune`.

## Skills
| Skill | What it does |
|-------|-------------|
| `/caveman` | Terse mode — drops articles/filler, ~75% fewer output tokens |
| `/cavecrew` | Decision guide for spawning compressed subagents |
| `/caveman-review` | One-line PR comments: `path:line: 🔴 bug: problem. fix.` |
| `/caveman-commit` | Conventional Commits ≤50 chars, body only when why is non-obvious |
| `/caveman-compress FILE` | Compress a .md file in-place, saves ~46% tokens |
| `/caveman-stats` | Real token usage from session log |
| `/caveman-help` | Quick-reference card |
| `/ship-review` | Pre-ship diff review — used by publish.sh automatically |

## Active Project Notes
- **Morrowind Quest Helper**: deployed, flagged for future bot-autonomous quest data updates. Pre-conditions in `Morrowind Quest Helper/.claude/CLAUDE.md` — no build script yet, questData is inline in HTML.
- **Neon Odyssey deploy.sh**: uses rsync with explicit file list — update it when new files added.
- **ship-review**: skill drives publish.sh review prompt — edit `.agents/skills/ship-review/SKILL.md` to change criteria.

## Drive Layout (Windows machine)
- `C:\` — system only. Claude config here (`C:\Users\<user>\.claude\`) but nothing else.
- `D:\` — all repos and projects (this repo lives at `D:\Co-Work_Main\`).
- `E:\` — games and modding work.

## First Session Checklist
1. Read project CLAUDE.md (already done if you're reading this).
2. Run `/caveman` — will be reminded by SessionStart hook if you forget.
3. Read the specific sub-project's `.claude/CLAUDE.md` before touching its files.
4. Never use `git push` / `scp` directly — use `./publish.sh`.
5. New files/projects → D: drive. Game modding → E: drive. Never C:.
