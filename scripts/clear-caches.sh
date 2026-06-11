#!/usr/bin/env bash
# Czyści cache Laravel, Symfony i .NET (build + skompilowane widoki Razor).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

log() { echo "==> $*"; }

log "Laravel — config, cache, route, view..."
"$ROOT/scripts/compose.sh" exec -T php env \
    APP_KEY="${APP_KEY}" \
    DB_PASSWORD="${POSTGRES_PASSWORD}" \
    sh -c '
        rm -f /app/laravel/bootstrap/cache/*.php 2>/dev/null || true
        php /app/laravel/artisan config:clear 2>/dev/null || true
        php /app/laravel/artisan cache:clear 2>/dev/null || true
        php /app/laravel/artisan route:clear 2>/dev/null || true
        php /app/laravel/artisan view:clear 2>/dev/null || true
        rm -rf /app/laravel/storage/framework/cache/data/* 2>/dev/null || true
        rm -rf /app/laravel/storage/framework/views/* 2>/dev/null || true
    '

log "Symfony — var/cache..."
"$ROOT/scripts/compose.sh" exec -T php env \
    APP_SECRET="${APP_SECRET}" \
    APP_ENV=dev \
    DATABASE_URL="${DATABASE_URL:-postgresql://dev:${POSTGRES_PASSWORD}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8}" \
    sh -c '
        php /app/symfony/bin/console cache:clear --no-warmup 2>/dev/null || true
        rm -rf /app/symfony/var/cache/* 2>/dev/null || true
    '

log ".NET — dotnet clean + bin/obj..."
if command -v dotnet >/dev/null 2>&1 && [ -f "$ROOT/dotnet-skeleton/hrk-demo.csproj" ]; then
    (cd "$ROOT/dotnet-skeleton" && dotnet clean -v q && rm -rf bin obj)
    echo "    bin/obj usunięte"
else
    echo "    SKIP (brak .NET SDK lub dotnet-skeleton/)"
fi

echo "Cache wyczyszczony."
