#!/usr/bin/env bash
# shellcheck shell=bash

validate_domain_name() {
  local host="$1"
  [[ "$host" =~ ^[A-Za-z0-9.-]+$ ]] || return 1
  [[ "$host" == *.* ]] || return 1
  [[ "$host" != .* ]] || return 1
  [[ "$host" != *. ]] || return 1
}

probe_tls_sni() {
  local host="$1" timeout_s="${2:-4}"
  command -v openssl >/dev/null 2>&1 || return 2
  timeout "$timeout_s" openssl s_client -connect "${host}:443" -servername "$host" -brief </dev/null >/dev/null 2>&1
}

xray_test_config() {
  local inbound="$1" outbound="${2:-}"
  local log_file="${3:-/tmp/argox-xray-test.log}"
  [ -x "${XRAY_BIN:-}" ] || error "Xray binary not found: ${XRAY_BIN:-unset}"
  if [ -n "$outbound" ] && [ -s "$outbound" ]; then
    "${XRAY_BIN}" run -test -c "$inbound" -c "$outbound" >"$log_file" 2>&1
  else
    "${XRAY_BIN}" run -test -c "$inbound" >"$log_file" 2>&1
  fi
}

backup_file_once() {
  local file="$1"
  [ -s "$file" ] || return 0
  cp -a "$file" "${file}.bak.$(date +%Y%m%d%H%M%S)"
}
