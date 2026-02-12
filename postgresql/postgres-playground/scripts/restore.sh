#!/usr/bin/env bash
set -euo pipefail
# Lightweight restore helper for logical and basic physical restore notes

: ${PGHOST:=localhost}
: ${PGPORT:=5432}
: ${PGUSER:=postgres}
: ${PGPASSWORD:=${PGPASSWORD:-}}
: ${BACKUP_DIR:=./backups}

usage(){
  cat <<EOF
Usage: $0 --logical <sql-file>    # for pg_dumpall SQL
       $0 --pgrestore <dumpfile>  # for custom-format pg_dump (-Fc) via pg_restore
       $0 --physical <basebackup.tar.gz> <target_data_dir>   # notes: manual steps
EOF
  exit 1
}

if [ "$#" -lt 1 ]; then
  usage
fi

case "$1" in
  --logical)
    shift
    sqlfile="$1"
    echo "Restoring logical SQL: $sqlfile"
    export PGPASSWORD="$PGPASSWORD"
    psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -f "$sqlfile"
    ;;
  --pgrestore)
    shift
    dumpfile="$1"
    echo "Restoring custom dump: $dumpfile"
    export PGPASSWORD="$PGPASSWORD"
    # replace target DB name as needed; this example restores all objects into the 'postgres' db
    pg_restore -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c "$dumpfile"
    ;;
  --physical)
    shift
    echo "Physical restore is environment-specific. Example steps:"
    echo "1) Stop PostgreSQL on target host"
    echo "2) Move/backup current data dir"
    echo "3) Extract basebackup into data dir (tar -xzf $1 -C <PGDATA>)"
    echo "4) Create recovery configuration (standby.signal + primary_conninfo in postgresql.conf or recovery.conf equivalent)"
    echo "5) Ensure WAL archive/restore settings are correct"
    echo "6) Start PostgreSQL"
    ;;
  *)
    usage
    ;;
esac

echo "Restore step finished (check logs and connections)."
