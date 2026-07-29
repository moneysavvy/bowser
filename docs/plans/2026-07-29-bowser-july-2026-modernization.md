# Bowser July 2026 Modernization Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Productize Bowser as a July 2026 agentic browser platform with clear repo boundaries, dual-mode routing, preflight, artifacts, and demo-ready just recipes.

**Architecture:** Keep `.claude/` as Claude Code runtime; isolate examples/experiments under `archive/`; move QA YAML to `stories/`; add `scripts/preflight.sh`, `artifacts/`, and operator docs; refresh Playwright/Claude skills and justfile.

**Tech Stack:** Claude Code, `@playwright/cli` (playwright-cli), just, YAML stories, bash preflight

---

### Task 1: Create directory skeleton and .gitignore

**Files:**
- Create: `artifacts/.gitkeep`, `scripts/.gitkeep`, `archive/README.md`
- Modify: `.gitignore`

**Step 1:** Create dirs and archive README explaining what lives there.

**Step 2:** Gitignore `artifacts/**` except `.gitkeep`; ignore Office lock files `~$*`.

**Step 3:** Commit skeleton.

---

### Task 2: Move non-core material into archive/

**Move to archive:**
- `shannon/` → `archive/shannon/`
- `hyperbrowser-app-examples/` → `archive/hyperbrowser-app-examples/`
- `example-app/` → `archive/example-app/`
- `jcan/` → `archive/jcan/`
- `specs/` → `archive/specs/`
- One-off scripts/media: `app.py`, `test_app.py`, `pyproject.toml`, `uv.lock`, `*.js` inject/upload scripts, `*.py` invoice/research, videos, xlsx, `SHANNON_TEST_REPORT.md`, `architecture-*.md`, `data_output.json`, `comet_research_agent.egg-info/`, `__pycache__/`
- Examples 06–15 + `templates/`, `fast-build.sh`, `manage.sh`, `.build-logs/` → `archive/examples-generated/`
- `HANDOFF.md` → `archive/HANDOFF-2026-02.md`
- `ai_review/` after stories migrated

**Keep at product root:** `.claude/`, `justfile`, `README.md`, `TOOLS.md`, `images/`, curated `examples/01–05`, `docs/`, `screenshots/` (migrate later into artifacts)

---

### Task 3: Migrate stories and update command paths

**Files:**
- Move: `ai_review/user_stories/*.yaml` → `stories/`
- Modify: `.claude/commands/ui-review.md`, `.claude/agents/bowser-qa-agent.md`
- Paths: `STORIES_DIR=stories`, screenshots → `artifacts/qa/`

---

### Task 4: Preflight script + just recipes

**Files:**
- Create: `scripts/preflight.sh`
- Rewrite: `justfile`

Checks: node, playwright-cli version/path, `playwright-cli list`, claude presence, optional `--chrome` note, starship/slow-node warning hint, stories dir, artifacts writable.

Recipes: `preflight`, `demo-chrome`, `demo-qa`, `demo-hop`, `smoke-playwright`, `smoke-chrome`, keep layer tests with deprecation aliases.

---

### Task 5: Refresh skills for July 2026

**Files:**
- Modify: `.claude/skills/playwright-bowser/SKILL.md`
- Modify: `.claude/skills/claude-bowser/SKILL.md`

Update install (`npm i -g @playwright/cli@latest`), `install-browser`, `show`/`devtools`, session lifecycle, artifact paths, auth bootstrap notes.

---

### Task 6: Operator documentation

**Files:**
- Rewrite: `README.md` (short)
- Create: `docs/ARCHITECTURE.md`, `docs/OPERATIONS.md`, `docs/DEMOS.md`, `docs/MIGRATION.md`, `docs/TROUBLESHOOTING.md`
- Archive old HANDOFF; slim TOOLS.md pointer or leave as reference

---

### Task 7: Demo stories + acceptance verify

**Files:**
- Ensure: `stories/hackernews.yaml` present
- Create: `stories/demo-smoke.yaml` if needed
- Run: `just preflight`
- Verify tree legibility
- Commit final state

---

### Task 8: Deprecation shims

Where old paths were referenced (`ai_review/user_stories`, `screenshots/bowser-qa`), update agents/commands; add `archive/README.md` note that archived material is unsupported.
