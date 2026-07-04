#!/usr/bin/env bash
# shellcheck shell=bash

build_xhttp_cdn_inbound() {
  jq_cmd -cn \
    --arg tag "${NODE_NAME} xhttp-h1.1-cdn" \
    --arg uuid "$UUID" \
    --arg dec "${VLESS_SERVER_DECRYPTION:-none}" \
    --arg path "/${WS_PATH}-xh" \
    --argjson port "$VLESS_XHTTP_PORT" \
    '{tag:$tag,protocol:"vless",port:$port,listen:"127.0.0.1",settings:{clients:[{id:$uuid}],decryption:$dec},streamSettings:{network:"xhttp",security:"none",xhttpSettings:{mode:"auto",path:$path}},sniffing:{enabled:true,destOverride:["http","tls","quic"],metadataOnly:false}}'
}

build_xhttp_h3_direct_inbound() {
  local curves
  curves="$(tls_curve_preferences_json_modular)"
  jq_cmd -cn \
    --arg tag "${NODE_NAME} xhttp-h3-direct" \
    --arg uuid "$UUID" \
    --arg dec "${VLESS_SERVER_DECRYPTION:-none}" \
    --arg path "/${WS_PATH}-xh3" \
    --arg serverName "$TLS_SERVER" \
    --arg certFile "${WORK_DIR}/cert/cert.pem" \
    --arg keyFile "${WORK_DIR}/cert/private.key" \
    --argjson port "$XHTTP_PORT" \
    --argjson curves "$curves" \
    '{tag:$tag,protocol:"vless",port:$port,settings:{clients:[{id:$uuid}],decryption:$dec},streamSettings:{network:"xhttp",security:"tls",xhttpSettings:{mode:"stream-up",extra:{alpn:["h3"]},path:$path},tlsSettings:({serverName:$serverName,alpn:["h3"],certificates:[{certificateFile:$certFile,keyFile:$keyFile}]} + (if ($curves|length)>0 then {curvePreferences:$curves} else {} end))},sniffing:{enabled:true,destOverride:["http","tls","quic"]}}'
}
