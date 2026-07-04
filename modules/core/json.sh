#!/usr/bin/env bash
# shellcheck shell=bash

require_jq() {
  [ -x "${JQ_BIN:-}" ] || command -v jq >/dev/null 2>&1 || error "jq is required"
}

jq_cmd() {
  if [ -x "${JQ_BIN:-}" ]; then
    "${JQ_BIN}" "$@"
  else
    jq "$@"
  fi
}

url_encode() {
  local raw="${1:-}"
  jq_cmd -nr --arg v "$raw" '$v|@uri'
}

csv_to_json_array() {
  local csv="${1:-}"
  jq_cmd -cn --arg v "$csv" '$v | split(",") | map(gsub("^\\s+|\\s+$";"")) | map(select(length>0))'
}

json_merge_inbounds() {
  # stdin: one JSON object per line. stdout: {"inbounds":[...]}
  jq_cmd -s '{inbounds: .}'
}

validate_json_file() {
  local file="$1"
  jq_cmd empty "$file" >/dev/null 2>&1
}
