#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="${LOG_DIR:-/opt/infra-ops/logs}"
BACKUP_DIR="${BACKUP_DIR:-/opt/infra-ops/backups}"

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

log() {
  local level="$1"; shift
  mkdir -p "$LOG_DIR"
  echo "$(ts) [$level] $*" | tee -a "${LOG_FILE:-$LOG_DIR/infra-ops.log}" >/dev/null
}

die() {
  log "ERROR" "$*"
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}
