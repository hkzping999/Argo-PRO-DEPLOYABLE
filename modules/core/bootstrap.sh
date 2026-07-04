#!/usr/bin/env bash
# shellcheck shell=bash

set -Eeuo pipefail

ARGOX_ROOT="${ARGOX_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
ARGOX_MODULE_DIR="${ARGOX_MODULE_DIR:-${ARGOX_ROOT}/modules}"
WORK_DIR="${WORK_DIR:-/etc/argox}"
TEMP_DIR="${TEMP_DIR:-/tmp/argox}"
CUSTOM_FILE="${CUSTOM_FILE:-${WORK_DIR}/custom}"
JQ_BIN="${JQ_BIN:-${WORK_DIR}/jq}"
XRAY_BIN="${XRAY_BIN:-${WORK_DIR}/xray}"

source "${ARGOX_MODULE_DIR}/core/log.sh"
source "${ARGOX_MODULE_DIR}/core/json.sh"
source "${ARGOX_MODULE_DIR}/core/state.sh"
source "${ARGOX_MODULE_DIR}/core/validator.sh"
source "${ARGOX_MODULE_DIR}/core/runtime.sh"
source "${ARGOX_MODULE_DIR}/pqc/vlessenc.sh"
source "${ARGOX_MODULE_DIR}/pqc/mldsa65.sh"
source "${ARGOX_MODULE_DIR}/pqc/tls_curve.sh"
source "${ARGOX_MODULE_DIR}/protocols/registry.sh"
source "${ARGOX_MODULE_DIR}/protocols/reality.sh"
source "${ARGOX_MODULE_DIR}/protocols/ws.sh"
source "${ARGOX_MODULE_DIR}/protocols/xhttp.sh"
source "${ARGOX_MODULE_DIR}/protocols/httpupgrade.sh"
source "${ARGOX_MODULE_DIR}/protocols/trojan.sh"
source "${ARGOX_MODULE_DIR}/protocols/hysteria2.sh"
