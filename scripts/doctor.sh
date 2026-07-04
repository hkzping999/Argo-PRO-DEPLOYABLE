#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARGOX_ROOT="$ROOT"
# shellcheck source=../modules/core/bootstrap.sh
source "$ROOT/modules/core/bootstrap.sh"
argox_set_default_runtime

status_line() {
  local name="$1" status="$2" detail="${3:-}"
  printf '%-28s %-8s %s\n' "$name" "$status" "$detail"
}

status_line 'Project root' 'ok' "$ROOT"
if command -v bash >/dev/null 2>&1; then status_line 'bash' 'ok' "$(bash --version | head -1)"; else status_line 'bash' 'missing'; fi
if command -v jq >/dev/null 2>&1; then status_line 'system jq' 'ok' "$(command -v jq)"; else status_line 'system jq' 'missing' 'will try WORK_DIR/jq'; fi
if jq_cmd --version >/dev/null 2>&1; then status_line 'jq_cmd' 'ok' "$(jq_cmd --version 2>/dev/null || true)"; else status_line 'jq_cmd' 'missing' 'module builders need jq'; fi
if command -v openssl >/dev/null 2>&1; then status_line 'openssl' 'ok' "$(openssl version | head -1)"; else status_line 'openssl' 'missing' 'Reality probe disabled'; fi
if command -v timeout >/dev/null 2>&1; then status_line 'timeout' 'ok' "$(command -v timeout)"; else status_line 'timeout' 'missing' 'Reality probe may hang'; fi

if [ -x "$XRAY_BIN" ]; then
  status_line 'xray binary' 'ok' "$XRAY_BIN"
  "$XRAY_BIN" version | head -1 || true
  if "$XRAY_BIN" vlessenc >/tmp/argox-doctor-vlessenc.log 2>&1; then status_line 'xray vlessenc' 'ok' 'VLESS PQC supported'; else status_line 'xray vlessenc' 'warn' 'not supported or failed'; fi
  if "$XRAY_BIN" mldsa65 >/tmp/argox-doctor-mldsa65.log 2>&1; then status_line 'xray mldsa65' 'ok' 'Reality ML-DSA-65 supported'; else status_line 'xray mldsa65' 'warn' 'not supported or failed'; fi
else
  status_line 'xray binary' 'warn' "not executable: $XRAY_BIN"
fi

if probe_tls_sni "${TLS_SERVER:-addons.mozilla.org}" 3; then
  status_line 'TLS SNI probe' 'ok' "${TLS_SERVER:-addons.mozilla.org}"
else
  status_line 'TLS SNI probe' 'warn' "${TLS_SERVER:-addons.mozilla.org}"
fi
