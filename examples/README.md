# Curated examples

Supported local demo apps for Bowser QA stories.

| App | Port hint | Story |
|-----|-----------|-------|
| `01-todo-app` | serve `examples/` | `stories/01-todo-app.yaml` |
| `02-realtime-chat` | | `stories/02-realtime-chat.yaml` |
| `03-analytics-dashboard` | | `stories/03-analytics-dashboard.yaml` |
| `04-ecommerce-gallery` | | — |
| `05-kanban-board` | | `stories/05-kanban-board.yaml` |

```bash
cd examples && python3 -m http.server 5500
# open http://127.0.0.1:5500/01-todo-app/
```

Generated apps 06–15 and fast-build tooling live in `archive/examples-generated/` and are **unsupported**.
