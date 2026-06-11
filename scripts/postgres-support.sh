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
    "Lista tabel (\\dt)" \
        "pg_exec -c '\\dt'" \
    "Struktura tabeli invoices (\\d invoices)" \
        "pg_exec -c '\\d invoices'" \
    "Liczba faktur" \
        "pg_exec -c 'SELECT COUNT(*) AS invoices FROM invoices;'" \
    "5 faktur (numer, kwota, status)" \
        "pg_exec -c 'SELECT number, amount, status FROM invoices LIMIT 5;'" \
    "Faktury nieopłacone (JOIN + SUM płatności)" \
        "pg_exec -c \"SELECT i.number, c.name, i.amount, COALESCE(SUM(p.amount),0) AS paid FROM invoices i JOIN customers c ON c.id = i.customer_id LEFT JOIN payments p ON p.invoice_id = i.id GROUP BY i.id, i.number, c.name, i.amount HAVING COALESCE(SUM(p.amount),0) < i.amount;\"" \
    "Lista klientów" \
        "pg_exec -c 'SELECT id, name, tax_id FROM customers ORDER BY id;'" \
    "Transakcja testowa (BEGIN → UPDATE → ROLLBACK)" \
        "pg_exec -c \"BEGIN; UPDATE invoices SET status = 'paid' WHERE id = 1; ROLLBACK; SELECT status FROM invoices WHERE id = 1;\"" \
    "Przeładuj schemat z sql/schema-postgresql.sql" \
        "$ROOT/scripts/compose.sh exec -T -i postgres psql -U $PG_USER -d $PG < $ROOT/sql/schema-postgresql.sql" \
    "Synchronizuj hasło użytkownika dev (Bitwarden)" \
        "./scripts/sync-db-passwords.sh"
