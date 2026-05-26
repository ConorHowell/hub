# WordPress Dev Bot Template

> Source file `CLAUDE.wordpress-tw.md` not yet created at project root.
> Create it at `/Users/home/Documents/Co-Work_Main/CLAUDE.wordpress-tw.md`, then re-deploy to update this file.

## Intended Stack
- Underscores (_tw) starter theme + Tailwind CSS
- Local by Flywheel for local dev
- WP Engine for production
- Pure PHP templates (no page builders)
- Claude acts as junior coder — asks before architectural changes

## Usage
1. Copy this file to your WordPress project root.
2. Rename to `CLAUDE.md`.
3. Find/replace `[THEME_NAME]` with your actual theme folder name.
4. Fill in the project-specific sections below.

## Overview
- **What it does:** [describe site purpose]
- **Tech stack:** WordPress · _tw (Underscores + Tailwind CSS) · PHP · Local by Flywheel
- **Theme:** `wp-content/themes/[THEME_NAME]/`
- **Dev command:** Open Local by Flywheel → start site

## Key Files
| File | Purpose |
|------|---------|
| `wp-content/themes/[THEME_NAME]/functions.php` | Theme functions, enqueue scripts |
| `wp-content/themes/[THEME_NAME]/tailwind.config.js` | Tailwind configuration |
| `wp-content/themes/[THEME_NAME]/style.css` | Theme header + base styles |

## Constraints
- Never edit files in `wp-content/plugins/` unless explicitly asked.
- No page builder markup — pure PHP templates only.
- Tailwind classes only in template files; no custom CSS unless Tailwind can't cover it.
- Always test in Local before pushing to WP Engine.
- Junior coder role: propose changes, wait for approval on anything structural.

## Deploy
- Local → WP Engine via WP Engine Local plugin push, or manual SFTP.
- Never push directly to production database.

## Known Gotchas
- Tailwind purge config must include all PHP template paths or classes will be stripped in production build.
- `functions.php` fatal errors take down the whole site — test locally first.
