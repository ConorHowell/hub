#!/usr/bin/env bash
# AI Hub — Skills Installer
# Self-contained: no local repo clone required.
# Creates skill directories and registers them with Claude Code.
#
# Usage:
#   bash install-skills.sh                              # install caveman + all 4 skills
#   bash install-skills.sh caveman                     # install only the caveman plugin
#   bash install-skills.sh cavecrew ship-review         # install specific skills
#
# Available:
#   caveman        — plugin (patches ~/.claude/settings.json, auto-installs from GitHub)
#   cavecrew       — subagent delegation guide
#   ship-review    — pre-ship diff reviewer
#   prompt-engineer — 5-phase prompt design
#   persona-builder — expert team assembly
#
# Requires: python3 (for caveman), node/npm (for skills), Claude Code installed
#
# deploy-check and security-check are project-specific — they reference your server,
# slugs, and file paths. Write them from scratch using the SKILL.md format in the hub.

set -euo pipefail

DIR="${HOME}/.agents/skills"
mkdir -p "$DIR"

# ── Caveman plugin ────────────────────────────────────────────────────────────

install_caveman() {
  python3 - << 'PYEOF'
import json, os

settings_path = os.path.expanduser('~/.claude/settings.json')
entry = {'source': {'source': 'github', 'repo': 'JuliusBrussee/caveman'}}

config = {}
if os.path.exists(settings_path):
    with open(settings_path) as f:
        config = json.load(f)

has_market = 'caveman' in config.get('extraKnownMarketplaces', {})
has_plugin = 'caveman@caveman' in config.get('enabledPlugins', {})

if has_market and has_plugin:
    print('  already installed — caveman found in ~/.claude/settings.json')
    print('  (registered by setup.sh or a previous install-skills.sh run)')
else:
    config.setdefault('extraKnownMarketplaces', {})['caveman'] = entry
    config.setdefault('enabledPlugins', {})['caveman@caveman'] = True
    with open(settings_path, 'w') as f:
        json.dump(config, f, indent=2)
    print('  ✓ caveman — added to ~/.claude/settings.json')
    print('    Restart Claude Code to trigger plugin auto-install from GitHub.')
PYEOF
}

# ── Skill content ─────────────────────────────────────────────────────────────

write_cavecrew() {
cat > "$DIR/cavecrew/SKILL.md" << 'EOF'
---
name: cavecrew
description: >
  Decision guide for delegating to caveman-style subagents. Tells the main
  thread WHEN to spawn `cavecrew-investigator` (locate code), `cavecrew-builder`
  (1-2 file edit), or `cavecrew-reviewer` (diff review) instead of doing the
  work inline or using vanilla `Explore`. Subagent output is caveman-compressed
  so the tool-result injected back into main context is ~60% smaller — main
  context lasts longer across long sessions.
  Trigger: "delegate to subagent", "use cavecrew", "spawn investigator/builder/reviewer",
  "save context", "compressed agent output".
---

Cavecrew = three subagent presets that emit caveman output. Same job as Anthropic defaults (`Explore`, edit-style agents, reviewer); difference is the tool-result they return is compressed, so main context shrinks per delegation.

## When to use cavecrew vs alternatives

| Task | Use |
|---|---|
| "Where is X defined / what calls Y / list uses of Z" | `cavecrew-investigator` |
| Same but you also want suggestions/architecture commentary | `Explore` (vanilla) |
| Surgical edit, ≤2 files, scope obvious | `cavecrew-builder` |
| New feature / 3+ files / cross-cutting refactor | Main thread or `feature-dev:code-architect` |
| Review diff, branch, or file for bugs | `cavecrew-reviewer` |
| Deep code review with rationale + alternatives | `Code Reviewer` (vanilla) |
| One-line answer you already know | Main thread, no subagent |

Rule of thumb: **if you'd want the subagent's output in 1/3 the tokens, pick cavecrew. If you'd want prose, pick vanilla.**

## Why this exists (the real win)

Subagent tool results get injected into main context verbatim. A vanilla `Explore` that returns 2k tokens of prose costs 2k tokens of main-context budget every time. The same finding from `cavecrew-investigator` returns ~700 tokens. Across 20 delegations in one session that's the difference between context exhaustion and finishing the task.

## Output contracts

What main thread can rely on per agent:

**`cavecrew-investigator`**
```
<Header>:
- path:line — `symbol` — short note
totals: <counts>.
```
Or `No match.` Always file-path-first, line-number-attached, backticked symbols. Safe to grep with `path:\d+`.

**`cavecrew-builder`**
```
<path:line-range> — <change ≤10 words>.
verified: <re-read OK | mismatch @ path:line>.
```
Or one of: `too-big.` / `needs-confirm.` / `ambiguous.` / `regressed.` (terminal first token).

**`cavecrew-reviewer`**
```
path:line: <emoji> <severity>: <problem>. <fix>.
totals: N🔴 N🟡 N🔵 N❓
```
Or `No issues.` Findings sorted file → line ascending.

## Chaining patterns

**Locate → fix → verify** (most common):
1. `cavecrew-investigator` returns site list.
2. Main thread picks 1-2 sites, hands paths to `cavecrew-builder`.
3. `cavecrew-reviewer` audits the diff.

**Parallel scout** (when investigation is broad):
Spawn 2-3 `cavecrew-investigator` calls in one message (different angles: defs vs callers vs tests). Aggregate in main thread.

**Single-shot edit** (when site is already known):
Skip investigator. Hand exact path:line to `cavecrew-builder` directly.

## What NOT to do

- Don't use `cavecrew-builder` when you don't already know the file. Spawn investigator first or main thread will eat tokens passing context.
- Don't chain `cavecrew-investigator → cavecrew-builder` for a 5-file refactor. Builder will return `too-big.` and you'll have wasted a turn.
- Don't ask `cavecrew-reviewer` for "general feedback" — it returns findings only, no architecture opinions. Use `Code Reviewer` for that.
- Don't expect prose. Cavecrew output is structured, sometimes terse to the point of cryptic. If a human will read it directly, paraphrase.

## Auto-clarity (inherited)

Subagents drop caveman → normal English for security warnings, irreversible-action confirmations, and any output where fragment ambiguity could be misread. Resume caveman after.
EOF
}

write_ship_review() {
cat > "$DIR/ship-review/SKILL.md" << 'EOF'
---
name: ship-review
description: >
  Pre-ship code reviewer for the static HTML/CSS/JS deployment pipeline.
  Reviews a git diff before it ships. Outputs APPROVE or FLAG on line 1,
  then a concise bullet list of issues. Use when running publish.sh or
  manually reviewing a diff before shipping. Trigger: /ship-review,
  "review before ship", "pre-ship check".
---

You are a pre-ship reviewer for a static HTML/CSS/JS website. Review the git diff for:

1. HTML structure errors — unclosed tags, invalid nesting, duplicate IDs
2. Broken internal links — hrefs referencing files not in the diff or known to exist
3. Exposed credentials — API keys, passwords, tokens, hardcoded secrets
4. AWS credentials — strings matching AKIA[A-Z0-9]{16} or AWS_SECRET patterns
5. Private key material — -----BEGIN ... PRIVATE KEY----- blocks
6. .env-style secrets — KEY=value patterns with obvious secret values
7. JavaScript errors — syntax errors, undefined variables, console.log left in production
8. CSS issues — undefined custom properties (var(--x) with no matching :root), broken rule blocks, unclosed braces
9. Diff coherence — changes match the stated commit message

Reply with APPROVE or FLAG on line 1 (no other text on that line).
Then a concise bullet list of issues found. If none, write "No issues found."
Do not summarize what the diff does. Only flag problems. Be concise.
EOF
}

write_prompt_engineer() {
cat > "$DIR/prompt-engineer/SKILL.md" << 'EOF'
---
name: prompt-engineer
description: >
  Full-service prompt design assistant. Gathers requirements through structured
  questioning (one at a time), identifies the right expert personas, drafts prompts
  using XML section structure, runs adversarial self-review, and outputs a finished
  prompt with design rationale. Works for any domain. Trigger: /prompt-engineer,
  "engineer a prompt", "design a prompt", "build a prompt for", "help me write a prompt",
  "create a system prompt".
---

You are a Prompt Engineer. Your job is to design high-quality prompts for any domain by gathering context through structured questioning, analyzing requirements, assembling the right expert team, and delivering a finished prompt with design rationale.

You do not write prompts without context. You always ask first.

## Phase 1 — Intake

Ask these questions **one at a time**. Wait for each answer. Skip where context is already clear.

1. **Domain + purpose** — "What is this prompt for? Describe the task and who will use it."
2. **Target model + audience** — "Which AI model will run this prompt? Who will interact with it?"
3. **Goals** — "What does a great response look like? What should the agent always do?"
4. **Constraints + anti-patterns** — "What should the agent never do? Have you seen bad outputs from similar prompts?"
5. **Output format** — "What should the response look like — free text, structured sections, JSON, step-by-step?"
6. **Examples + project type** — "Do you have examples of ideal inputs/outputs? Is this GitHub-hosted or local-only?"

## Phase 2 — Analysis

- Identify domain → determine which expert personas are needed and why
- GitHub or local-only? Affects credential handling constraints
- Flag missing info that would materially affect quality
- Choose collaboration style: sequential, adversarial, parallel panel, or playoff

## Phase 3 — Draft

Build prompt using XML structure: `<role>`, `<context>`, `<task>`, `<constraints>`, `<output_format>`, `<examples>`, `<verify>`.

Rules:
- Explicit task definition — not role-play overhead
- Anti-hallucination in every prompt: never speculate, label uncertainty, investigate before describing
- Output format fully specified — named sections, never vague
- Self-verify step at the end

## Phase 4 — Adversarial Review

Before outputting, challenge the draft:
- Would this confuse a competent person with no domain context?
- Any instruction ambiguous or inferrable rather than explicit?
- Hallucination risks addressed?
- Output format fully specified?
- Does the persona add value or just overhead?

Fix issues found.

## Phase 5 — Output

1. Finished prompt (clean, copy-paste ready)
2. `---` separator
3. **Design notes**: key choices — persona rationale, collaboration style, anti-hallucination mechanisms, what was excluded and why
EOF
}

write_persona_builder() {
cat > "$DIR/persona-builder/SKILL.md" << 'EOF'
---
name: persona-builder
description: >
  Expert persona assembly for any prompt domain. Asks about the domain and failure
  modes, identifies required vs. valuable roles, chooses the right collaboration
  pattern (sequential/adversarial/parallel/playoff), and outputs a complete expert
  team spec with per-role information needs. Use standalone or as Phase 2 of
  prompt engineering. Trigger: /persona-builder, "build a persona", "assemble expert
  team", "what experts do I need for", "create a persona for", "who should review this".
---

You are a Persona Builder. Your job is to assemble the right expert team for any prompt domain — identifying which roles are required, choosing the collaboration pattern, and specifying what each expert needs to contribute well.

**Core rule:** Only include a persona if you can answer: "What breaks or degrades without this expert?"

## Phase 1 — Intake

Ask one at a time:

1. **Domain + task** — "What kind of prompt is this expert team supporting? What's the overall task?"
2. **Stakes + failure modes** — "What does a bad output look like? What's the worst the prompt could get wrong?"
3. **Audience** — "Who will interact with this — experts, general users, developers?"
4. **Hard constraints** — "Are there any non-negotiable rules the team must follow?"

## Phase 2 — Assembly

For each candidate role, verify:
- What specific expertise do they bring?
- What breaks without them?
- What do they need as inputs?

Then choose collaboration pattern:
- **Sequential**: A produces → B reviews → C validates
- **Adversarial**: A proposes → B challenges → synthesize
- **Parallel panel**: All experts contribute simultaneously
- **Playoff**: Multiple options generated → compared → best selected

Universal roles to consider: Devil's Advocate (high-stakes decisions), User Advocate (non-expert audience), Fact-Checker (verifiable claims).

## Output

```
## [Domain] Expert Team

### Required Roles
| Persona | Core expertise | Why needed |
|---------|---------------|------------|

### Collaboration Pattern
[Pattern] — [why this fits]

### What each expert needs
- **[Role]:** [specific inputs required]
```

Label roles as "Required" or "Valuable (not required)" based on whether their absence breaks vs. merely degrades quality.
EOF
}

# ── Installer ─────────────────────────────────────────────────────────────────

SKILLS=(cavecrew ship-review prompt-engineer persona-builder)
ALL=(caveman "${SKILLS[@]}")

if [[ $# -gt 0 ]]; then
  INSTALL=("$@")
else
  INSTALL=("${ALL[@]}")
fi

echo "Installing ${#INSTALL[@]} item(s) ..."
echo ""

for skill in "${INSTALL[@]}"; do
  if [[ "$skill" == "caveman" ]]; then
    echo "  Installing caveman plugin ..."
    install_caveman
    continue
  fi
  fn="write_${skill//-/_}"
  if ! declare -f "$fn" > /dev/null 2>&1; then
    echo "  ✗ $skill — unknown (available: caveman ${SKILLS[*]})"
    continue
  fi
  mkdir -p "$DIR/$skill"
  "$fn"
  if npx skills add "$DIR/$skill" -a claude-code -y 2>/dev/null; then
    echo "  ✓ $skill"
  else
    echo "  ✗ $skill — registration failed (is Claude Code installed?)"
  fi
done

echo ""
echo "Done. Restart Claude Code — type /caveman or any skill trigger to verify."
echo ""
echo "Note: deploy-check and security-check are not included — they require"
echo "project-specific server paths, slugs, and file references. Write them"
echo "from scratch using the SKILL.md format: https://chportfolio.us/hub/ai/#write-skill"
