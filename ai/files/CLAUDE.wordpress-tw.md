# [THEME_NAME] — WordPress Theme

## Stack
- **Theme:** _tw (Underscores + Tailwind CSS) — `wp-content/themes/[THEME_NAME]/`
- **Local dev:** Local by Flywheel
- **Hosting:** WP Engine
- **Deploy:** Manual push/pull via the Local app — **Claude never deploys**

---

## Project Structure

```
wp-content/themes/[THEME_NAME]/
├── inc/                  # PHP includes (customizer, template-functions, template-tags)
├── template-parts/       # Reusable PHP partials (content, header, footer pieces)
├── src/                  # Source CSS/JS (do not edit compiled output)
│   ├── css/
│   └── js/
├── functions.php         # Theme setup, enqueue, hooks
├── style.css             # WP theme header (do not add real CSS here)
├── tailwind.config.js    # Tailwind config — extend here, don't add arbitrary values
├── package.json
└── *.php                 # Template files (index, page, single, archive, etc.)
```

---

## Build

```bash
# First time / after pulling
npm install

# Development (watch mode — run while coding)
npm run dev

# Production (before pushing to WP Engine)
npm run build
```

**Always run `npm run build` before telling the user the work is ready to push.**
Never edit files in `dist/` or any compiled output directly.

---

## Naming Conventions

Replace `[THEME_NAME]` everywhere with the actual theme slug.

| Thing | Pattern | Example |
|-------|---------|---------|
| Function prefix | `[THEME_NAME]_` | `my_theme_setup()` |
| Text domain | `[THEME_NAME]` | `__( 'Label', '[THEME_NAME]' )` |
| Hook prefix | `[THEME_NAME]/` | `do_action( '[THEME_NAME]/before_header' )` |
| CSS classes | Tailwind utilities + `.[THEME_NAME]-*` for custom | `.my-theme-hero` |

---

## WordPress Rules

- Use `get_template_part()` for all partials — never `include`/`require` template files directly.
- Escape all output: `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses_post()`.
- Never query the database directly (`$wpdb`) unless there is no WP function for it.
- Use `wp_enqueue_scripts` to load CSS/JS — never hardcode `<script>` or `<link>` tags.
- Internationalize all user-facing strings with `__()` / `_e()`.
- Never edit `wp-config.php`, `wp-settings.php`, or core files.
- `functions.php` grows fast — keep it organized. New feature areas go in `inc/`.

---

## Tailwind Rules

- Extend the theme in `tailwind.config.js` → `theme.extend` — do not override defaults.
- Avoid inline `style=""` — use Tailwind utilities or a custom class.
- Custom component classes go in `src/css/` using `@layer components {}`.
- Check `tailwind.config.js` content paths before adding new template directories.

---

## Deployment (Manual — Claude does not touch this)

Push and pull happen through the **Local app UI**:
- Local → WP Engine: "Push to WP Engine" button
- WP Engine → Local: "Pull from WP Engine" button

Before telling the user work is ready:
1. `npm run build` ran successfully
2. No PHP errors in Local's logs
3. Visually confirmed the change in Local (localhost)

---

## Claude's Role — Junior Coder

- Ask before changing template hierarchy, hook structure, or anything architectural.
- Ask before adding a new `inc/` file or registering a new post type/taxonomy.
- Implement what's asked. Do not refactor surrounding code unless asked.
- If something looks wrong in existing code, flag it — don't silently fix it.
- One task at a time. Confirm before moving to the next.
- No npm package installs without asking first.
