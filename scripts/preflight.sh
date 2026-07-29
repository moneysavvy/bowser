#!/usr/bin/env bash
# Bowser preflight — verify environment before demos / QA runs.
# Exit 0 = ready (warnings allowed unless BOWSER_STRICT=1 / CI=true)
# Exit 1 = blocking failures (or warnings in strict mode)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STRICT=0
if [[ "${BOWSER_STRICT:-}" == "1" || "${CI:-}" == "true" ]]; then
  STRICT=1
fi

PASS=0
WARN=0
FAIL=0

ok()   { echo "  OK  $*"; PASS=$((PASS + 1)); }
warn() {
  if (( STRICT )); then
    echo "  FAIL $* (strict)"
    FAIL=$((FAIL + 1))
  else
    echo "  WARN $*"; WARN=$((WARN + 1))
  fi
}
bad()  { echo "  FAIL $*"; FAIL=$((FAIL + 1)); }

echo "Bowser preflight — $(date -u +%Y-%m-%dT%H:%MZ)"
echo "Root: $ROOT"
echo "Mode: $([[ $STRICT -eq 1 ]] && echo STRICT || echo normal)"
echo

echo "== Core layout =="
for d in .claude/skills .claude/agents .claude/commands stories artifacts scripts docs; do
  if [[ -d "$d" ]]; then ok "dir $d"; else bad "missing dir $d"; fi
done
[[ -f justfile ]] && ok "justfile" || bad "missing justfile"
[[ -f package.json ]] && ok "package.json" || bad "missing package.json"
[[ -f .claude/skills/playwright-bowser/SKILL.md ]] && ok "playwright-bowser skill" || bad "playwright-bowser skill missing"
[[ -f .claude/skills/claude-bowser/SKILL.md ]] && ok "claude-bowser skill" || bad "claude-bowser skill missing"
echo

echo "== Node =="
if command -v node >/dev/null 2>&1; then
  NODE_V="$(node -v 2>/dev/null || true)"
  ok "node $NODE_V"
  MAJOR="$(echo "$NODE_V" | sed -E 's/^v([0-9]+).*/\1/')"
  if [[ -n "$MAJOR" ]] && (( MAJOR < 20 )); then
    bad "Node $NODE_V — require Node >= 20"
  fi
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
  bad "node not found — install Node 20+"
fi
echo

echo "== Playwright CLI =="
PW=""
if [[ -x "$ROOT/node_modules/.bin/playwright-cli" ]]; then
  PW="$ROOT/node_modules/.bin/playwright-cli"
elif command -v playwright-cli >/dev/null 2>&1; then
  PW="$(command -v playwright-cli)"
fi

if [[ -n "$PW" ]]; then
  PW_VER="$("$PW" --version 2>/dev/null || echo unknown)"
  ok "playwright-cli at $PW ($PW_VER)"
  if [[ "$PW_VER" == *alpha* ]]; then
    warn "alpha CLI detected — pin @playwright/cli@0.1.17 (npm i && npm i -g @playwright/cli@0.1.17)"
  fi
  if [[ "$PW_VER" != "0.1.17" && "$PW_VER" != *unknown* ]]; then
    warn "expected @playwright/cli 0.1.17 for July 2026 pin — found $PW_VER"
  fi
  if "$PW" list >/dev/null 2>&1; then
    ok "playwright-cli list works"
  else
    warn "playwright-cli list failed — try: playwright-cli install-browser"
  fi
else
  bad "playwright-cli missing — run: npm install && npx playwright-cli install-browser"
fi
echo

echo "== Claude Code =="
if command -v claude >/dev/null 2>&1; then
  CLAUDE_V="$(claude --version 2>/dev/null | head -1 || echo unknown)"
  ok "claude ($CLAUDE_V)"
  if (( ! STRICT )); then
    warn "Claude-Bowser demos require: claude --chrome (not checked here)"
  else
    ok "skipping chrome MCP check in CI/strict"
  fi
else
  if (( STRICT )); then
    ok "claude optional in CI (CLI smoke only)"
  else
    bad "claude CLI missing — install Claude Code for agent demos"
  fi
fi
echo

echo "== Just =="
if command -v just >/dev/null 2>&1; then
  ok "just $(just --version 2>/dev/null | head -1)"
else
  warn "just missing — brew install just (npm scripts still work)"
fi
echo

echo "== Stories & artifacts =="
STORY_COUNT="$(find stories -name '*.yaml' 2>/dev/null | wc -l | tr -d ' ')"
if (( STORY_COUNT > 0 )); then ok "$STORY_COUNT YAML stories in stories/"; else warn "no stories/*.yaml found"; fi
mkdir -p artifacts
if [[ -w artifacts ]]; then ok "artifacts/ writable"; else bad "artifacts/ not writable"; fi
echo

echo "== Secrets hygiene =="
if [[ -f .env ]]; then
  ok ".env present (gitignored)"
elif (( STRICT )); then
  ok "no .env in CI/strict (expected — agent keys not required for CLI smoke)"
else
  warn "no .env — copy .env.sample if agent demos need ANTHROPIC_API_KEY"
fi
if git check-ignore -q .env 2>/dev/null || [[ ! -f .env ]]; then
  # When .env is absent, check-ignore may fail; still verify pattern exists in .gitignore
  if grep -qE '^\.env$' .gitignore 2>/dev/null; then
    ok ".env is gitignored"
  else
    bad ".env is NOT listed in .gitignore"
  fi
else
  bad ".env exists but is NOT gitignored"
fi
if git ls-files --error-unmatch .claude/settings.json >/dev/null 2>&1; then
  if grep -Ei 'sk-|api[_-]?key|AUTH_TOKEN|password\s*[:=]' .claude/settings.json >/dev/null 2>&1; then
    bad ".claude/settings.json contains secret-like values — remove before push"
  else
    ok ".claude/settings.json has no secret-like strings"
  fi
fi
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
