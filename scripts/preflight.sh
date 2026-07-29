#!/usr/bin/env bash
# Bowser preflight — verify environment before demos / QA runs.
# Exit 0 = ready, 1 = blocking failures, 2 = warnings only (still usable).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0
WARN=0
FAIL=0

ok()   { echo "  OK  $*"; PASS=$((PASS + 1)); }
warn() { echo "  WARN $*"; WARN=$((WARN + 1)); }
bad()  { echo "  FAIL $*"; FAIL=$((FAIL + 1)); }

echo "Bowser preflight — $(date -u +%Y-%m-%dT%H:%MZ)"
echo "Root: $ROOT"
echo

echo "== Core layout =="
for d in .claude/skills .claude/agents .claude/commands stories artifacts scripts docs; do
  if [[ -d "$d" ]]; then ok "dir $d"; else bad "missing dir $d"; fi
done
[[ -f justfile ]] && ok "justfile" || bad "missing justfile"
[[ -f .claude/skills/playwright-bowser/SKILL.md ]] && ok "playwright-bowser skill" || bad "playwright-bowser skill missing"
[[ -f .claude/skills/claude-bowser/SKILL.md ]] && ok "claude-bowser skill" || bad "claude-bowser skill missing"
echo

echo "== Node =="
if command -v node >/dev/null 2>&1; then
  NODE_V="$(node -v 2>/dev/null || true)"
  ok "node $NODE_V"
  # Starship / slow node hint (darwin)
  START=$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null || echo 0)
  node -e 'process.exit(0)' >/dev/null 2>&1 || true
  END=$(python3 -c 'import time; print(int(time.time()*1000))' 2>/dev/null || echo 0)
  if [[ "$START" != 0 && "$END" != 0 ]]; then
    DELTA=$((END - START))
    if (( DELTA > 2000 )); then
      warn "node startup ~${DELTA}ms — raise starship command_timeout if prompts hang"
    else
      ok "node startup ~${DELTA}ms"
    fi
  fi
else
  bad "node not found — install Node 20+ (Bowser demos expect modern Node)"
fi
echo

echo "== Playwright CLI =="
if command -v playwright-cli >/dev/null 2>&1; then
  PW_PATH="$(command -v playwright-cli)"
  PW_VER="$(playwright-cli --version 2>/dev/null || echo unknown)"
  ok "playwright-cli at $PW_PATH ($PW_VER)"
  NPM_LATEST="$(npm view @playwright/cli version 2>/dev/null || echo '')"
  if [[ -n "$NPM_LATEST" ]]; then
    echo "     npm latest @playwright/cli: $NPM_LATEST"
    if [[ "$PW_VER" == *alpha* ]]; then
      warn "installed CLI looks like an alpha Playwright build — prefer: npm i -g @playwright/cli@latest"
    fi
  fi
  if playwright-cli list >/dev/null 2>&1; then
    ok "playwright-cli list works"
  else
    warn "playwright-cli list failed — try: playwright-cli install-browser"
  fi
else
  bad "playwright-cli missing — run: npm i -g @playwright/cli@latest && playwright-cli install-browser"
fi
echo

echo "== Claude Code =="
if command -v claude >/dev/null 2>&1; then
  CLAUDE_V="$(claude --version 2>/dev/null | head -1 || echo unknown)"
  ok "claude ($CLAUDE_V)"
  warn "Claude-Bowser demos require: claude --chrome (not checked here)"
else
  bad "claude CLI missing — install Claude Code"
fi
echo

echo "== Just =="
if command -v just >/dev/null 2>&1; then
  ok "just $(just --version 2>/dev/null | head -1)"
else
  warn "just missing — brew install just (recipes won't run)"
fi
echo

echo "== Stories & artifacts =="
STORY_COUNT="$(find stories -name '*.yaml' 2>/dev/null | wc -l | tr -d ' ')"
if (( STORY_COUNT > 0 )); then ok "$STORY_COUNT YAML stories in stories/"; else warn "no stories/*.yaml found"; fi
mkdir -p artifacts
if [[ -w artifacts ]]; then ok "artifacts/ writable"; else bad "artifacts/ not writable"; fi
echo

echo "== Mode routing reminder =="
echo "  Claude-Bowser  → real Chrome, auth/cookies, live demos     (claude --chrome)"
echo "  Playwright-Bowser → isolated/parallel/CI QA              (playwright-cli)"
echo

echo "== Summary =="
echo "  passed=$PASS  warnings=$WARN  failures=$FAIL"
if (( FAIL > 0 )); then
  echo "  RESULT: NOT READY — fix FAIL items, then re-run: just preflight"
  exit 1
fi
if (( WARN > 0 )); then
  echo "  RESULT: READY WITH WARNINGS"
  exit 0
fi
echo "  RESULT: READY"
exit 0
