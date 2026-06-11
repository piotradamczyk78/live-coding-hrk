#!/usr/bin/env bash
# Interaktywne menu komend Symfony.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"
# shellcheck disable=SC1091
source "$ROOT/scripts/lib/support-menu.sh"

SYMFONY_DATABASE_URL="${DATABASE_URL:-postgresql://dev:${POSTGRES_PASSWORD}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8}"

symfony_console() {
    "$ROOT/scripts/compose.sh" exec -T php env \
        APP_SECRET="${APP_SECRET}" \
        APP_ENV=dev \
        DATABASE_URL="${SYMFONY_DATABASE_URL}" \
        php /app/symfony/bin/console "$@"
}

support_menu_run "Symfony" \
    "Uruchom serwer dev (:8001)" \
        "./scripts/symfony-serve.sh" \
    "Wersja Symfony" \
        "symfony_console --version" \
    "Lista komend (list)" \
        "symfony_console list" \
    "Mapa tras (debug:router)" \
        "symfony_console debug:router" \
    "Test połączenia DB (SELECT 1)" \
        "symfony_console doctrine:query:sql 'SELECT 1 AS ok'" \
    "Lista tabel (information_schema)" \
        "symfony_console doctrine:query:sql \"SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name\"" \
    "DBAL — surowe SQL (SELECT version())" \
        "symfony_console dbal:run-sql 'SELECT version()'" \
    "Wyczyść cache Symfony" \
        "symfony_console cache:clear --no-warmup" \
    "Wygeneruj kontroler (make:controller)" \
        "docker exec -it -w /app/symfony hrk-php env APP_SECRET='${APP_SECRET}' APP_ENV=dev DATABASE_URL='${SYMFONY_DATABASE_URL}' php bin/console make:controller Api/ExampleController" \
    "Wygeneruj encję (make:entity)" \
        "docker exec -it -w /app/symfony hrk-php env APP_SECRET='${APP_SECRET}' APP_ENV=dev DATABASE_URL='${SYMFONY_DATABASE_URL}' php bin/console make:entity Example"
