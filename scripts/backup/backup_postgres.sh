#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

# Config padrão
LOG_FILE="${LOG_FILE:-/opt/infra-ops/logs/backup_postgres.log}"
PG_BACKUP_DIR="${PG_BACKUP_DIR:-/opt/infra-ops/backups/postgres}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

# Docker / Postgres
PG_CONTAINER="${PG_CONTAINER:-infraops_postgres}"
PG_DB="${PG_DB:-infraops}"
PG_USER="${PG_USER:-infraops}"

need_cmd docker
need_cmd gzip
need_cmd date
need_cmd find

mkdir -p "$PG_BACKUP_DIR"

ts_file="$(date -u +'%Y%m%dT%H%M%SZ')"
outfile="${PG_BACKUP_DIR}/${PG_DB}_${ts_file}.sql.gz"

log "INFO" "Postgres backup start: container=${PG_CONTAINER} db=${PG_DB} user=${PG_USER} out=${outfile}"

# Faz dump dentro do container e comprime no host
if docker exec -i "$PG_CONTAINER" pg_dump -U "$PG_USER" -d "$PG_DB" | gzip -c > "$outfile"; then
  log "INFO" "Postgres backup done: $(du -h "$outfile" | awk '{print $1}') -> $outfile"
else
  rm -f "$outfile" || true
  die "Postgres backup failed"
fi

# Retenção (remove dumps antigos)
deleted_count="$(find "$PG_BACKUP_DIR" -type f -name "*.sql.gz" -mtime +"$RETENTION_DAYS" -print -delete | wc -l || true)"
log "INFO" "Retention applied: deleted_files=${deleted_count} retention=${RETENTION_DAYS}d dir=${PG_BACKUP_DIR}"
