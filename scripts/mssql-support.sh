#!/usr/bin/env bash
# Interaktywne menu komend MS SQL (T-SQL).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"
# shellcheck disable=SC1091
source "$ROOT/scripts/lib/support-menu.sh"

export MSSQL_SA_PASSWORD="${MSSQL_SA_PASSWORD:?}"

mssql_network() {
    docker inspect hrk-sqlserver --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null | head -1
}

mssql_sqlcmd() {
    local network
    network="$(mssql_network)"
    docker run --rm \
        --network "$network" \
        mcr.microsoft.com/mssql-tools:latest \
        /opt/mssql-tools/bin/sqlcmd \
            -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" \
            "$@"
}

mssql_sqlcmd_it() {
    local network
    network="$(mssql_network)"
    docker run --rm -it \
        --network "$network" \
        mcr.microsoft.com/mssql-tools:latest \
        /opt/mssql-tools/bin/sqlcmd \
            -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD"
}

support_menu_run "MS SQL" \
    "Interaktywna sesja sqlcmd" \
        "mssql_sqlcmd_it" \
    "Test połączenia (SELECT 1)" \
        "mssql_sqlcmd -Q 'SELECT 1 AS ok'" \
    "Liczba faktur" \
        "mssql_sqlcmd -Q 'SET NOCOUNT ON; SELECT COUNT(*) AS invoices FROM dbo.invoices;'" \
    "TOP 10 faktur" \
        "mssql_sqlcmd -Q 'SET NOCOUNT ON; SELECT TOP 10 id, number, amount, status FROM dbo.invoices ORDER BY id;'" \
    "Lista tabel (INFORMATION_SCHEMA)" \
        "mssql_sqlcmd -Q \"SET NOCOUNT ON; SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' ORDER BY TABLE_NAME;\"" \
    "Faktury nieopłacone (JOIN + SUM)" \
        "mssql_sqlcmd -Q \"SET NOCOUNT ON; SELECT i.number, c.name, i.amount, ISNULL(SUM(p.amount),0) AS paid FROM dbo.invoices i JOIN dbo.customers c ON c.id = i.customer_id LEFT JOIN dbo.payments p ON p.invoice_id = i.id GROUP BY i.id, i.number, c.name, i.amount HAVING ISNULL(SUM(p.amount),0) < i.amount;\"" \
    "Lista klientów" \
        "mssql_sqlcmd -Q 'SET NOCOUNT ON; SELECT id, name, tax_id FROM dbo.customers ORDER BY id;'" \
    "Transakcja testowa (BEGIN TRAN → ROLLBACK)" \
        "mssql_sqlcmd -Q \"BEGIN TRAN; UPDATE dbo.invoices SET status = N'paid' WHERE id = 2; ROLLBACK TRAN; SELECT status FROM dbo.invoices WHERE id = 2;\"" \
    "Przeładuj schemat (init-mssql.sh)" \
        "./scripts/init-mssql.sh" \
    "Dane połączenia GUI (DBeaver / Azure Data Studio)" \
        "echo 'Host: localhost | Port: 1433 | User: sa | Database: hrk_demo | Encrypt: off / Trust Server Certificate'" \
    "Synchronizuj hasło SA (Bitwarden)" \
        "./scripts/sync-db-passwords.sh"
