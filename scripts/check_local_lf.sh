#!/usr/bin/env bash
set -euo pipefail
files=(argox.sh argox-next.sh config-pqc-strong.conf README.md SHA256SUMS.txt)
status=0
for f in "${files[@]}"; do
  if [ ! -f "$f" ]; then
    echo "missing: $f"
    status=1
    continue
  fi
  read -r lf cr bytes < <(python3 - "$f" <<'PY'
from pathlib import Path
import sys
b = Path(sys.argv[1]).read_bytes()
print(b.count(b"\n"), b.count(b"\r"), len(b))
PY
)
  printf '%-30s LF=%-6s CR=%-3s bytes=%s\n' "$f" "$lf" "$cr" "$bytes"
  if [ "$cr" != "0" ]; then status=1; fi
done
exit "$status"
