# Bowser operator surface — July 2026
# Layers: Skill → Subagent → Command → Just

default_prompt := "Get the current date, then go to https://simonwillison.net/, find the latest blog post by Simon, summarize it, and give it a rating out of 10."

default_qa_prompt := "Navigate to https://news.ycombinator.com/. Verify the front page loads with posts. Click 'More' to go to the next page. Verify page 2 loads with a new set of posts. Go back to page 1. Click into the first post's comments link. Verify the comments page loads and at least one comment is visible."

default_hop_demo_prompt := "pack of 10 sketch notebooks"

# List available commands
default:
    @just --list

# ─── Preflight / ops ─────────────────────────────────────────

# Verify Node, playwright-cli, Claude Code, stories, artifacts
preflight:
    bash scripts/preflight.sh

# CI-strict preflight (warnings become failures)
preflight-strict:
    BOWSER_STRICT=1 bash scripts/preflight.sh

# Deterministic Playwright CLI smoke (no Claude)
smoke:
    bash scripts/smoke-cli.sh

# Serve curated examples on :5500 (python http.server)
serve-examples port="5500":
    python3 -m http.server {{port}} --directory examples

# Smoke-load all curated example apps (starts server if needed)
smoke-examples:
    bash scripts/smoke-examples.sh

# Local CI gate: strict preflight + CLI smoke + examples smoke
ci:
    just preflight-strict
    just smoke
    just smoke-examples

# ─── Live demos (curated) ────────────────────────────────────

# Observable Chrome demo (requires claude --chrome / Chrome MCP)
demo-chrome prompt="Open https://news.ycombinator.com, screenshot the front page, list the top 3 story titles, then stop.":
    claude --dangerously-skip-permissions --model opus --chrome "/claude-bowser {{prompt}}"

# Parallel isolated QA demo against hackernews stories
demo-qa:
    just preflight
    claude --dangerously-skip-permissions --model opus "/ui-review false hackernews"

# Saved hop workflow demo (Chrome; stops before purchase)
demo-hop prompt=default_hop_demo_prompt:
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 && claude --dangerously-skip-permissions --model opus --chrome "/bowser:hop-automate amazon-add-to-cart {{prompt}}"

# Headless blog summarize (Playwright path, no Chrome required)
demo-blog url="https://simonwillison.net/":
    claude --dangerously-skip-permissions --model opus "/bowser:hop-automate blog-summarizer \"{{url}}\" playwright headless"

# Intentional failure demo — shows preflight repair path
demo-failure:
    @echo "Simulating missing playwright-cli detection via preflight..."
    @bash scripts/preflight.sh || true
    @echo ""
    @echo "If FAIL items appeared, repair with the printed commands, then: just preflight"

# ─── Layer 1: Skill (Capability) ─────────────────────────────

smoke-playwright headed="true" prompt=default_prompt:
    claude --dangerously-skip-permissions --model opus "/playwright-bowser (headed: {{headed}}) {{prompt}}"

smoke-chrome prompt=default_prompt:
    claude --dangerously-skip-permissions --model opus --chrome "/claude-bowser {{prompt}}"

# Deprecated aliases
test-playwright-skill headed="true" prompt=default_prompt:
    @echo "DEPRECATED: use 'just smoke-playwright' — forwarding..."
    just smoke-playwright headed="{{headed}}" prompt="{{prompt}}"

test-chrome-skill prompt=default_prompt:
    @echo "DEPRECATED: use 'just smoke-chrome' — forwarding..."
    just smoke-chrome prompt="{{prompt}}"

# ─── Layer 2: Subagent (Scale) ───────────────────────────────

test-playwright-agent headed="true" prompt=default_prompt:
    claude --dangerously-skip-permissions --model opus "Use a @playwright-bowser-agent to do this: (headed: {{headed}}) {{prompt}}"

test-chrome-agent prompt=default_prompt:
    claude --dangerously-skip-permissions --model opus --chrome "Use a @claude-bowser-agent to do this: {{prompt}}"

test-qa headed="true" prompt=default_qa_prompt:
    claude --dangerously-skip-permissions --model opus "Use a @bowser-qa-agent: (headed: {{headed}}) {{prompt}}"

# ─── Layer 3: Command (Orchestration) ────────────────────────

hop workflow="amazon-add-to-cart" prompt="pack of 10 sketch notebooks" *flags="":
    export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 && claude --dangerously-skip-permissions --model opus --chrome "/bowser:hop-automate {{workflow}} {{prompt}} {{flags}}"

ui-review headed="false" filter="" *flags="":
    claude --dangerously-skip-permissions --model opus "/ui-review {{headed}} {{filter}} {{flags}}"

# ─── Layer 4: Convenience ────────────────────────────────────

automate-amazon prompt=default_hop_demo_prompt:
    just hop amazon-add-to-cart "{{prompt}}"

summarize-blog url="https://simonwillison.net/":
    just demo-blog url="{{url}}"
