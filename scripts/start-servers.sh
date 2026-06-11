#!/usr/bin/env bash
# Uruchamia Laravel (:8000) i Symfony (:8001) w tle z poprawnymi secretami.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

RUNTIME_DIR="$ROOT/.secrets/runtime"
mkdir -p "$RUNTIME_DIR"

cat >"$RUNTIME_DIR/start-laravel.sh" <<EOF
#!/bin/sh
export APP_KEY='${APP_KEY}'
export DB_PASSWORD='${POSTGRES_PASSWORD}'
export DB_CONNECTION=pgsql
export DB_HOST=postgres
export DB_PORT=5432
export DB_DATABASE=hrk_demo
export DB_USERNAME=dev
# Laravel czyta .env nawet gdy APP_KEY jest w env — nadpisz runtime (plik gitignored)
if [ -f /app/laravel/.env ]; then
  sed -i.bak "s|^APP_KEY=.*|APP_KEY=${APP_KEY}|" /app/laravel/.env
  sed -i.bak "s|^DB_PASSWORD=.*|DB_PASSWORD=${POSTGRES_PASSWORD}|" /app/laravel/.env
  sed -i.bak 's|^SESSION_DRIVER=.*|SESSION_DRIVER=file|' /app/laravel/.env
fi
export SESSION_DRIVER=file
rm -f /app/laravel/bootstrap/cache/config.php
php /app/laravel/artisan config:clear >/dev/null 2>&1 || true
exec php /app/laravel/artisan serve --host=0.0.0.0 --port=8000
EOF

cat >"$RUNTIME_DIR/start-symfony.sh" <<EOF
#!/bin/sh
export APP_SECRET='${APP_SECRET}'
export APP_ENV=dev
export DATABASE_URL='postgresql://dev:${POSTGRES_PASSWORD}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8'
exec php -S 0.0.0.0:8001 -t /app/symfony/public
EOF

chmod +x "$RUNTIME_DIR/start-laravel.sh" "$RUNTIME_DIR/start-symfony.sh"

docker exec hrk-php sh -c 'pkill -f "artisan serve" 2>/dev/null; pkill -f "php -S 0.0.0.0:8001" 2>/dev/null; pkill -f "Foundation/resources/server.php" 2>/dev/null; true'
sleep 1

docker exec -d hrk-php /app/.secrets/runtime/start-laravel.sh
docker exec -d hrk-php /app/.secrets/runtime/start-symfony.sh

echo "Serwery uruchomione w tle."
echo "  Laravel  → http://localhost:8000"
echo "  Symfony  → http://localhost:8001"
