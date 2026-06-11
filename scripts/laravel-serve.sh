#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

if [[ -z "${APP_KEY:-}" || "$APP_KEY" == *'{{bw:'* ]]; then
    echo "Błąd: APP_KEY nie ustawiony. Uruchom: make bw-unlock && make doctor" >&2
    exit 1
fi

export DB_PASSWORD="${POSTGRES_PASSWORD}"

docker exec hrk-php sh -c "
    if [ -f /app/laravel/.env ]; then
        sed -i.bak 's|^APP_KEY=.*|APP_KEY=${APP_KEY}|' /app/laravel/.env
        sed -i.bak 's|^DB_PASSWORD=.*|DB_PASSWORD=${DB_PASSWORD}|' /app/laravel/.env
    fi
    rm -f /app/laravel/bootstrap/cache/config.php
"
docker exec hrk-php env \
    APP_KEY="${APP_KEY}" \
    DB_PASSWORD="${DB_PASSWORD}" \
    DB_CONNECTION=pgsql \
    DB_HOST=postgres \
    DB_PORT=5432 \
    DB_DATABASE=hrk_demo \
    DB_USERNAME=dev \
    php /app/laravel/artisan config:clear >/dev/null 2>&1 || true

exec docker exec -it hrk-php env \
    APP_KEY="${APP_KEY}" \
    DB_PASSWORD="${DB_PASSWORD}" \
    DB_CONNECTION=pgsql \
    DB_HOST=postgres \
    DB_PORT=5432 \
    DB_DATABASE=hrk_demo \
    DB_USERNAME=dev \
    DATABASE_URL="${DATABASE_URL:-postgresql://dev:${DB_PASSWORD}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8}" \
    php /app/laravel/artisan serve --host=0.0.0.0 --port=8000
