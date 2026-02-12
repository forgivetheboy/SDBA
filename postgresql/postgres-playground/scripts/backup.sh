#!/usr/bin/env bash
set -euo pipefail
# Lightweight backup helper: logical (pg_dumpall or per-db) and physical (pg_basebackup)

: ${PGHOST:=localhost}
: ${PGPORT:=5432}
: ${PGUSER:=postgres}
: ${PGPASSWORD:=${PGPASSWORD:-}}
: ${BACKUP_DIR:=./backups}

mkdir -p "$BACKUP_DIR"
timestamp=$(date +%Y%m%d_%H%M%S)

usage(){
  cat <<EOF
Usage: $0 [--logical|--physical|--all]
  --logical   : pg_dumpall to single SQL file + per-db custom dumps
  --physical  : pg_basebackup to capture filesystem-level basebackup
  --all       : both
EOF
  exit 1
}

if [ "$#" -eq 0 ]; then
  usage
fi

while [ "$#" -gt 0 ]; do
  case "$1" in
    --logical) MODE=logical; shift;;
    --physical) MODE=physical; shift;;
    --all) MODE=all; shift;;
    *) usage;;
  esac
done

export PGPASSWORD="$PGPASSWORD"

if [ "$MODE" = "logical" ] || [ "$MODE" = "all" ]; then
  echo "Running logical backup..."
  outfile="$BACKUP_DIR/pg_dumpall_${timestamp}.sql"
  pg_dumpall -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" > "$outfile"
  echo "Dumped cluster SQL -> $outfile"

  # Per-db compressed dumps
  for db in $(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -Atc "SELECT datname FROM pg_database WHERE datistemplate = false;"); do
    echo "Dumping $db"
    pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -Fc -f "$BACKUP_DIR/${db}_${timestamp}.dump" "$db"
  done
fi

if [ "$MODE" = "physical" ] || [ "$MODE" = "all" ]; then
  echo "Running physical base backup (pg_basebackup)..."
  baseout="$BACKUP_DIR/basebackup_${timestamp}"
  mkdir -p "$baseout"
  pg_basebackup -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -D "$baseout" -Ft -z -P
  echo "Base backup saved -> $baseout.tar.gz"
fi

echo "Done."
