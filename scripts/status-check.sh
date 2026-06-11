#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

PASS=0
FAIL=0
ok()   { echo "OK   $*"; PASS=$((PASS + 1)); }
fail() { echo "FAIL $*"; FAIL=$((FAIL + 1)); }

echo "=== Kontenery ==="
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || fail "docker compose ps"

echo ""
echo "=== HTTP ==="
for spec in "8080:Adminer" "8000:Laravel" "8001:Symfony"; do
    port="${spec%%:*}"
    name="${spec##*:}"
    code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 3 "http://localhost:${port}" 2>/dev/null || echo "000")
    if [ "$code" = "200" ] || { [ "$name" = "Symfony" ] && [ "$code" = "404" ]; }; then
        ok "$name :$port HTTP $code"
    else
        fail "$name :$port HTTP $code"
    fi
done

echo ""
echo "=== PostgreSQL ==="
cnt=$(docker exec hrk-postgres psql -U dev -d hrk_demo -tAc "SELECT COUNT(*) FROM invoices;" 2>/dev/null || echo "?")
if [ "$cnt" = "5" ]; then ok "PostgreSQL — $cnt faktur"
else fail "PostgreSQL — invoices=$cnt"; fi

echo ""
echo "=== MS SQL ==="
NETWORK=$(docker inspect hrk-sqlserver --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null | head -1)
if [ -n "$NETWORK" ]; then
    mcnt=$(docker run --rm --network "$NETWORK" mcr.microsoft.com/mssql-tools:latest \
        /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" \
        -h -1 -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM dbo.invoices;" 2>/dev/null | tr -d ' \r\n' || echo "?")
    if [ "$mcnt" = "5" ]; then ok "MS SQL — $mcnt faktur"
    else fail "MS SQL — invoices=$mcnt"; fi
else
    fail "MS SQL — brak sieci kontenera"
fi

echo ""
echo "=== Laravel APP_KEY ==="
ver=$(docker exec hrk-php env APP_KEY="$APP_KEY" php /app/laravel/artisan --version 2>/dev/null || echo "ERR")
if [[ "$ver" == Laravel* ]]; then ok "$ver"
else fail "Laravel artisan: $ver"; fi

echo ""
echo "=== Symfony ==="
sver=$(docker exec hrk-php env APP_SECRET="$APP_SECRET" php /app/symfony/bin/console --version 2>/dev/null || echo "ERR")
if [[ "$sver" == Symfony* ]]; then ok "$sver"
else fail "Symfony console: $sver"; fi

echo ""
if [ "$FAIL" -eq 0 ]; then
    echo "Wszystko działa ($PASS/$((PASS+FAIL)) testów)."
    exit 0
else
    echo "Problemy: $FAIL/$((PASS+FAIL)) testów nie przeszło."
    exit 1
fi
