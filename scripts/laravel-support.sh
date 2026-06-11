#!/usr/bin/env bash
# Interaktywne menu komend Laravel.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"
# shellcheck disable=SC1091
source "$ROOT/scripts/lib/support-menu.sh"

laravel_artisan() {
    "$ROOT/scripts/compose.sh" exec -T php env \
        APP_KEY="${APP_KEY}" \
        DB_PASSWORD="${POSTGRES_PASSWORD}" \
        DB_CONNECTION=pgsql \
        DB_HOST=postgres \
        DB_PORT=5432 \
        DB_DATABASE=hrk_demo \
        DB_USERNAME=dev \
        php /app/laravel/artisan "$@"
}

laravel_artisan_it() {
    docker exec -it hrk-php env \
        APP_KEY="${APP_KEY}" \
        DB_PASSWORD="${POSTGRES_PASSWORD}" \
        DB_CONNECTION=pgsql \
        DB_HOST=postgres \
        DB_PORT=5432 \
        DB_DATABASE=hrk_demo \
        DB_USERNAME=dev \
        php /app/laravel/artisan "$@"
}

support_menu_run "Laravel" \
    "Uruchom serwer dev (:8000)" \
        "./scripts/laravel-serve.sh" \
    "Wersja i informacje (about)" \
        "laravel_artisan --version && laravel_artisan about" \
    "Lista tras (route:list)" \
        "laravel_artisan route:list" \
    "Trasy API (route:list --path=api)" \
        "laravel_artisan route:clear && laravel_artisan route:list --path=api" \
    "Połączenie DB (db:show)" \
        "laravel_artisan db:show" \
    "Status migracji" \
        "laravel_artisan migrate:status" \
    "Tinker (interaktywny REPL)" \
        "laravel_artisan_it tinker" \
    "Wyczyść cache (config, cache, route, view)" \
        "laravel_artisan config:clear && laravel_artisan cache:clear && laravel_artisan route:clear && laravel_artisan view:clear" \
    "Napraw APP_KEY w .env (po secrets-sync)" \
        "./scripts/laravel-env-patch.sh" \
    "Wygeneruj kontroler API (szablon)" \
        "laravel_artisan make:controller Api/ExampleController --api" \
    "Wygeneruj model (szablon)" \
        "laravel_artisan make:model Example"
