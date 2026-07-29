# Operations

## Artifacts layout

```
artifacts/
├── qa/<timestamp>_<id>/           # ui-review / bowser-qa-agent
│   ├── <story-file>/<story-slug>/ # step screenshots
│   ├── summary.md                 # aggregated report
│   └── report.json                # optional machine-readable
├── chrome/<timestamp>_<id>/       # Claude-Bowser demos
├── playwright/<timestamp>_<id>/   # ad-hoc playwright-bowser runs
└── legacy-screenshots/            # pre-migration captures
```

Contents of `artifacts/**` are gitignored (directory kept via `.gitkeep`).

## Parallel execution

- Playwright: one named session per agent (`-s=story-slug`)
- `/ui-review` fans out `bowser-qa-agent` teammates; each gets its own `SCREENSHOT_PATH`
- Never share one Playwright session across parallel agents
- Claude-Bowser: single instance only — do not fan out Chrome MCP tasks

## Headed vs headless

| Flag | Use |
|------|-----|
| default / `false` | Headless smoke / CI |
| `true` / `headed` | Visible debug / demos |

```bash
just ui-review headed=headed filter=hackernews
just smoke-playwright headed=true
```

## Cleanup

```bash
playwright-cli close-all
playwright-cli kill-all          # zombies
rm -rf artifacts/qa/*            # wipe QA runs (keep .gitkeep)
```

## Environment

- Run `just preflight` before demos or CI jobs
- Pin localhost ports in stories; start the app and confirm readiness before QA
- Persist auth with `playwright-cli state-save` / `state-load` when not using Chrome mode
