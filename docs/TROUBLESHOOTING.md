# Troubleshooting

## Preflight fails

```bash
just preflight
```

Follow printed `FAIL` lines first.

| Symptom | Fix |
|---------|-----|
| `playwright-cli missing` | `npm i -g @playwright/cli@latest` |
| `list` fails / no browser | `playwright-cli install-browser` |
| alpha CLI version | Reinstall `@playwright/cli@latest` (avoid stale globals) |
| `claude` missing | Install Claude Code; ensure CLI on `PATH` |
| `just` missing | `brew install just` |
| node startup very slow | Raise Starship `command_timeout`; avoid heavy prompt modules during demos |

## Chrome tools not available

Restart Claude Code with `--chrome`. Or use Playwright mode:

```bash
just smoke-playwright
just demo-qa
```

## Cookie banners / modals

Use `dialog-accept` / `dialog-dismiss`, or snapshot and click the dismiss control. Encode expected first-run handling in the story when possible.

## Auth required

- Prefer **Claude-Bowser** when the user's existing session is required
- For Playwright: run login once with `--persistent`, or `state-save` / `state-load`

## Localhost drift

1. Confirm the server: `curl -sI http://127.0.0.1:<port>`
2. Match the port in `stories/*.yaml`
3. Prefer headed mode once: `just ui-review headed=headed filter=01-todo`

## Headless-only failures

Re-run headed:

```bash
just smoke-playwright headed=true prompt="..."
```

## Parallel session collisions

Always use unique `-s=` names. On stuck browsers:

```bash
playwright-cli close-all
playwright-cli kill-all
```

## Secrets hygiene

- Keep keys in `.env` only (gitignored). Use `.env.sample` as the template.
- Never put `sk-` tokens in `.claude/settings.json` (committed).
- If a key was ever printed in a terminal/agent log, rotate it.