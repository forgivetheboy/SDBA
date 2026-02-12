#!/usr/bin/env bash
set -euo pipefail
# Run SQL in sql/user_admin.sql against a server

: ${PGHOST:=localhost}
: ${PGPORT:=5432}
: ${PGUSER:=postgres}
: ${PGPASSWORD:=${PGPASSWORD:-}}

export PGPASSWORD="$PGPASSWORD"

psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -f "../sql/user_admin.sql"
