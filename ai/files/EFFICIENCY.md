# Efficiency — Prompting and Token Economics

> Verified **2026-07-27** against the official documentation:
> `code.claude.com/docs/en/costs`, `code.claude.com/docs/en/prompt-caching`,
> `code.claude.com/docs/en/context-window`, `code.claude.com/docs/en/best-practices`,
> and the Anthropic prompt-engineering best-practices page at
> `platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices`.
>
> Two things in one guide: **how to prompt current Claude models**, and **what actually costs tokens
> in Claude Code**. Start with the first section — a lot of widely-repeated prompting advice is now
> actively harmful.

---

## 1. Prompting advice that is now WRONG

These are not style preferences. Each one is contradicted by the current docs, and several cost you
tokens, latency, or a hard API error.

| Old advice | What the docs say now |
|---|---|
| "Add *double-check your work* / *verify your answer*" | **Remove it on Opus 5.** It verifies its own work without being told, and verification instructions carried over from older prompts cause over-verification — extra tokens and latency for nothing. Remove these instructions rather than rewriting them. |
| "Say *think step by step* and prescribe the steps" | Prefer general over prescriptive. "Think thoroughly" usually produces better reasoning than a hand-written plan — the model's own reasoning frequently exceeds what a human would prescribe. |
| "Tell it what **not** to do" | Tell Claude what to do instead of what not to do. Positive examples beat prohibitions. |
| "Prefill the assistant turn to force a format" | **Hard error.** From Claude 4.6 onward, a prefilled response on the last assistant turn is no longer supported — such requests return a **400**, regardless of thinking settings. Use structured outputs instead. |
| "Set a thinking budget (`budget_tokens`)" | Deprecated — **400s on Claude 4.7 and later**. Use effort levels plus `max_tokens`. |
| "Longer, more complete instructions are safer" | Bloated `CLAUDE.md` files cause Claude to **ignore your actual instructions**. |
| "If in doubt, use [tool]" | Causes tool **overtriggering**. Say *when* to use a tool, not how eager to be. |
| "CRITICAL: YOU MUST use this tool when…" | Dial the aggressive language back for tool descriptions — normal phrasing ("Use this tool when…") triggers more accurately. (Emphasis in `CLAUDE.md` for a small number of genuine hard rules is still supported by the Claude Code docs — that's a different thing from tool triggering.) |

**One more, easy to miss:** with thinking **disabled**, the word "think" is itself a trigger. Use
*consider*, *evaluate*, or *reason through* instead. And if a prompt of yours contains a rule telling
the model **not** to think or reason, delete it — that instruction increases tag leakage.

### The cheapest fix available
Grep your own `CLAUDE.md`, skills, and agent definitions for "double-check", "verify your", "make
sure to check", and "think step by step". Deleting those lines is a pure win: fewer input tokens,
fewer output tokens, lower latency, same or better quality.

---

## 2. Prompting that works

1. **Give the reason with the rule.** Explaining *why* helps Claude generalise to cases you didn't
   anticipate. Not `NEVER use ellipses` — instead, `Your response will be read aloud by a
   text-to-speech engine, so never use ellipses, since it will not know how to pronounce them.`
2. **Examples beat description.** Few-shot is one of the most reliable ways to steer output format,
   tone, and structure. Use **3–5** examples, relevant and diverse, each wrapped in `<example>` tags.
3. **XML tags for sections.** Wrapping each type of content in its own tag (`<instructions>`,
   `<context>`, `<input>`) reduces misinterpretation. Keep tag names consistent.
4. **Put the role in the system prompt**, not the user turn. Even one sentence makes a difference.
5. **Long inputs: material at the TOP, question at the BOTTOM.** For 20k+ token inputs, putting the
   query at the end can improve response quality by **up to 30%**, especially with complex
   multi-document inputs. Most people do this backwards.
6. **Control format positively.** Not "do not use markdown" — instead "your response should be
   composed of smoothly flowing prose paragraphs".
7. **Tell reviewers what counts.** A reviewer prompted to find gaps will usually report some, even
   when the work is sound. Instruct it to **flag only gaps that affect correctness or the stated
   requirements** — otherwise you train yourself to ignore the reviews.
8. **The golden test:** show your prompt to a colleague with minimal context. If they'd be confused,
   Claude will be too.
9. **Corrected the same issue more than twice in one session? Run `/clear` and start fresh.** The
   contradictory history is now working against you, and it costs on every subsequent message.

---

## 3. How prompt caching actually works

The cache matches on the **prefix** — the start of the request — and the match is exact. A change
anywhere in the prefix recomputes everything after it. **There is no per-file or per-segment
caching.** Claude Code orders each request so the most stable content comes first:

| Layer | Contains | Invalidated by |
|---|---|---|
| System prompt | Core instructions, tool definitions, output style | Tool-definition set changes, or a Claude Code upgrade |
| Project context | `CLAUDE.md`, auto memory, unscoped rules | Session start, `/clear`, `/compact` |
| Conversation | Messages, responses, tool results | Every turn — normal and cheap |

Two things are part of the cache key without appearing in the prompt text: **the model** and **the
effort level**.

### Invalidates the whole cache
- **Switching model** (`/model`) — each model has its own cache.
- **Changing effort** (`/effort`) — each effort level has its own cache.
- **Turning on fast mode** (`/fast`) — it adds a header that is part of the key. Costs once per
  conversation.
- **Connecting or disconnecting an MCP server**, but *only* when its tools load into the prefix.
  Deferred tool definitions (the default) don't disturb the cache. Same for enabling or disabling a
  plugin that provides an MCP server.
- **Denying an entire tool by bare name** (`Bash`, `WebFetch`). Scoped rules like `Bash(rm *)` don't.
- **Upgrading Claude Code.** Resuming a long session right after an upgrade is the single most
  expensive request you can send.

### Does NOT invalidate the cache
Invoking skills and commands · spawning a subagent · hooks · LSP · themes · editing repo files ·
editing `CLAUDE.md` · changing output style · **changing permission mode** · `/recap` · **`/rewind`**.

### The trap
**Editing `CLAUDE.md` mid-session doesn't invalidate the cache — but it also doesn't take effect.**
Claude keeps using the version loaded at session start. Your edit applies on the next `/clear`,
`/compact`, or restart. Nested `CLAUDE.md` files and `paths:`-scoped rules load later, when a
matching file is first read.

---

## 4. Cache TTL — and the one habit that matters most

| Auth | TTL |
|---|---|
| Claude subscription | **1 hour**, requested automatically by Claude Code |
| API key, or a cloud provider (Bedrock / Vertex) | **5 minutes** |
| Subscription past plan limits, drawing on usage credits | **5 minutes** |

On API-key auth you can opt into the longer window with `ENABLE_PROMPT_CACHING_1H=1`.

This corrects a rule a lot of people (including this hub, previously) were running on: *"cache TTL is
5 minutes, so batch your work and never take a break."* On a subscription that's simply not true.
Normal breaks are fine.

> ### Choose your model and effort at the START of a session.
> That one habit prevents the most expensive avoidable mistake on the list above. Dropping to a
> cheaper model or lower effort **mid-session to save tokens is a full cache miss** — it recomputes
> the entire conversation and usually costs more than it saves.

---

## 5. `/rewind` vs `/compact` vs `/clear`

- **`/rewind`** truncates back to an earlier turn. That prefix is **already cached and still warm** —
  it's the cheapest way to abandon a path that went wrong.
- **`/compact`** replaces history with a summary. The summarization call itself reads the cache; the
  cost is in *generating* the summary. Run it at a natural break, and give it focus:
  `/compact focus on the auth bug fix`.
- **`/clear`** costs nothing. Use it between unrelated tasks. `/rename` the session first and
  `/resume` if you need to come back.

> **Caveat that matters:** checkpoints only capture changes made through Claude's **file-editing
> tools**. Changes made by Bash commands or external processes are **not** captured. `/rewind` is not
> a replacement for git — commit before anything risky.

---

## 6. What survives compaction

| Mechanism | After compaction |
|---|---|
| System prompt, output style | Unchanged |
| Project-root `CLAUDE.md`, unscoped rules, auto memory | Re-injected from disk |
| Rules with `paths:` frontmatter | **Lost** until a matching file is read again |
| Nested `CLAUDE.md` in subdirectories | **Lost** until a file there is read again |
| Invoked skill bodies | Re-injected — capped at **5,000 tokens per skill, 25,000 total**, oldest dropped first |

**Truncation keeps the START of the file.** Put the most important instructions at the top of every
`SKILL.md`. A skill whose critical rule sits at the bottom of a long file silently loses that rule
after a compaction.

---

## 7. Reducing token use — the documented list

1. **`/clear` between unrelated tasks.** Stale context is re-sent on *every* subsequent message.
2. **Right model for the job.** Sonnet handles most coding; reserve the largest model for
   architecture and multi-step reasoning. Route simple subagents to `model: haiku`.
3. **Delegate verbose operations to subagents** — test runs, doc fetching, log processing. The raw
   output stays in their context; only a summary comes back.
4. **Move procedures out of `CLAUDE.md` and into skills.** `CLAUDE.md` loads at session start and
   costs on every turn; a skill body loads only when invoked. **Aim to keep `CLAUDE.md` under ~200
   lines.** Pruning test: *would removing this line cause Claude to make mistakes?* If not, cut it.
5. **Use hooks to preprocess output before Claude ever sees it** — e.g. a hook that greps test output
   for failures turns tens of thousands of tokens into hundreds. Hooks are also deterministic, where
   `CLAUDE.md` instructions are only advisory.
6. **Prefer CLI tools over MCP servers** where one exists (`gh`, `aws`, `gcloud`) — no per-tool
   listing cost. MCP tool definitions are deferred by default; `/context` shows what is actually
   consuming space.
7. **Write specific prompts.** "Improve this codebase" triggers broad scanning. "Add input validation
   to the login function in auth.ts" doesn't.
8. **Use plan mode for complex tasks** — `/plan`, or Shift+Tab to cycle into it. Both reach the same
   mode. It prevents the expensive rework that follows a
   wrong initial direction. Skip planning when you could describe the diff in one sentence.
9. **Give verification targets** — test cases, expected output, a screenshot to match. Self-verifiable
   work catches its own errors instead of costing a correction round-trip. Have Claude show evidence
   rather than assert success; `/goal` re-checks a stated condition each turn.
10. **Lower effort for genuinely mechanical work** — but set it at session start, not mid-task (see §4).

### Subagents are a CONTEXT win more than a token win
A subagent starts its own conversation with its own system prompt — **no cache hits on its first
call** — and it uses the **5-minute TTL even on a subscription**. The parent's cache is untouched. A
`/fork` is different: it inherits the parent's prefix exactly and *does* read the parent's cache.

Delegate for **volume** (keeping thousands of lines of output out of your main window), not for
trivia. A one-line lookup dispatched to a subagent costs more than doing it inline.

Also worth knowing: the cache is effectively scoped to **one machine and one working directory** —
the system prompt embeds the working directory, platform, shell, and OS version. Each git worktree is
its own directory and therefore its own cache, so a worktree agent always pays a cold start. Still
the right call for isolation and parallel edits — just not a token saving.

---

## 8. Diagnosing

| Command | Tells you |
|---|---|
| `/context` | What is consuming the context window right now |
| `/usage` | Token usage and cost. On a paid plan it attributes usage to skills, subagents, plugins, and individual MCP servers, and **flags any behaviour accounting for 10% or more** of recent usage. Toggle 24h vs 7d. |
| `/status` | Model, effort, context %, running tasks — without interrupting a response |
| `/cost` | Cost of the current session |

**The single best health metric** is the ratio of `cache_read_input_tokens` to
`cache_creation_input_tokens`. Cache reads bill at roughly **10% of the standard input rate**. If
creation stays high turn after turn, something in your prefix keeps changing — go back to §3.

**Why a long session burns more than its activity suggests:** the full conversation is sent on every
message, a cache miss after a break reprocesses everything, scheduled tasks fire on an interval with
full context, and idle agents keep consuming.

---

## Summary — the six habits

1. Delete "double-check your work" from every prompt you own.
2. Pick model and effort at the start of the session, then leave them alone.
3. `/rewind` to abandon a path, `/clear` between tasks, `/compact` only when one long task overflows.
4. Keep `CLAUDE.md` short; put procedures in skills, with the important lines at the top.
5. Delegate volume to subagents; do trivia inline.
6. Long inputs: material first, question last.
