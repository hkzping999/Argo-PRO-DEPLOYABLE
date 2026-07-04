#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARGOX_ROOT="$ROOT"
# shellcheck source=../modules/core/bootstrap.sh
source "$ROOT/modules/core/bootstrap.sh"

ENV_FILE=""
TAGS=""
OUT="-"
TEST_XRAY="n"

usage() {
  cat <<USAGE
Build inbound.json using the modular protocol builders.

Usage:
  $0 --tags vless-ws,reality-vision [--env ./config-pqc-strong.conf] [--out ./inbound.json] [--test-xray]

Options:
  --tags       Comma separated protocol tags. Use --list-protocols to view tags.
  --env        Optional shell assignment file to load variables from.
  --out        Output path. Default: stdout.
  --test-xray  Run xray config test after writing output.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --tags) TAGS="${2:-}"; shift 2 ;;
    --env) ENV_FILE="${2:-}"; shift 2 ;;
    --out) OUT="${2:-}"; shift 2 ;;
    --test-xray) TEST_XRAY="y"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) error "Unknown option: $1" ;;
  esac
done

argox_load_env_file "$ENV_FILE"
argox_set_default_runtime
require_jq

TAGS="${TAGS:-$(protocol_default_tags_csv)}"
[ -n "$TAGS" ] || error "No protocol tags specified"

# Do not auto-generate PQC keys in this standalone builder unless an Xray binary is present.
# Existing values from env/custom are respected.
if [ -x "$XRAY_BIN" ]; then
  prepare_vless_pqc_keys_modular || true
  generate_mldsa65_modular || true
fi

build_one() {
  local tag="$1" builder
  builder="$(protocol_builder_by_tag "$tag")" || error "Unknown protocol tag: $tag"
  if ! declare -F "$builder" >/dev/null 2>&1; then
    error "Protocol builder not loaded: $builder"
  fi
  "$builder"
}

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
while IFS= read -r tag; do
  [ -n "$tag" ] || continue
  build_one "$tag" >> "$tmp"
  printf '\n' >> "$tmp"
done < <(argox_split_csv "$TAGS")

json="$(json_merge_inbounds < "$tmp")"
if [ "$OUT" = "-" ]; then
  printf '%s\n' "$json" | jq_cmd .
else
  mkdir -p "$(dirname "$OUT")"
  printf '%s\n' "$json" | jq_cmd . > "$OUT"
  validate_json_file "$OUT" || error "Generated JSON is invalid: $OUT"
  info "Generated inbound config: $OUT"
  if truthy "$TEST_XRAY"; then
    xray_test_config "$OUT" "" "/tmp/argox-next-xray-test.log" || {
      cat /tmp/argox-next-xray-test.log >&2 || true
      error "xray config test failed"
    }
    info "xray config test passed"
  fi
fi
