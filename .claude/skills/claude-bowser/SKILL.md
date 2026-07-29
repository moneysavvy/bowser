---
name: claude-bowser
description: Observable browser automation using Chrome MCP tools. Use when you need to browse websites, take screenshots, interact with web pages, or perform browser tasks in your current Chrome. Keywords - browse, screenshot, browser, chrome, bowser, ui testing, observable.
---

# Claude Bowser

## Purpose

Automate browsing using Chrome MCP tools (`mcp__claude_in_chrome__*`) available when Claude Code is started with `--chrome`. Uses the user's real Chrome — observable, with existing profile, cookies, and extensions.

**Not interchangeable with Playwright-Bowser.** Use this mode for authenticated personal workflows and live demos. Use `/playwright-bowser` for parallel, headless, or CI automation.

## Pre-flight Check

**Before doing anything**, verify Chrome MCP tools are available (`mcp__claude_in_chrome__*`).

- If available: proceed.
- If NOT available: stop and reply: _"Chrome tools are not available. Restart with `claude --chrome`, or use Playwright-Bowser (`/playwright-bowser`) for isolated automation."_

Optional operator check from the repo root: `just preflight` (notes Chrome requirement; does not prove MCP attachment).

## Workflow

1. Resize the browser window to 1440x900 when the tool allows.
2. Execute the request (navigate, click, type, screenshot).
3. Prefer saving screenshots under `artifacts/chrome/<run-id>/` when doing demos.
4. For purchase/checkout demos: stop at a safe point (cart / checkout review) — never complete payment.
5. Report results with paths to any artifacts captured.

## Limitations

- **No parallel instances.** One shared Chrome controller.
- **Observable only.** No headless mode.
- **Shares the user's browser** — can interfere with active tabs.
- **Not available** in pure programmatic contexts without Chrome MCP.
