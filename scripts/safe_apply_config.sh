#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARGOX_ROOT="$ROOT"
# shellcheck source=../modules/core/bootstrap.sh
source "$ROOT/modules/core/bootstrap.sh"
argox_set_default_runtime

SRC="${1:-}"
DST="${2:-${WORK_DIR}/inbound.json}"
OUTBOUND="${3:-${WORK_DIR}/outbound.json}"
[ -s "$SRC" ] || error "Source inbound config not found: $SRC"

validate_json_file "$SRC" || error "Source JSON is invalid: $SRC"
if [ -x "$XRAY_BIN" ]; then
  if [ -s "$OUTBOUND" ]; then
    xray_test_config "$SRC" "$OUTBOUND" "/tmp/argox-safe-apply-test.log" || { cat /tmp/argox-safe-apply-test.log >&2 || true; error "xray config test failed; not applying"; }
  else
    xray_test_config "$SRC" "" "/tmp/argox-safe-apply-test.log" || { cat /tmp/argox-safe-apply-test.log >&2 || true; error "xray config test failed; not applying"; }
  fi
else
  warning "Xray binary not executable; applying without xray -test"
fi

mkdir -p "$(dirname "$DST")"
backup_file_once "$DST"
install -m 600 "$SRC" "$DST"
info "Applied config to $DST"
