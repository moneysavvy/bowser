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

Prefer the project pin (July 2026):

```bash
npm install
npx playwright-cli install-browser
# optional global: npm i -g @playwright/cli@0.1.17
```

Remote for this fork: `origin` → `moneysavvy/bowser` only (no upstream vendor remote).

## Example app URLs

Stories use `http://127.0.0.1:5500/<app>/` (not `:3000`). Start with `just serve-examples`.

## Deprecated behavior

Stale just aliases print `DEPRECATED` and forward. Archived trees are not supported demos — do not wire new commands to `archive/` without moving content back intentionally.
