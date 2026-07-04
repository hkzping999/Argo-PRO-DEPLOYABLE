#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "${1:-}" in
  --test-modules)
    exec "$ROOT/scripts/test_modules.sh"
    ;;
  --doctor)
    shift
    exec "$ROOT/scripts/doctor.sh" "$@"
    ;;
  --list-protocols)
    ARGOX_ROOT="$ROOT"
    # shellcheck source=modules/core/bootstrap.sh
    source "$ROOT/modules/core/bootstrap.sh"
    protocol_list_table
    ;;
  --build-inbounds)
    shift
    exec "$ROOT/scripts/build_inbounds.sh" "$@"
    ;;
  --build-sample)
    exec "$ROOT/tests/build_sample_inbounds.sh"
    ;;
  --safe-apply-config)
    shift
    exec "$ROOT/scripts/safe_apply_config.sh" "$@"
    ;;
  *)
    cat <<USAGE
Argo-PQC-Strong modular refactor stage 1

Production-compatible legacy script:
  ./argox.sh

Modular commands:
  ./argox-next.sh --test-modules
      Check syntax for all modular shell files.

  ./argox-next.sh --doctor
      Check jq, openssl, xray, vlessenc, mldsa65 and Reality SNI probe readiness.

  ./argox-next.sh --list-protocols
      Show the modular protocol registry.

  ./argox-next.sh --build-sample
      Build a sample inbound JSON using the modular protocol builders.

  ./argox-next.sh --build-inbounds --tags vless-ws,reality-vision --env ./config-pqc-strong.conf --out ./inbound.json
      Build inbound JSON from selected protocol tags and an optional env/custom file.

  ./argox-next.sh --safe-apply-config ./inbound.json [/etc/argox/inbound.json] [/etc/argox/outbound.json]
      Validate and apply generated config with backup and optional xray -test.

This is a staged refactor layer. The legacy installer remains available while protocol builders are migrated safely.
USAGE
    ;;
esac
