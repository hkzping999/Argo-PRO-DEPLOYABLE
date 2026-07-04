#!/usr/bin/env bash
# shellcheck shell=bash

# Runtime helpers shared by the modular refactor layer.

argox_split_csv() {
  local csv="${1:-}" IFS=',' item
  # shellcheck disable=SC2206
  local arr=( $csv )
  for item in "${arr[@]}"; do
    item="${item#${item%%[![:space:]]*}}"
    item="${item%${item##*[![:space:]]}}"
    [ -n "$item" ] && printf '%s\n' "$item"
  done
}

argox_load_env_file() {
  local file="${1:-}"
  [ -n "$file" ] || return 0
  [ -f "$file" ] || error "Environment file not found: $file"
  # The legacy custom/config files are shell assignment files by design.
  # shellcheck disable=SC1090
  . "$file"
}

argox_set_default_runtime() {
  NODE_NAME="${NODE_NAME:-Argo-PQC-Strong}"
  UUID="${UUID:-00000000-0000-0000-0000-000000000000}"
  WS_PATH="${WS_PATH:-argopqc}"
  ARGO_DOMAIN="${ARGO_DOMAIN:-example.com}"
  TLS_SERVER="${TLS_SERVER:-addons.mozilla.org}"
  WORK_DIR="${WORK_DIR:-/etc/argox}"
  TEMP_DIR="${TEMP_DIR:-/tmp/argox}"
  CUSTOM_FILE="${CUSTOM_FILE:-${WORK_DIR}/custom}"
  JQ_BIN="${JQ_BIN:-${WORK_DIR}/jq}"
  XRAY_BIN="${XRAY_BIN:-${WORK_DIR}/xray}"

  REALITY_PORT="${REALITY_PORT:-443}"
  GRPC_PORT="${GRPC_PORT:-8443}"
  VLESS_WS_PORT="${VLESS_WS_PORT:-8001}"
  VLESS_XHTTP_PORT="${VLESS_XHTTP_PORT:-8008}"
  XHTTP_PORT="${XHTTP_PORT:-8444}"
  HTTPUPGRADE_PORT="${HTTPUPGRADE_PORT:-8010}"
  HYSTERIA2_PORT="${HYSTERIA2_PORT:-8445}"
  TROJAN_DIRECT_PORT="${TROJAN_DIRECT_PORT:-8446}"

  REALITY_PRIVATE="${REALITY_PRIVATE:-REPLACE_REALITY_PRIVATE_KEY}"
  REALITY_PUBLIC="${REALITY_PUBLIC:-REPLACE_REALITY_PUBLIC_KEY}"
  REALITY_TARGET="${REALITY_TARGET:-}"
  REALITY_SERVER_NAMES="${REALITY_SERVER_NAMES:-}"
  REALITY_CHECK_ON_INSTALL="${REALITY_CHECK_ON_INSTALL:-y}"
  REALITY_CHECK_TIMEOUT="${REALITY_CHECK_TIMEOUT:-4}"

  ENABLE_VLESS_PQC="${ENABLE_VLESS_PQC:-y}"
  VLESS_PQC_STRICT="${VLESS_PQC_STRICT:-n}"
  VLESS_SERVER_DECRYPTION="${VLESS_SERVER_DECRYPTION:-${VLESS_PQC_DECRYPTION:-none}}"
  VLESS_CLIENT_ENCRYPTION="${VLESS_CLIENT_ENCRYPTION:-${VLESS_PQC_ENCRYPTION:-none}}"

  ENABLE_REALITY_MLDSA65="${ENABLE_REALITY_MLDSA65:-y}"
  REALITY_MLDSA65_STRICT="${REALITY_MLDSA65_STRICT:-n}"
  ENABLE_TLS_PQC_CURVE="${ENABLE_TLS_PQC_CURVE:-y}"
  TLS_CURVE_PREFERENCES="${TLS_CURVE_PREFERENCES:-X25519MLKEM768,X25519}"
}
