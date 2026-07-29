# Bowser July 2026 Modernization — Design

**Date:** 2026-07-29  
**Status:** Approved (Approach C — Hybrid product layout)  
**Source:** Bowser July 2026 Modernization Guide + brainstorming

## Intent

Productize Bowser as a terminal-first, autonomous, observable agentic browser platform. Preserve the four-layer stack (Skill → Subagent → Command → Just) and dual modes (Claude-Bowser / Playwright-Bowser). Separate core runtime from examples, generated apps, and adjacent experiments.

## Approach

**C — Hybrid product layout:** Keep `.claude/` at repo root (Claude Code contract). Add `docs/`, `stories/`, `artifacts/`, `scripts/`, `archive/`. Curate `examples/`. Refresh skills/justfile/docs to July 2026 Playwright CLI (`@playwright/cli@0.1.17+`) and current Claude Code.

## Target shape

```
bowser/
├── README.md
├── justfile
├── .claude/          # product runtime
├── stories/          # QA YAML
├── examples/         # curated demos (01–05 + optional polish)
├── artifacts/        # screenshots, logs, reports (contents gitignored)
├── scripts/          # preflight, helpers
├── docs/             # operator docs + plans/
└── archive/          # shannon, hyperbrowser, unsupported examples, one-offs
```

## Layer contracts

| Layer | Role | Must not |
|-------|------|----------|
| Skill | Raw capability adapter | Business logic, fan-out |
| Subagent | Isolated worker, I/O contract | Cross-story orchestration |
| Command | Routing, fan-out, aggregation | Browser primitives |
| Just | Operator UX / CI entrypoints | Hidden policy |

## Mode routing

- **Claude-Bowser:** identity, cookies, live demos → requires `claude --chrome`
- **Playwright-Bowser:** scale, CI, parallel QA → `playwright-cli` named sessions

## Artifacts

All major runs write under `artifacts/<run-type>/<timestamp>_<id>/` with screenshots, `summary.md`, and optional `report.json`.

## Acceptance

1. Core identifiable from root in <1 minute  
2. `just preflight` verifies environment  
3. `just demo-chrome` and `just demo-qa` exist  
4. Workflows emit inspectable artifacts  
5. Docs: README + ARCHITECTURE/OPERATIONS/DEMOS/MIGRATION/TROUBLESHOOTING  
6. Unsupported material isolated under `archive/`
