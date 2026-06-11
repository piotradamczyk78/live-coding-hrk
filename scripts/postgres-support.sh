#!/usr/bin/env bash
# Interaktywne menu komend PostgreSQL.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"
# shellcheck disable=SC1091
source "$ROOT/scripts/lib/support-menu.sh"

PG="hrk_demo"
PG_USER="dev"

pg_exec() {
    "$ROOT/scripts/compose.sh" exec -T postgres \
        psql -U "$PG_USER" -d "$PG" "$@"
}

pg_exec_it() {
    docker exec -it hrk-postgres psql -U "$PG_USER" -d "$PG"
}

support_menu_run "PostgreSQL" \
    "Interaktywna sesja psql" \
        "pg_exec_it" \
    "Healthcheck (pg_isready)" \
        "$ROOT/scripts/compose.sh exec -T postgres pg_isready -U $PG_USER -d $PG" \
    "Wersja PostgreSQL" \
        "pg_exec -c 'SELECT version();'" \
    "Lista tabel (\\dt)" \
        "pg_exec -c '\\dt'" \
    "Liczba tabel w schemacie public" \
        "pg_exec -c \"SELECT COUNT(*) AS tables FROM information_schema.tables WHERE table_schema = 'public';\"" \
    "Transakcja testowa (BEGIN → SELECT 1 → ROLLBACK)" \
        "pg_exec -c 'BEGIN; SELECT 1 AS ok; ROLLBACK;'" \
    "Przeładuj schemat z sql/schema-postgresql.sql" \
        "$ROOT/scripts/compose.sh exec -T -i postgres psql -U $PG_USER -d $PG < $ROOT/sql/schema-postgresql.sql" \
    "Synchronizuj hasło użytkownika dev (Bitwarden)" \
        "./scripts/sync-db-passwords.sh"
