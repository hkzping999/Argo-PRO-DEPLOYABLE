#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail=0
while IFS= read -r f; do
  if bash -n "$f"; then
    printf 'ok   %s\n' "${f#$ROOT/}"
  else
    printf 'fail %s\n' "${f#$ROOT/}" >&2
    fail=1
  fi
done < <(find "$ROOT/modules" "$ROOT/scripts" "$ROOT/tests" -type f -name '*.sh' | sort)

exit "$fail"
