#!/usr/bin/env bash
# Interaktywne menu komend PHP (kontener hrk-php).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"
# shellcheck disable=SC1091
source "$ROOT/scripts/lib/support-menu.sh"

php_exec() {
    "$ROOT/scripts/compose.sh" exec -T php "$@"
}

php_exec_it() {
    docker exec -it hrk-php "$@"
}

support_menu_run "PHP 8.3" \
    "Wejście do kontenera (bash)" \
        "php_exec_it bash" \
    "Wersja PHP" \
        "php_exec php -v" \
    "Wersja Composer" \
        "php_exec composer --version" \
    "Rozszerzenia DB (pdo, pgsql, intl)" \
        "php_exec php -m | grep -E '^(pdo|pdo_pgsql|pgsql|intl|zip)$' || php_exec php -m | grep -E 'pdo|pgsql|intl'" \
    "Test połączenia PDO → PostgreSQL" \
        "php_exec php -r \"\\\$p = new PDO('pgsql:host=postgres;port=5432;dbname=hrk_demo', 'dev', '${POSTGRES_PASSWORD}'); echo 'OK: ' . \\\$p->query('SELECT version()')->fetchColumn() . \"\n\";\"" \
    "Laravel — wersja artisan" \
        "php_exec env APP_KEY='${APP_KEY}' DB_PASSWORD='${POSTGRES_PASSWORD}' php /app/laravel/artisan --version" \
    "Symfony — wersja console" \
        "php_exec env APP_SECRET='${APP_SECRET}' DATABASE_URL='${DATABASE_URL:-postgresql://dev:${POSTGRES_PASSWORD}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8}' php /app/symfony/bin/console --version" \
    "Composer diagnose (laravel/)" \
        "php_exec composer diagnose --working-dir=/app/laravel" \
    "Composer diagnose (symfony/)" \
        "php_exec composer diagnose --working-dir=/app/symfony" \
    "Lista pakietów Laravel (composer show -D)" \
        "php_exec composer show -D --working-dir=/app/laravel 2>/dev/null | head -20" \
    "Lista pakietów Symfony (composer show -D)" \
        "php_exec composer show -D --working-dir=/app/symfony 2>/dev/null | head -20" \
    "Przebuduj obraz PHP (docker compose build)" \
        "./scripts/bitwarden/secrets-wrap.sh ./scripts/compose.sh build php" \
    "Restart kontenera PHP" \
        "./scripts/compose.sh restart php"
