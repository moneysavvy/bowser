#!/bin/bash
SCOPE="tolas-projects-41ed0696"
APPS=("01-todo-app" "02-realtime-chat" "03-analytics-dashboard" "04-ecommerce-gallery" "05-kanban-board" "06-pomodoro-timer" "07-expense-tracker" "08-markdown-editor" "09-weather-dashboard" "10-quiz-game" "11-agent-dashboard" "12-code-diff" "13-json-explorer" "14-regex-tester" "15-invoice-dashboard")
URLS=("https://01-todo-app.vercel.app" "https://02-realtime-chat.vercel.app" "https://03-analytics-dashboard.vercel.app" "https://04-ecommerce-gallery.vercel.app" "https://05-kanban-board.vercel.app" "https://06-pomodoro-timer.vercel.app" "https://07-expense-tracker.vercel.app" "https://08-markdown-editor.vercel.app" "https://09-weather-dashboard.vercel.app" "https://10-quiz-game.vercel.app" "https://11-agent-dashboard.vercel.app" "https://12-code-diff.vercel.app" "https://13-json-explorer.vercel.app" "https://14-regex-tester.vercel.app" "https://15-invoice-dashboard.vercel.app")
DIR="$(cd "$(dirname "$0")" && pwd)"

case "${1:-help}" in
  list)
    echo "📋 Deployed Examples:"
    echo ""
    for i in "${!APPS[@]}"; do
      STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${URLS[$i]}" 2>/dev/null)
      if [ "$STATUS" = "200" ]; then ICON="✅"; else ICON="❌"; fi
      echo "  $ICON ${APPS[$i]}  →  ${URLS[$i]}"
    done
    echo ""
    ;;

  delete)
    if [ -z "$2" ]; then
      echo "Usage: $0 delete <app-name|all>"
      echo "Apps: ${APPS[*]}"
      exit 1
    fi

    if [ "$2" = "all" ]; then
      echo "🗑️  Deleting ALL examples from Vercel..."
      for app in "${APPS[@]}"; do
        echo "  Removing $app..."
        vercel project rm "$app" --scope "$SCOPE" --yes 2>/dev/null
      done
      echo ""
      read -p "Also delete local files? (y/N) " -n 1 -r
      echo ""
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        for app in "${APPS[@]}"; do
          rm -rf "$DIR/$app"
          rm -f "$DIR/../ai_review/user_stories/${app}.yaml"
        done
        echo "  Local files deleted."
      fi
      echo "✅ All examples removed."
    else
      echo "🗑️  Deleting $2 from Vercel..."
      vercel project rm "$2" --scope "$SCOPE" --yes 2>/dev/null
      read -p "Also delete local files? (y/N) " -n 1 -r
      echo ""
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$DIR/$2"
        rm -f "$DIR/../ai_review/user_stories/${2}.yaml"
        echo "  Local files deleted."
      fi
      echo "✅ $2 removed."
    fi
    ;;

  deploy)
    if [ -z "$2" ]; then
      echo "Deploying ALL examples..."
      for app in "${APPS[@]}"; do
        echo "  Deploying $app..."
        cd "$DIR/$app" && vercel --yes --prod --scope "$SCOPE" 2>&1 | tail -1
      done
    else
      echo "Deploying $2..."
      cd "$DIR/$2" && vercel --yes --prod --scope "$SCOPE" 2>&1 | tail -3
    fi
    echo "✅ Done."
    ;;

  test)
    echo "🧪 Speed testing all examples..."
    echo ""
    TOTAL_START=$(python3 -c "import time; print(time.time())")
    for i in "${!APPS[@]}"; do
      START=$(python3 -c "import time; print(time.time())")
      STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${URLS[$i]}")
      TTFB=$(curl -s -o /dev/null -w "%{time_starttransfer}" "${URLS[$i]}")
      SIZE=$(curl -s "${URLS[$i]}" | wc -c | tr -d ' ')
      END=$(python3 -c "import time; print(time.time())")
      MS=$(python3 -c "print(f'{($END - $START)*1000:.0f}ms')")
      echo "  ${APPS[$i]}:  HTTP $STATUS  |  TTFB ${TTFB}s  |  ${SIZE} bytes  |  $MS"
    done
    TOTAL_END=$(python3 -c "import time; print(time.time())")
    TOTAL=$(python3 -c "print(f'{$TOTAL_END - $TOTAL_START:.1f}s')")
    echo ""
    echo "  Total: $TOTAL"
    echo ""
    ;;

  *)
    echo "Usage: $0 {list|test|deploy [app]|delete <app|all>}"
    echo ""
    echo "Commands:"
    echo "  list              Show all deployed examples with status"
    echo "  test              Speed test all examples (HTTP, TTFB, size)"
    echo "  deploy [app]      Deploy one or all examples to Vercel"
    echo "  delete <app|all>  Delete from Vercel (+ optional local cleanup)"
    echo ""
    echo "Apps: ${APPS[*]}"
    ;;
esac
