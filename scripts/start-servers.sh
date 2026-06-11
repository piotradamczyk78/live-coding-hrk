#!/usr/bin/env bash
# Uruchamia Laravel (:8000) i Symfony (:8001) w tle z poprawnymi secretami.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

RUNTIME_DIR="$ROOT/.secrets/runtime"
mkdir -p "$RUNTIME_DIR"

"$ROOT/scripts/laravel-env-patch.sh"

cat >"$RUNTIME_DIR/start-laravel.sh" <<'EOF'
#!/bin/sh
# APP_KEY i DB_PASSWORD wstrzyknięte przez laravel-env-patch.sh
export DB_CONNECTION=pgsql
export DB_HOST=postgres
export DB_PORT=5432
export DB_DATABASE=hrk_demo
export DB_USERNAME=dev
export SESSION_DRIVER=file
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
