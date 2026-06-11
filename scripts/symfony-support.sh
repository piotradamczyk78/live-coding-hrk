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

symfony_console_it() {
    docker exec -it hrk-php env \
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
    "Liczba faktur (doctrine:query:sql)" \
        "symfony_console doctrine:query:sql 'SELECT COUNT(*) FROM invoices'" \
    "5 faktur z klientami (JOIN)" \
        "symfony_console doctrine:query:sql 'SELECT i.number, c.name, i.amount FROM invoices i JOIN customers c ON c.id = i.customer_id LIMIT 5'" \
    "DBAL — surowe SQL" \
        "symfony_console dbal:run-sql 'SELECT * FROM invoices LIMIT 3'" \
    "Wyczyść cache Symfony" \
        "symfony_console cache:clear --no-warmup" \
    "Wygeneruj kontroler API (make:controller)" \
        "docker exec -it -w /app/symfony hrk-php env APP_SECRET='${APP_SECRET}' APP_ENV=dev DATABASE_URL='${SYMFONY_DATABASE_URL}' php bin/console make:controller Api/InvoiceController" \
    "Wygeneruj encję Invoice (make:entity)" \
        "docker exec -it -w /app/symfony hrk-php env APP_SECRET='${APP_SECRET}' APP_ENV=dev DATABASE_URL='${SYMFONY_DATABASE_URL}' php bin/console make:entity Invoice" \
    "Test API — nieopłacone faktury" \
        "curl -s http://localhost:8001/api/invoices/unpaid | head -c 500; echo" \
    "Test web — lista faktur (HTTP)" \
        "curl -s -o /dev/null -w 'GET /invoices → HTTP %{http_code}\n' http://localhost:8001/invoices"
