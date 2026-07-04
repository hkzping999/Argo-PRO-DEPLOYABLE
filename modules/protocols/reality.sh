#!/usr/bin/env bash
# shellcheck shell=bash

REALITY_DOMAIN_POOL_DEFAULT=("addons.mozilla.org" "www.microsoft.com" "www.apple.com" "www.cloudflare.com" "www.samsung.com")

host_from_target() {
  local x="$1"
  x="${x#https://}"; x="${x#http://}"; x="${x%%/*}"
  if [[ "$x" =~ ^\[([^]]+)\]:[0-9]{1,5}$ ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    printf '%s' "${x%%:*}"
  fi
}

normalize_reality_target() {
  local x="$1"
  x="${x#https://}"; x="${x#http://}"; x="${x%%/*}"
  if [[ "$x" =~ :[0-9]{1,5}$ ]]; then printf '%s' "$x"; else printf '%s:443' "$x"; fi
}

pick_reality_domain_modular() {
  local candidate
  local pool=("${REALITY_DOMAIN_POOL[@]:-${REALITY_DOMAIN_POOL_DEFAULT[@]}}")
  if truthy "${REALITY_CHECK_ON_INSTALL:-y}"; then
    for candidate in "${pool[@]}"; do
      if validate_domain_name "$candidate" && probe_tls_sni "$candidate" "${REALITY_CHECK_TIMEOUT:-4}"; then
        printf '%s' "$candidate"
        return 0
      fi
    done
  fi
  printf '%s' "${pool[0]:-addons.mozilla.org}"
}

ensure_reality_defaults_modular() {
  local host
  if [ -z "${REALITY_TARGET:-}" ]; then
    REALITY_TARGET="$(normalize_reality_target "$(pick_reality_domain_modular)")"
  fi
  host="$(host_from_target "$REALITY_TARGET")"
  validate_domain_name "$host" || error "Invalid Reality SNI: $host"
  REALITY_SERVER_NAMES="${REALITY_SERVER_NAMES:-$host}"
  REALITY_SERVER_NAMES_JSON="$(csv_to_json_array "$REALITY_SERVER_NAMES")"
}

reality_settings_json() {
  ensure_reality_defaults_modular
  jq_cmd -cn \
    --arg dest "$REALITY_TARGET" \
    --arg privateKey "$REALITY_PRIVATE" \
    --arg seed "${REALITY_MLDSA65_SEED:-}" \
    --argjson names "$REALITY_SERVER_NAMES_JSON" \
    '{show:false,dest:$dest,xver:0,serverNames:$names,privateKey:$privateKey,shortIds:[""]} + (if $seed != "" then {mldsa65Seed:$seed} else {} end)'
}

build_reality_vision_inbound() {
  local reality_json
  reality_json="$(reality_settings_json)"
  jq_cmd -cn \
    --arg tag "${NODE_NAME} reality-vision" \
    --arg uuid "$UUID" \
    --arg dec "${VLESS_SERVER_DECRYPTION:-none}" \
    --argjson port "$REALITY_PORT" \
    --argjson reality "$reality_json" \
    '{tag:$tag,protocol:"vless",port:$port,settings:{clients:[{id:$uuid,flow:"xtls-rprx-vision"}],decryption:$dec},streamSettings:{network:"tcp",security:"reality",realitySettings:$reality},sniffing:{enabled:true,destOverride:["http","tls"]}}'
}

build_reality_grpc_inbound() {
  local reality_json
  reality_json="$(reality_settings_json)"
  jq_cmd -cn \
    --arg tag "${NODE_NAME} reality-grpc" \
    --arg uuid "$UUID" \
    --arg dec "${VLESS_SERVER_DECRYPTION:-none}" \
    --argjson port "$GRPC_PORT" \
    --argjson reality "$reality_json" \
    '{tag:$tag,protocol:"vless",port:$port,settings:{clients:[{id:$uuid,flow:""}],decryption:$dec},streamSettings:{network:"grpc",security:"reality",realitySettings:$reality,grpcSettings:{serviceName:"grpc",multiMode:true}},sniffing:{enabled:true,destOverride:["http","tls"]}}'
}
