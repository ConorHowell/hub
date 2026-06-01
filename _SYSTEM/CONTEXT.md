# Hub — Session Context

> Read this + `.claude/CLAUDE.md` before any work on Hub projects.
> Update in-place at session end if structure or content changes.

---

## What This Project Is

Hub is a public-facing resource site at `chportfolio.us/hub/`. It hosts:
- **Project Hub** (`hub/`) — index of all deployed tools
- **AI Hub** (`hub/ai/`) — Claude Code reference, skills, bot templates, onboarding guides

Single-file architecture — all HTML/CSS/JS is inline, no build step, no external deps. Deploy via `./publish.sh hub "message"` from Co-Work_Main/.

---

## Code Assistant Persona

### Required Roles

| Persona | Core expertise | Why needed |
|---------|---------------|------------|
| Frontend Developer | Self-contained HTML/CSS/JS, no-framework patterns, inline asset embedding | Without: risks introducing external deps or breaking the no-build constraint |
| Content Curator | Hub accuracy, skill/template descriptions, public-facing clarity | Without: outdated cards, broken download links, or project-specific info leaking into public content |

### Collaboration Pattern

**Sequential** — Frontend Developer implements, Content Curator reviews for accuracy and public-safety before ship.

### Information Each Expert Needs

- **Frontend Developer:** `Hub/ai/index.html` structure, existing card patterns, CSS variables, JS patterns used
- **Content Curator:** list of live skills/templates in `Hub/ai/files/`, what's deployed vs in-progress, Hub/ai public resource rule

---

## Architecture

- `Hub/index.html` — project landing page (links to all deployed tools)
- `Hub/ai/index.html` — AI Hub (skills, bot templates, onboarding, raw files table)
- `Hub/ai/files/` — downloadable resources: CLAUDE.md templates, MULTIAGENT.md, ONBOARDING.md, FIRST-SESSION.md, install-skills.sh

All files are self-contained. No build step. Apache serves from `/opt/bitnami/wordpress/hub/`.

---

## Hard Rules

- **No project-specific content in public files:** no server IPs, repo names, credentials, or deploy script specifics in `Hub/ai/files/`. All content must be generic and reusable.
- **No external dependencies:** Hub files must work with zero CDN or npm deps.
- **ship-review runs automatically** via publish.sh — FLAG = pause, ask user before continuing.

---

## Known Gotchas

- `Hub/ai/index.html` is a single large file — always use `cavecrew-investigator` to locate sections before editing. Never inline-scan the whole file.
- Raw Files table in index.html must be updated whenever a new file is added to `Hub/ai/files/`.
- ONBOARDING_TEXT in index.html (inline JS) must stay in sync with `Hub/ai/files/ONBOARDING.md`.
