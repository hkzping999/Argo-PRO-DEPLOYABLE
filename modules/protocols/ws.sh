#!/usr/bin/env bash
# shellcheck shell=bash

build_vless_ws_inbound() {
  jq_cmd -cn \
    --arg tag "${NODE_NAME} vless-ws" \
    --arg uuid "$UUID" \
    --arg dec "${VLESS_SERVER_DECRYPTION:-none}" \
    --arg path "/${WS_PATH}-vl" \
    --argjson port "$VLESS_WS_PORT" \
    '{tag:$tag,protocol:"vless",port:$port,listen:"127.0.0.1",settings:{clients:[{id:$uuid,level:0}],decryption:$dec},streamSettings:{network:"ws",security:"none",wsSettings:{path:$path}},sniffing:{enabled:true,destOverride:["http","tls","quic"],metadataOnly:false}}'
}
