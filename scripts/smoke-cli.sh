#!/usr/bin/env bash
# Deterministic Playwright CLI smoke — no Claude required (CI-safe).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -x "$ROOT/node_modules/.bin/playwright-cli" ]]; then
  PW="$ROOT/node_modules/.bin/playwright-cli"
elif command -v playwright-cli >/dev/null 2>&1; then
  PW="$(command -v playwright-cli)"
else
  echo "FAIL: playwright-cli not found. Run: npm install"
  exit 1
fi

RUN_ID="cli-smoke_$(date +%Y%m%d_%H%M%S)"
OUT="artifacts/playwright/${RUN_ID}"
mkdir -p "$OUT"
SESSION="bowser-ci-smoke"

cleanup() {
  "$PW" -s="$SESSION" close >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Smoke: using $PW ($("$PW" --version 2>/dev/null || echo unknown))"
echo "Artifacts: $OUT"

PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900 "$PW" -s="$SESSION" open https://example.com
"$PW" -s="$SESSION" screenshot --filename="$OUT/example.png"
"$PW" -s="$SESSION" close
trap - EXIT

if [[ ! -f "$OUT/example.png" ]]; then
  echo "FAIL: screenshot missing"
  exit 1
fi

{
  echo "# CLI smoke report"
  echo
  echo "- time: $(date -u +%Y-%m-%dT%H:%MZ)"
  echo "- cli: $("$PW" --version 2>/dev/null || echo unknown)"
  echo "- url: https://example.com"
  echo "- screenshot: $OUT/example.png"
  echo "- result: PASS"
} > "$OUT/summary.md"

echo "PASS: $OUT/summary.md"
exit 0
