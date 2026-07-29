#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$DIR/templates/base.html"
SPECS="$DIR/templates/specs.json"
ASSEMBLE="$DIR/templates/assemble.py"
SCOPE="tolas-projects-41ed0696"
LOGDIR="$DIR/.build-logs"
mkdir -p "$LOGDIR"

TEMPLATE_LINES=$(wc -l < "$TEMPLATE" | tr -d ' ')
NUM_APPS=$(python3 -c "import json; print(len(json.load(open('$SPECS'))['apps']))")

echo "============================================"
echo "  FAST PARALLEL APP BUILDER"
echo "  Template: ${TEMPLATE_LINES} lines shared CSS"
echo "  Apps: ${NUM_APPS}"
echo "  Model: MiniMax-M2.5-highspeed"
echo "============================================"
echo ""

START_ALL=$(python3 -c "import time; print(time.time())")

APP_DATA=$(python3 -c "
import json
specs = json.load(open('$SPECS'))
for a in specs['apps']:
    print(f\"{a['id']}|{a['title']}|{a['max_width']}|{a['prompt']}\")
")

PIDS=()
APP_IDS=()

while IFS='|' read -r APP_ID APP_TITLE APP_WIDTH APP_PROMPT; do
  APP_DIR="$DIR/$APP_ID"
  mkdir -p "$APP_DIR"
  cp "$DIR/01-todo-app/vercel.json" "$APP_DIR/vercel.json" 2>/dev/null || echo '{"rewrites":[{"source":"/(.*)", "destination":"/index.html"}]}' > "$APP_DIR/vercel.json"
  APP_IDS+=("$APP_ID")

  IDX=${#APP_IDS[@]}
  echo "  [$IDX/${NUM_APPS}] Building $APP_ID ..."

  (
    BUILD_START=$(python3 -c "import time; print(time.time())")

    PROMPT="You are filling in an HTML template. Output ONLY a valid JSON object with keys: extra_head, app_styles, app_html, app_script.

- extra_head: any extra CDN <link>/<script> tags. Empty string if none.
- app_styles: CSS rules specific to this app. The base template already provides: cards, buttons (.btn, .btn-primary, .btn-ghost, .btn-danger, .btn-sm), inputs (.input), grids (.grid-2/3/4), stat cards (.stat-card, .stat-value, .stat-label), rows (.row, .row-border), headers (.header h1/p), badges (.badge), animations, responsive breakpoints, and a dark gradient theme. Do NOT duplicate these.
- app_html: HTML markup that goes inside <div id=app>. Use template classes where possible.
- app_script: Vanilla JS code. No <script> tags, just the code.

Keep it concise. No comments. Ensure valid JSON (escape quotes in strings).

APP: ${APP_PROMPT}"

    cd "$DIR/.." && ~/.local/bin/claude -p --dangerously-skip-permissions "$PROMPT" 2>/dev/null > "$LOGDIR/${APP_ID}.raw"

    BUILD_END=$(python3 -c "import time; print(time.time())")
    BUILD_MS=$(python3 -c "print(f'{($BUILD_END - $BUILD_START)*1000:.0f}')")

    python3 "$ASSEMBLE" "$LOGDIR/${APP_ID}.raw" "$TEMPLATE" "$APP_DIR/index.html" "$APP_TITLE" "$APP_WIDTH" 2>"$LOGDIR/${APP_ID}.log"

    if [ -f "$APP_DIR/index.html" ] && [ -s "$APP_DIR/index.html" ]; then
      echo "OK ${BUILD_MS}ms" > "$LOGDIR/${APP_ID}.status"
    else
      echo "FAIL" > "$LOGDIR/${APP_ID}.status"
    fi
  ) &

  PIDS+=($!)
done <<< "$APP_DATA"

echo ""
echo "  All ${NUM_APPS} builds launched in parallel. Waiting..."
echo ""

FAILED=0
for i in "${!PIDS[@]}"; do
  wait "${PIDS[$i]}" 2>/dev/null || true
  APP="${APP_IDS[$i]}"
  STATUS=$(cat "$LOGDIR/${APP}.status" 2>/dev/null || echo "UNKNOWN")
  if [[ "$STATUS" == OK* ]]; then
    MS=$(echo "$STATUS" | awk '{print $2}')
    SIZE=$(wc -c < "$DIR/$APP/index.html" 2>/dev/null | tr -d ' ')
    echo "  ✅ $APP  →  ${MS}  (${SIZE} bytes)"
  else
    echo "  ❌ $APP  →  FAILED"
    cat "$LOGDIR/${APP}.log" 2>/dev/null | head -3
    FAILED=$((FAILED + 1))
  fi
done

END_ALL=$(python3 -c "import time; print(time.time())")
TOTAL=$(python3 -c "print(f'{$END_ALL - $START_ALL:.1f}s')")

echo ""
echo "============================================"
echo "  Total wall time: $TOTAL"
echo "  Passed: $((NUM_APPS - FAILED))/${NUM_APPS}"
echo "============================================"

if [ "${1:-}" = "--deploy" ] && [ $FAILED -eq 0 ]; then
  echo ""
  echo "  Deploying to Vercel..."
  for APP in "${APP_IDS[@]}"; do
    echo -n "  $APP → "
    cd "$DIR/$APP" && vercel --yes --prod --scope "$SCOPE" 2>&1 | tail -1
  done
  echo ""
  echo "  ✅ All deployed!"
fi
