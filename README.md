# Bowser

Agentic browser automation and UI testing — Skill → Subagent → Command → Just.

## Modes (pick one)

| Mode | Command | When |
|------|---------|------|
| **Claude-Bowser** | `just demo-chrome` / `/claude-bowser` | Your real Chrome — logins, cookies, live demos (`claude --chrome`) |
| **Playwright-Bowser** | `just demo-qa` / `/playwright-bowser` | Isolated, parallel, CI-friendly QA via `playwright-cli` |

These are different capabilities, not drop-in replacements.

## Install

```bash
# Claude Code
curl -fsSL https://claude.ai/install.sh | bash   # or: brew install --cask claude-code

# Project-pinned Playwright CLI (July 2026 — preferred)
cd bowser
npm install
npx playwright-cli install-browser

# Optional global CLI (same pin)
npm install -g @playwright/cli@0.1.17

# Just (operator recipes)
brew install just

# Secrets (local only)
cp .env.sample .env   # add ANTHROPIC_API_KEY — never commit .env
```

```bash
just preflight-strict   # production gate
just smoke              # CLI smoke without Claude
claude                  # or: claude --chrome for Claude-Bowser
```

## Quick start

```bash
just ci                 # strict preflight + CLI smoke (CI-equivalent)
just preflight          # environment readiness (warnings allowed)
just demo-qa            # parallel Playwright QA (hackernews stories)
just demo-chrome        # observable Chrome demo (needs --chrome)
just demo-hop           # Amazon cart workflow — stops before purchase
just demo-blog          # headless blog summarize via hop + Playwright
```

## Production / CI

GitHub Actions runs on `main` PRs/pushes: Node 22 → `npm ci` → `preflight:strict` → `smoke` → uploads `artifacts/playwright/`.

Local equivalent: `npm run ci` or `just ci`.

## Repo map

```
.claude/     product runtime — skills, agents, commands
stories/     QA YAML fixtures
examples/    curated demo apps (01–05)
artifacts/   run outputs (gitignored contents)
scripts/     preflight and helpers
docs/        architecture, ops, demos, migration, troubleshooting
archive/     unsupported experiments (not product surface)
justfile     operator entrypoints
```

## Docs

- [Architecture](docs/ARCHITECTURE.md) — four-layer contracts
- [Operations](docs/OPERATIONS.md) — artifacts, parallel runs, cleanup
- [Demos](docs/DEMOS.md) — live demo tracks + recovery
- [Migration](docs/MIGRATION.md) — early-2026 → July 2026 paths
- [Troubleshooting](docs/TROUBLESHOOTING.md) — fast fixes

## Master AI Agentic Coding

Learn patterns with [Tactical Agentic Coding](https://agenticengineer.com/tactical-agentic-coding?y=bows) · [IndyDevDan](https://www.youtube.com/@indydevdan)
