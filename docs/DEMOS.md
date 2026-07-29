# Demos

Every live track: preflight → deterministic start → safe stop → artifacts.

## Prerequisites

```bash
just preflight
```

Claude-Bowser tracks need a Chrome-enabled session: start Claude Code with `--chrome`.

## Track 1 — Observable browser (`demo-chrome`)

```bash
just demo-chrome
```

**Expect:** HN front page opened in real Chrome; top titles reported; screenshots optional under `artifacts/chrome/`.

**Fallback:** If Chrome MCP missing, switch to `just demo-blog` (Playwright) or restart `claude --chrome`.

## Track 2 — Parallel QA (`demo-qa`)

```bash
just demo-qa
```

**Expect:** `/ui-review` on `stories/hackernews.yaml`; multiple agents; screenshots under `artifacts/qa/<run>/`; summary in chat (write `summary.md` into run dir when aggregating).

**Fallback:** Narrow filter already set to `hackernews`. If network blocked, serve `examples/01-todo-app` and run `just ui-review filter=01-todo`.

## Track 3 — Workflow orchestration (`demo-hop`)

```bash
just demo-hop
```

**Expect:** Amazon search → add to cart → **stop before purchase**.

**Fallback:** `just demo-blog` (no auth, Playwright headless).

## Track 4 — Failure / recovery (`demo-failure`)

```bash
just demo-failure
```

**Expect:** Preflight output with actionable repair commands (e.g. install `@playwright/cli`, `install-browser`).

## Demo-safe rules

- Never complete payments or destructive admin actions
- Prefer public sites (HN, simonwillison.net) for network demos
- For localhost demos, document port in the story and verify HTTP 200 first
