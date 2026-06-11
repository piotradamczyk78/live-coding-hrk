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
    "Wersja SQL Server" \
        "mssql_sqlcmd -Q 'SELECT @@VERSION AS version;'" \
    "Lista tabel (INFORMATION_SCHEMA)" \
        "mssql_sqlcmd -Q \"SET NOCOUNT ON; SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' ORDER BY TABLE_NAME;\"" \
    "Liczba tabel w schemacie dbo" \
        "mssql_sqlcmd -Q \"SET NOCOUNT ON; SELECT COUNT(*) AS tables FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo';\"" \
    "Transakcja testowa (BEGIN TRAN → ROLLBACK)" \
        "mssql_sqlcmd -Q 'BEGIN TRAN; SELECT 1 AS ok; ROLLBACK TRAN;'" \
    "Przeładuj schemat (init-mssql.sh)" \
        "./scripts/init-mssql.sh" \
    "Dane połączenia GUI (DBeaver / Azure Data Studio)" \
        "echo 'Host: localhost | Port: 1433 | User: sa | Database: hrk_demo | Encrypt: off / Trust Server Certificate'" \
    "Synchronizuj hasło SA (Bitwarden)" \
        "./scripts/sync-db-passwords.sh"
