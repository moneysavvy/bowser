#!/usr/bin/env bash
# Serve curated examples and smoke-load each app with Playwright CLI (no Claude).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PORT="${BOWSER_EXAMPLES_PORT:-5500}"
HOST="127.0.0.1"
BASE="http://${HOST}:${PORT}"

if [[ -x "$ROOT/node_modules/.bin/playwright-cli" ]]; then
  PW="$ROOT/node_modules/.bin/playwright-cli"
elif command -v playwright-cli >/dev/null 2>&1; then
  PW="$(command -v playwright-cli)"
else
  echo "FAIL: playwright-cli not found. Run: npm install"
  exit 1
fi

APPS=(
  01-todo-app
  02-realtime-chat
  03-analytics-dashboard
  04-ecommerce-gallery
  05-kanban-board
)

RUN_ID="examples-smoke_$(date +%Y%m%d_%H%M%S)"
OUT="artifacts/playwright/${RUN_ID}"
mkdir -p "$OUT"

STARTED_SERVER=0
SERVER_PID=""
cleanup() {
  if [[ "${STARTED_SERVER:-0}" -eq 1 && -n "${SERVER_PID}" ]]; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
  fi
  "$PW" -s=examples-smoke close >/dev/null 2>&1 || true
}
trap cleanup EXIT

if command -v lsof >/dev/null 2>&1 && lsof -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Port $PORT already in use — reusing existing server"
else
  python3 -m http.server "$PORT" --directory examples >/dev/null 2>&1 &
  SERVER_PID=$!
  STARTED_SERVER=1
fi

for _ in $(seq 1 40); do
  if curl -sf -o /dev/null "$BASE/01-todo-app/"; then
    break
  fi
  sleep 0.25
done

if ! curl -sf -o /dev/null "$BASE/01-todo-app/"; then
  echo "FAIL: examples server not ready at $BASE"
  exit 1
fi
echo "Serving examples at $BASE"

FAILS=0
{
  echo "# Examples smoke report"
  echo
  echo "- time: $(date -u +%Y-%m-%dT%H:%MZ)"
  echo "- base: $BASE"
  echo
} > "$OUT/summary.md"

PLAYWRIGHT_MCP_VIEWPORT_SIZE=1440x900 "$PW" -s=examples-smoke open "$BASE/01-todo-app/" >/dev/null

for app in "${APPS[@]}"; do
  URL="$BASE/$app/"
  echo "Checking $URL"
  if ! curl -sf -o /dev/null "$URL"; then
    echo "  FAIL curl $app"
    echo "- $app: FAIL (HTTP)" >> "$OUT/summary.md"
    FAILS=$((FAILS + 1))
    continue
  fi
  "$PW" -s=examples-smoke goto "$URL" >/dev/null
  "$PW" -s=examples-smoke screenshot --filename="$OUT/${app}.png" >/dev/null
  if [[ -f "$OUT/${app}.png" ]]; then
    echo "  OK $app"
    echo "- $app: PASS ($OUT/${app}.png)" >> "$OUT/summary.md"
  else
    echo "  FAIL screenshot $app"
    echo "- $app: FAIL (screenshot)" >> "$OUT/summary.md"
    FAILS=$((FAILS + 1))
  fi
done

"$PW" -s=examples-smoke close >/dev/null 2>&1 || true
trap - EXIT
if [[ "${STARTED_SERVER:-0}" -eq 1 ]]; then
  kill "$SERVER_PID" >/dev/null 2>&1 || true
fi

if (( FAILS > 0 )); then
  echo "result: FAIL ($FAILS)" >> "$OUT/summary.md"
  echo "FAIL: $FAILS app(s) — see $OUT/summary.md"
  exit 1
fi

echo "result: PASS" >> "$OUT/summary.md"
echo "PASS: $OUT/summary.md"
exit 0
