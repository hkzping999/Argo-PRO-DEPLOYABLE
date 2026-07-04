#!/usr/bin/env bash
# shellcheck shell=bash

vless_pqc_supported() {
  [ -x "${XRAY_BIN:-}" ] || return 1
  "${XRAY_BIN}" vlessenc >/tmp/argox-vlessenc-probe.log 2>&1
}

prepare_vless_pqc_keys_modular() {
  ENABLE_VLESS_PQC="${ENABLE_VLESS_PQC:-y}"
  VLESS_PQC_STRICT="${VLESS_PQC_STRICT:-y}"
  VLESS_PQC_REQUIRE_PREFIX="${VLESS_PQC_REQUIRE_PREFIX:-mlkem768x25519plus}"

  VLESS_SERVER_DECRYPTION="${VLESS_PQC_DECRYPTION:-}"
  VLESS_CLIENT_ENCRYPTION="${VLESS_PQC_ENCRYPTION:-}"

  if ! truthy "$ENABLE_VLESS_PQC"; then
    VLESS_SERVER_DECRYPTION="none"
    VLESS_CLIENT_ENCRYPTION="none"
    return 0
  fi

  if [ -n "$VLESS_SERVER_DECRYPTION" ] && [ -n "$VLESS_CLIENT_ENCRYPTION" ]; then
    return 0
  fi

  local out
  if ! out="$(${XRAY_BIN} vlessenc 2>/dev/null)"; then
    if truthy "$VLESS_PQC_STRICT"; then
      error "xray vlessenc failed; current Xray-core does not support VLESS PQC encryption"
    fi
    warning "xray vlessenc failed; fallback to VLESS encryption=none"
    VLESS_SERVER_DECRYPTION="none"
    VLESS_CLIENT_ENCRYPTION="none"
    return 0
  fi

  VLESS_SERVER_DECRYPTION="$(awk -F: 'tolower($1) ~ /decryption/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' <<< "$out")"
  VLESS_CLIENT_ENCRYPTION="$(awk -F: 'tolower($1) ~ /encryption/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' <<< "$out")"

  if [[ "$VLESS_SERVER_DECRYPTION" != ${VLESS_PQC_REQUIRE_PREFIX}* ]] || [[ "$VLESS_CLIENT_ENCRYPTION" != ${VLESS_PQC_REQUIRE_PREFIX}* ]]; then
    truthy "$VLESS_PQC_STRICT" && error "VLESS PQC output prefix mismatch; expected ${VLESS_PQC_REQUIRE_PREFIX}"
  fi
}
