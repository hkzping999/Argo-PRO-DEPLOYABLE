#!/usr/bin/env bash
# shellcheck shell=bash

build_httpupgrade_cdn_inbound() {
  jq_cmd -cn \
    --arg tag "${NODE_NAME} httpupgrade-cdn" \
    --arg uuid "$UUID" \
    --arg dec "${VLESS_SERVER_DECRYPTION:-none}" \
    --arg path "/${WS_PATH}-hu" \
    --arg host "$ARGO_DOMAIN" \
    --argjson port "$HTTPUPGRADE_PORT" \
    '{tag:$tag,protocol:"vless",port:$port,listen:"127.0.0.1",settings:{clients:[{id:$uuid,level:0}],decryption:$dec},streamSettings:{network:"httpupgrade",security:"none",httpupgradeSettings:{path:$path,host:$host,headers:{Host:$host}}},sniffing:{enabled:true,destOverride:["http","tls","quic"],metadataOnly:false}}'
}
