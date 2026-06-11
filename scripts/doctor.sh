#!/usr/bin/env bash
# Pełna stabilizacja środowiska — kontenery, DB, serwery, smoke testy.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

export MSSQL_SA_PASSWORD="${MSSQL_SA_PASSWORD:?}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:?}"
export DATABASE_URL="${DATABASE_URL:?postgresql://dev:${POSTGRES_PASSWORD}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8}"

log() { echo "==> $*"; }

log "Uruchamianie kontenerów Docker..."
"$ROOT/scripts/compose.sh" up -d

log "Oczekiwanie na PostgreSQL..."
for i in $(seq 1 60); do
    if "$ROOT/scripts/compose.sh" exec -T postgres pg_isready -U dev -d hrk_demo >/dev/null 2>&1; then
        break
    fi
    sleep 1
done

log "Synchronizacja haseł DB (legacy → Bitwarden)..."
"$ROOT/scripts/sync-db-passwords.sh"

log "Sprawdzanie schematu PostgreSQL..."
INVOICE_COUNT="$("$ROOT/scripts/compose.sh" exec -T postgres psql -U dev -d hrk_demo -tAc "SELECT COUNT(*) FROM invoices;" 2>/dev/null || echo 0)"
if [ "${INVOICE_COUNT:-0}" -lt 1 ]; then
    log "Ładowanie schematu PG (brak danych lub świeży wolumen)..."
    "$ROOT/scripts/compose.sh" exec -T postgres psql -U dev -d hrk_demo -f /docker-entrypoint-initdb.d/01-schema.sql 2>/dev/null \
        || "$ROOT/scripts/compose.sh" exec -T -i postgres psql -U dev -d hrk_demo < "$ROOT/sql/schema-postgresql.sql"
fi

log "Inicjalizacja MS SQL..."
"$ROOT/scripts/init-mssql.sh" || echo "UWAGA: MS SQL init nieudany — sprawdź: docker compose logs sqlserver"

log "Czyszczenie cache Laravel..."
"$ROOT/scripts/compose.sh" exec -T php sh -c "rm -f /app/laravel/bootstrap/cache/config.php; php /app/laravel/artisan config:clear 2>/dev/null || true"

log "Weryfikacja podstawowa (verify.sh)..."
"$ROOT/scripts/verify.sh"

log "Uruchamianie serwerów dev w tle..."
pkill -f "artisan serve --host=0.0.0.0 --port=8000" 2>/dev/null || true
pkill -f "php -S 0.0.0.0:8001" 2>/dev/null || true

nohup "$ROOT/scripts/laravel-serve.sh" > /tmp/hrk-laravel.log 2>&1 &
LARAVEL_PID=$!
nohup "$ROOT/scripts/symfony-serve.sh" > /tmp/hrk-symfony.log 2>&1 &
SYMFONY_PID=$!

sleep 3

wait_http() {
    local url="$1" name="$2"
    for i in $(seq 1 30); do
        code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
        if [ "$code" = "200" ]; then
            echo "OK  $name ($url) — HTTP $code"
            return 0
        fi
        sleep 1
    done
    echo "FAIL $name ($url) — ostatni HTTP $code" >&2
    echo "--- log Laravel ---" >&2; tail -20 /tmp/hrk-laravel.log >&2 || true
    echo "--- log Symfony ---" >&2; tail -20 /tmp/hrk-symfony.log >&2 || true
    return 1
}

ERR=0
wait_http "http://localhost:8080" "Adminer" || ERR=1
wait_http "http://localhost:8000" "Laravel" || ERR=1
wait_http "http://localhost:8001" "Symfony" || ERR=1

if command -v dotnet >/dev/null 2>&1 && [ -f "$ROOT/dotnet-skeleton/hrk-demo.csproj" ]; then
    log ".NET SDK dostępny — build szkieletu..."
    (cd "$ROOT/dotnet-skeleton" && dotnet build -v q) && echo "OK  .NET build" || { echo "FAIL .NET build" >&2; ERR=1; }
else
    echo "SKIP .NET (brak SDK lokalnie — szkielet w dotnet-skeleton/)"
fi

if [ "${RUN_PLAYWRIGHT:-0}" = "1" ] && [ -f "$ROOT/e2e/package.json" ]; then
    log "Playwright smoke testy..."
    (cd "$ROOT/e2e" && npm test) || ERR=1
fi

if [ "$ERR" -eq 0 ]; then
    echo ""
    echo "Środowisko GOTOWE."
    echo "  Laravel  → http://localhost:8000  (PID $LARAVEL_PID)"
    echo "  Symfony  → http://localhost:8001  (PID $SYMFONY_PID)"
    echo "  Adminer  → http://localhost:8080"
    echo "  PostgreSQL :5432 | MS SQL :1433"
else
    echo ""
    echo "Środowisko częściowo działa — sprawdź logi powyżej." >&2
    exit 1
fi
