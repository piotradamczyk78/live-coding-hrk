#!/usr/bin/env bash
# Synchronizuje hasła DB z Bitwarden/cache gdy wolumeny Docker mają starsze hasła.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

echo "==> PostgreSQL — ustawianie hasła użytkownika dev..."
docker exec hrk-postgres psql -U dev -d hrk_demo -c \
    "ALTER USER dev WITH PASSWORD '${POSTGRES_PASSWORD}';" >/dev/null

NETWORK="$(docker inspect hrk-sqlserver --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null | head -1)"
SQLCMD="docker run --rm --network $NETWORK mcr.microsoft.com/mssql-tools:latest /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa"

echo "==> MS SQL — synchronizacja hasła SA..."
if $SQLCMD -P "$MSSQL_SA_PASSWORD" -Q "SELECT 1" >/dev/null 2>&1; then
    echo "    Hasło SA już aktualne."
elif $SQLCMD -P 'YourStrong!Pass1' -Q "SELECT 1" >/dev/null 2>&1; then
    $SQLCMD -P 'YourStrong!Pass1' -Q "ALTER LOGIN sa WITH PASSWORD = N'${MSSQL_SA_PASSWORD}';" >/dev/null
    echo "    Hasło SA zaktualizowane (legacy → Bitwarden)."
else
    echo "    UWAGA: nie udało się połączyć z MS SQL — sprawdź: docker compose logs sqlserver" >&2
    exit 1
fi

echo "Hasła zsynchronizowane."
