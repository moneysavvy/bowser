---
name: playwright-bowser
description: Headless browser automation using Playwright CLI. Use when you need headless browsing, parallel browser sessions, UI testing, screenshots, web scraping, or browser automation that can run in the background. Keywords - playwright, headless, browser, test, screenshot, scrape, parallel.
allowed-tools: Bash
---

# Playwright Bowser

## Purpose

Automate browsers using `playwright-cli` (`@playwright/cli`) — the July 2026 token-efficient CLI for coding agents. Headless by default, parallel via named sessions (`-s=`), no large MCP tool schemas in context.

**Not interchangeable with Claude-Bowser.** Use this mode for isolation, CI, parallelism, and repeatable QA. Use `/claude-bowser` when you need the user's real Chrome profile.

## Install (July 2026)

```bash
npm install -g @playwright/cli@latest
playwright-cli install-browser
playwright-cli --help
```

Optional: `playwright-cli install` to initialize workspace config. Prefer current `@playwright/cli` over stale alpha globals.

## Key Details

- **Headless by default** — pass `--headed` to `open` to watch
- **Parallel sessions** — `-s=<name>` for independent browsers
- **Persistent profiles** — `--persistent` keeps cookies/storage across calls
- **Auth bootstrap** — `state-save` / `state-load` for login reuse; or run a login story once with `--persistent`
- **Vision mode** (opt-in) — `PLAYWRIGHT_MCP_CAPS=vision` returns screenshots as images in context
- **Artifacts** — prefer writing under `artifacts/qa/<run-id>/` or paths passed by the orchestrator

## Sessions

**Always use a named session.** Derive a short kebab-case name from the task.

```bash
PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900 playwright-cli -s=mystore-checkout open https://mystore.com --persistent
playwright-cli -s=mystore-checkout snapshot
playwright-cli -s=mystore-checkout click e12
```

```bash
playwright-cli list
playwright-cli close-all
playwright-cli kill-all          # stale/zombie sessions
playwright-cli -s=<name> close
playwright-cli -s=<name> delete-data
```

## Quick Reference

```
Core:       open [url], goto <url>, click <ref>, fill <ref> <text>, type <text>, snapshot, screenshot [ref], close
Navigate:   go-back, go-forward, reload
Keyboard:   press <key>, keydown <key>, keyup <key>
Mouse:      mousemove <x> <y>, mousedown, mouseup, mousewheel <dx> <dy>
Tabs:       tab-list, tab-new [url], tab-close [index], tab-select <index>
Save:       screenshot [ref], pdf, screenshot --filename=f
Storage:    state-save, state-load, cookie-*, localstorage-*, sessionstorage-*
Network:    route <pattern>, route-list, unroute, network
DevTools:   console, run-code <code>, tracing-start/stop, video-start/stop, show, eval
Sessions:   -s=<name> <cmd>, list, close-all, kill-all
Install:    install, install-browser
Config:     open --headed, open --browser=chrome|firefox, resize <w> <h>
Dialogs:    dialog-accept, dialog-dismiss   # cookie banners / modals
```

## Workflow

1. Open with named session + viewport:
```bash
PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900 playwright-cli -s=<session-name> open <url> --persistent
# headed debug:
PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900 playwright-cli -s=<session-name> open <url> --persistent --headed
```

2. Snapshot → interact via refs (`click`, `fill`, `type`, `press`).

3. Dismiss first-run noise when needed (`dialog-accept` / `dialog-dismiss` or click the banner ref).

4. Screenshot to the orchestrator path when provided:
```bash
playwright-cli -s=<session-name> screenshot --filename=artifacts/qa/<run>/<step>.png
```

5. **Always close** when done:
```bash
playwright-cli -s=<session-name> close
```

## Configuration

If `playwright-cli.json` exists in the cwd, it is used. Optional:

```json
{
  "browser": {
    "browserName": "chromium",
    "launchOptions": { "headless": true },
    "contextOptions": { "viewport": { "width": 1440, "height": 900 } }
  },
  "outputDir": "./artifacts/playwright"
}
```

## Full Help

`playwright-cli --help` and `playwright-cli --help <command>`.

See [docs/playwright-cli.md](docs/playwright-cli.md) for extended notes.
