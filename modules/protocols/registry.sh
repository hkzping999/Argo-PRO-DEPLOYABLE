#!/usr/bin/env bash
# shellcheck shell=bash

# letter|tag|name|group|default|builder
PROTOCOL_REGISTRY=(
  'b|reality-vision|VLESS + Reality Vision + PQC|direct-pqc|no|build_reality_vision_inbound'
  'c|hysteria2|Hysteria2 + TLS hybrid PQ curve|direct-tls|no|build_hysteria2_inbound'
  'd|reality-grpc|VLESS + Reality gRPC + PQC|direct-pqc|no|build_reality_grpc_inbound'
  'e|vless-ws|VLESS + WS + Argo + PQC|argo-cdn|yes|build_vless_ws_inbound'
  'i|xhttp-h1.1-cdn|VLESS + XHTTP HTTP/1.1 CDN + PQC|argo-cdn|no|build_xhttp_cdn_inbound'
  'j|xhttp-h3-direct|VLESS + XHTTP HTTP/3 Direct + PQC|direct-tls|no|build_xhttp_h3_direct_inbound'
  'l|trojan-direct|Trojan Direct + TLS hybrid PQ curve|direct-tls|no|build_trojan_direct_inbound'
  'm|httpupgrade-cdn|VLESS + HTTPUpgrade CDN + PQC|argo-cdn|no|build_httpupgrade_cdn_inbound'
)

protocol_tag_by_letter() {
  local letter="$1" row
  for row in "${PROTOCOL_REGISTRY[@]}"; do
    IFS='|' read -r l tag _ <<< "$row"
    [ "$l" = "$letter" ] && { printf '%s' "$tag"; return 0; }
  done
  return 1
}

protocol_builder_by_tag() {
  local want="$1" row
  for row in "${PROTOCOL_REGISTRY[@]}"; do
    IFS='|' read -r _ tag _name _group _default builder <<< "$row"
    [ "$tag" = "$want" ] && { printf '%s' "$builder"; return 0; }
  done
  return 1
}

protocol_list_table() {
  local row
  printf '%-4s %-22s %-12s %s\n' 'Key' 'Tag' 'Group' 'Name'
  printf '%-4s %-22s %-12s %s\n' '---' '---' '---' '---'
  for row in "${PROTOCOL_REGISTRY[@]}"; do
    IFS='|' read -r letter tag name group _default _builder <<< "$row"
    printf '%-4s %-22s %-12s %s\n' "$letter" "$tag" "$group" "$name"
  done
}

protocol_default_tags_csv() {
  local row out=""
  for row in "${PROTOCOL_REGISTRY[@]}"; do
    IFS='|' read -r _ tag _name _group def _builder <<< "$row"
    if [ "$def" = "yes" ]; then
      out="${out:+$out,}$tag"
    fi
  done
  printf '%s' "$out"
}
