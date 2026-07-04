#!/usr/bin/env bash
# shellcheck shell=bash

generate_mldsa65_modular() {
  ENABLE_REALITY_MLDSA65="${ENABLE_REALITY_MLDSA65:-y}"
  REALITY_MLDSA65_STRICT="${REALITY_MLDSA65_STRICT:-n}"

  truthy "$ENABLE_REALITY_MLDSA65" || return 0
  [ -n "${REALITY_MLDSA65_SEED:-}" ] && [ -n "${REALITY_MLDSA65_VERIFY:-}" ] && return 0

  local out
  if ! out="$(${XRAY_BIN} mldsa65 2>/dev/null)"; then
    if truthy "$REALITY_MLDSA65_STRICT"; then
      error "xray mldsa65 failed; current Xray-core does not support Reality ML-DSA-65"
    fi
    warning "xray mldsa65 failed; continue without Reality ML-DSA-65"
    REALITY_MLDSA65_SEED=""
    REALITY_MLDSA65_VERIFY=""
    return 0
  fi

  REALITY_MLDSA65_SEED="$(awk -F: 'tolower($1) ~ /seed/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' <<< "$out")"
  REALITY_MLDSA65_VERIFY="$(awk -F: 'tolower($1) ~ /verify/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' <<< "$out")"

  if [ -z "$REALITY_MLDSA65_SEED" ] || [ -z "$REALITY_MLDSA65_VERIFY" ]; then
    truthy "$REALITY_MLDSA65_STRICT" && error "Cannot parse xray mldsa65 output"
    warning "Cannot parse xray mldsa65 output; continue without ML-DSA-65"
    REALITY_MLDSA65_SEED=""
    REALITY_MLDSA65_VERIFY=""
  fi
}
