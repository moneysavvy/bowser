# Migration (early 2026 → July 2026)

## Path map

| Old | New |
|-----|-----|
| `ai_review/user_stories/` | `stories/` |
| `screenshots/bowser-qa/` | `artifacts/qa/` |
| `HANDOFF.md` | `archive/HANDOFF-2026-02.md` + `docs/*` |
| Examples 06–15, fast-build | `archive/examples-generated/` |
| `shannon/`, `hyperbrowser-app-examples/` | `archive/` |
| Invoice/research one-offs | `archive/one-offs/` |
| `just test-playwright-skill` | `just smoke-playwright` (alias kept) |
| `just test-chrome-skill` | `just smoke-chrome` (alias kept) |

## Command map

| Old habit | New |
|-----------|-----|
| Ad-hoc prompts only | `just demo-chrome` / `just demo-qa` / `just demo-hop` |
| Assume Playwright installed | `just preflight` first |
| Mixed root clutter as “the product” | Root = product; `archive/` = unsupported |

## Playwright CLI

Install/refresh:

```bash
npm install -g @playwright/cli@latest
playwright-cli install-browser
```

Bowser skills now document July 2026 CLI commands (`install-browser`, `kill-all`, dialog helpers, artifact paths).

## Deprecated behavior

Stale just aliases print `DEPRECATED` and forward. Archived trees are not supported demos — do not wire new commands to `archive/` without moving content back intentionally.
