#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

THRESHOLD_PERCENT="${THRESHOLD_PERCENT:-85}"
TARGET_MOUNT="${TARGET_MOUNT:-/}"
LOG_FILE="${LOG_FILE:-/opt/infra-ops/logs/disk_usage_check.log}"

need_cmd df
need_cmd awk

usage_pct="$(df -P "$TARGET_MOUNT" | awk 'NR==2 {gsub("%","",$5); print $5}')"
[[ -n "${usage_pct}" ]] || die "Could not determine disk usage for mount: $TARGET_MOUNT"

if (( usage_pct >= THRESHOLD_PERCENT )); then
  log "WARN" "Disk usage high on ${TARGET_MOUNT}: ${usage_pct}% (threshold=${THRESHOLD_PERCENT}%)"
  exit 2
else
  log "INFO" "Disk usage OK on ${TARGET_MOUNT}: ${usage_pct}% (threshold=${THRESHOLD_PERCENT}%)"
fi
