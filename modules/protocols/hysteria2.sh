#!/usr/bin/env bash
# shellcheck shell=bash

build_hysteria2_inbound() {
  local curves port
  curves="$(tls_curve_preferences_json_modular)"
  port="${HY2_PORT:-${HYSTERIA2_PORT:-8445}}"
  jq_cmd -cn \
    --arg tag "${NODE_NAME} hysteria2" \
    --arg uuid "$UUID" \
    --arg serverName "$TLS_SERVER" \
    --arg certFile "${WORK_DIR}/cert/cert.pem" \
    --arg keyFile "${WORK_DIR}/cert/private.key" \
    --argjson port "$port" \
    --argjson curves "$curves" \
    '{tag:$tag,protocol:"hysteria",port:$port,settings:{version:2,clients:[{auth:$uuid}]},streamSettings:{network:"hysteria",security:"tls",tlsSettings:({serverNames:[$serverName],alpn:["h3"],certificates:[{certificateFile:$certFile,keyFile:$keyFile}]} + (if ($curves|length)>0 then {curvePreferences:$curves} else {} end))}}'
}
