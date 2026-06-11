#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

"$ROOT/scripts/laravel-env-patch.sh"

export DB_PASSWORD="${POSTGRES_PASSWORD}"

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
