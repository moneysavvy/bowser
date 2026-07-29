# Curated examples

Supported local demo apps for Bowser QA stories. Default port: **5500**.

| App | URL | Story |
|-----|-----|-------|
| `01-todo-app` | http://127.0.0.1:5500/01-todo-app/ | `stories/01-todo-app.yaml` |
| `02-realtime-chat` | http://127.0.0.1:5500/02-realtime-chat/ | `stories/02-realtime-chat.yaml` |
| `03-analytics-dashboard` | http://127.0.0.1:5500/03-analytics-dashboard/ | `stories/03-analytics-dashboard.yaml` |
| `04-ecommerce-gallery` | http://127.0.0.1:5500/04-ecommerce-gallery/ | `stories/04-ecommerce-gallery.yaml` |
| `05-kanban-board` | http://127.0.0.1:5500/05-kanban-board/ | `stories/05-kanban-board.yaml` |

```bash
# Terminal A
just serve-examples

# Terminal B — readiness + screenshots for all apps
just smoke-examples

# Agent QA against one file (server must be up)
just ui-review filter=01-todo
```

Generated apps 06–15 and fast-build tooling live in `archive/examples-generated/` and are **unsupported**.
