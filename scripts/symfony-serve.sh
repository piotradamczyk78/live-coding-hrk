#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

if [[ -z "${APP_SECRET:-}" || "$APP_SECRET" == *'{{bw:'* ]]; then
    echo "Błąd: APP_SECRET nie ustawiony." >&2
    exit 1
fi

exec docker exec -it hrk-php env \
    APP_SECRET="${APP_SECRET}" \
    DATABASE_URL="${DATABASE_URL:-postgresql://dev:${POSTGRES_PASSWORD}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8}" \
    APP_ENV=dev \
    php -S 0.0.0.0:8001 -t /app/symfony/public
