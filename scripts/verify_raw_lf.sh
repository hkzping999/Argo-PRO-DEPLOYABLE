#!/usr/bin/env bash
set -euo pipefail
repo_url="${1:-https://raw.githubusercontent.com/hkzping999/Argo-PRO/main}"
files=(argox.sh argox-next.sh config-pqc-strong.conf README.md SHA256SUMS.txt)
for f in "${files[@]}"; do
  tmp="$(mktemp)"
  curl -fsSL "${repo_url%/}/$f" -o "$tmp"
  lf=$(python3 - "$tmp" <<'PY'
from pathlib import Path
import sys
b = Path(sys.argv[1]).read_bytes()
print(b.count(b"\n"))
PY
)
  cr=$(python3 - "$tmp" <<'PY'
from pathlib import Path
import sys
b = Path(sys.argv[1]).read_bytes()
print(b.count(b"\r"))
PY
)
  printf '%-28s LF=%s CR=%s\n' "$f" "$lf" "$cr"
  rm -f "$tmp"
done
