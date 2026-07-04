#!/usr/bin/env bash
# shellcheck shell=bash

build_trojan_direct_inbound() {
  local curves port
  curves="$(tls_curve_preferences_json_modular)"
  port="${TROJAN_PORT:-${TROJAN_DIRECT_PORT:-8446}}"
  jq_cmd -cn \
    --arg tag "${NODE_NAME} trojan-direct" \
    --arg password "$UUID" \
    --arg serverName "$TLS_SERVER" \
    --arg certFile "${WORK_DIR}/cert/cert.pem" \
    --arg keyFile "${WORK_DIR}/cert/private.key" \
    --argjson port "$port" \
    --argjson curves "$curves" \
    '{port:$port,protocol:"trojan",tag:$tag,settings:{clients:[{password:$password}]},streamSettings:{network:"tcp",security:"tls",tlsSettings:({serverName:$serverName,certificates:[{certificateFile:$certFile,keyFile:$keyFile}]} + (if ($curves|length)>0 then {curvePreferences:$curves} else {} end))},sniffing:{enabled:true,destOverride:["http","tls","quic"],metadataOnly:false}}'
}
