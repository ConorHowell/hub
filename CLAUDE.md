# Hub

> Inherits: ~/.claude/CLAUDE.md + Co-Work_Main/CLAUDE.md

## Overview
- **What it does:** Project landing page — links to all deployed tools.
- **Tech stack:** Single self-contained HTML file. No build step. No external deps.
- **Entry point:** index.html
- **Deploy:** `./publish.sh hub "message"` from Co-Work_Main/
- **Live URL:** https://chportfolio.us/hub/

## Key Files
| File | Purpose |
|------|---------|
| index.html | Entire app — all HTML, CSS, JS inline |

## Constraints
- **Subagents:** `Explore` for any read >1 file. `general-purpose` (worktree) for ALL edits. Inline exception: single known-path read only.
- **No external deps:** Keep index.html fully self-contained.
- **Adding a project:** Add a `<div class="project-group">` block, then `./publish.sh hub "Add X to hub"`.
