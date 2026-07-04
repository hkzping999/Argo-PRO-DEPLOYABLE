#!/usr/bin/env bash
# shellcheck shell=bash

shell_quote() {
  printf '%q' "${1:-}"
}

write_custom() {
  local key="$1" value="${2:-}" quoted
  quoted="$(shell_quote "$value")"
  mkdir -p "$(dirname "${CUSTOM_FILE}")"
  touch "${CUSTOM_FILE}"
  chmod 600 "${CUSTOM_FILE}" 2>/dev/null || true
  if grep -qE "^${key}=" "${CUSTOM_FILE}" 2>/dev/null; then
    sed -i "s#^${key}=.*#${key}=${quoted}#" "${CUSTOM_FILE}"
  else
    printf "%s=%s\n" "$key" "$quoted" >> "${CUSTOM_FILE}"
  fi
}

read_custom() {
  local key="$1"
  [ -s "${CUSTOM_FILE}" ] || return 1
  # shellcheck disable=SC1090
  . "${CUSTOM_FILE}"
  eval "printf '%s' \"\${${key}:-}\""
}

truthy() {
  case "${1:-}" in
    y|Y|yes|YES|true|TRUE|1|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}
