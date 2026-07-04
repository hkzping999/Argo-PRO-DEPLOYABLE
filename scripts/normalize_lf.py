#!/usr/bin/env python3
from pathlib import Path
patterns = [
    "*.sh", "*.conf", "*.md", "*.txt", "*.json", "*.yml", "*.yaml",
    ".gitattributes", ".editorconfig",
    "modules/**/*.sh", "scripts/**/*.sh", "scripts/**/*.py", "tests/**/*.sh", "docs/**/*.md", ".github/**/*.yml",
]
files = []
for pat in patterns:
    files.extend(Path('.').glob(pat))
changed = 0
for p in sorted(set(files)):
    if not p.is_file():
        continue
    b = p.read_bytes()
    if b"\0" in b:
        continue
    fixed = b.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    if not fixed.endswith(b"\n"):
        fixed += b"\n"
    if fixed != b:
        p.write_bytes(fixed)
        print(f"normalized: {p}")
        changed += 1
print(f"changed files: {changed}")
