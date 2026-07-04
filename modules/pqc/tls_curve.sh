#!/usr/bin/env bash
# shellcheck shell=bash

tls_curve_preferences_json_modular() {
  ENABLE_TLS_PQC_CURVE="${ENABLE_TLS_PQC_CURVE:-y}"
  TLS_CURVE_PREFERENCES="${TLS_CURVE_PREFERENCES:-X25519MLKEM768,X25519}"
  if truthy "$ENABLE_TLS_PQC_CURVE"; then
    csv_to_json_array "$TLS_CURVE_PREFERENCES"
  else
    printf '[]'
  fi
}
