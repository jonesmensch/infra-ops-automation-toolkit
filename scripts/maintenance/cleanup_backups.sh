#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

RETENTION_DAYS="${RETENTION_DAYS:-7}"
TARGET_DIR="${TARGET_DIR:-/opt/infra-ops/backups}"
LOG_FILE="${LOG_FILE:-/opt/infra-ops/logs/cleanup_backups.log}"

need_cmd find
need_cmd du

mkdir -p "$TARGET_DIR"
before="$(du -sh "$TARGET_DIR" 2>/dev/null | awk '{print $1}')"
log "INFO" "Cleanup start: dir=${TARGET_DIR} retention=${RETENTION_DAYS}d size_before=${before:-unknown}"

deleted_count="$(find "$TARGET_DIR" -type f -mtime +"$RETENTION_DAYS" -print -delete | wc -l || true)"

after="$(du -sh "$TARGET_DIR" 2>/dev/null | awk '{print $1}')"
log "INFO" "Cleanup done: deleted_files=${deleted_count} size_after=${after:-unknown}"
