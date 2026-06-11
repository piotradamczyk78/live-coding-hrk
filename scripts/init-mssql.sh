#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

SA_PASSWORD="${MSSQL_SA_PASSWORD:?Ustaw MSSQL_SA_PASSWORD}"
NETWORK="$(docker inspect hrk-sqlserver --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null | head -1)"
SQLCMD_IMAGE="mcr.microsoft.com/mssql-tools:latest"

sqlcmd_exec() {
    docker run --rm -i \
        --network "$NETWORK" \
        -v "$ROOT/sql/schema-mssql.sql:/schema-mssql.sql:ro" \
        "$SQLCMD_IMAGE" \
        /opt/mssql-tools/bin/sqlcmd \
            -S sqlserver \
            -U sa \
            -P "$SA_PASSWORD" \
            "$@"
}

echo "Oczekiwanie na MS SQL..."
for i in $(seq 1 90); do
    if sqlcmd_exec -Q "SELECT 1" >/dev/null 2>&1; then
        break
    fi
    if [ "$i" -eq 90 ]; then
        echo "MS SQL nie wystartował w czasie. Sprawdź: docker compose logs sqlserver"
        exit 1
    fi
    sleep 2
done

echo "Ładowanie schematu T-SQL..."
sqlcmd_exec -i /schema-mssql.sql

echo "MS SQL gotowy."
