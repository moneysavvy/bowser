# Architecture

Bowser is a four-layer agentic browser system. Each layer has one job and delegates down.

## Layers

| Layer | Name | Role | Location |
|-------|------|------|----------|
| 4 | Just | Operator UX — one command to run workflows | `justfile` |
| 3 | Command | Orchestration — discover, fan-out, aggregate | `.claude/commands/` |
| 2 | Subagent | Scale — isolated workers, structured reports | `.claude/agents/` |
| 1 | Skill | Capability — drive browser via CLI or Chrome MCP | `.claude/skills/` |

### Contracts

**Skills** — raw adapters only. No business workflows, no multi-story fan-out.

**Subagents** — one unit of work (one story / one task). Strict report format. Named browser sessions for Playwright.

**Commands** — routing and aggregation only. Resolve mode (Chrome vs Playwright), discover stories, spawn agents, normalize results, write `summary.md` under the run dir.

**Just recipes** — stable names for humans, CI, and other agents. Prefer `just preflight`, `just demo-*`, `just smoke-*`.

## Dual modes

```
Claude Code
├── claude-bowser-agent
│   └── claude-bowser skill → Chrome MCP → your Chrome
├── playwright-bowser-agent
│   └── playwright-bowser skill → playwright-cli → Chromium sessions
└── bowser-qa-agent
    └── playwright-bowser skill → step screenshots + PASS/FAIL report
```

| | Claude-Bowser | Playwright-Bowser |
|--|---------------|-------------------|
| Browser | Real Chrome | Isolated Chromium |
| Parallel | No | Yes (`-s=name`) |
| Auth | Existing profile | Explicit login / `state-save` |
| Best for | Live demos, personal automation | QA, CI, scale |

## Extension rules

1. New capability → new or extended **skill**
2. New parallel worker shape → thin **agent** wrapping a skill
3. New multi-step product workflow → **command** under `.claude/commands/`
4. New operator entrypoint → **just** recipe that calls the command/skill
5. Unsupported experiments → `archive/` (never promote silently to root)

## Stories

YAML under `stories/*.yaml`. Discovered by `/ui-review`. Drop a file → next run picks it up.
