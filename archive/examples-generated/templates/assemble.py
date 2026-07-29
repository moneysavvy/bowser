#!/usr/bin/env python3
"""Assemble an app from raw model output + base template."""

import json
import re
import sys

if len(sys.argv) < 6:
    print(
        "Usage: assemble.py <raw_file> <template_file> <output_file> <title> <max_width>",
        file=sys.stderr,
    )
    sys.exit(1)

raw_file, tmpl_file, out_file, title, width = sys.argv[1:6]

with open(raw_file) as f:
    raw = f.read()

m = re.search(r"\{[\s\S]*\}", raw)
if not m:
    print(f"ERROR: no JSON found in {raw_file}", file=sys.stderr)
    sys.exit(1)

try:
    data = json.loads(m.group())
except json.JSONDecodeError as e:
    print(f"ERROR: invalid JSON in {raw_file}: {e}", file=sys.stderr)
    sys.exit(1)

with open(tmpl_file) as f:
    template = f.read()

template = template.replace("{{TITLE}}", title)
template = template.replace("{{MAX_WIDTH}}", width)
template = template.replace("{{EXTRA_HEAD}}", data.get("extra_head", ""))
template = template.replace("{{APP_STYLES}}", data.get("app_styles", ""))
template = template.replace("{{APP_HTML}}", data.get("app_html", ""))
template = template.replace("{{APP_SCRIPT}}", data.get("app_script", ""))

with open(out_file, "w") as f:
    f.write(template)

print(f"OK: {out_file}")
