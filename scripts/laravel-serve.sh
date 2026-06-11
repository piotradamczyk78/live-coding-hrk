#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

eval "$("$ROOT/scripts/bitwarden/secrets-export-env.sh")"

export DB_PASSWORD="${POSTGRES_PASSWORD}"

if [[ -z "${APP_KEY:-}" || "$APP_KEY" == *'{{bw:'* ]]; then
    echo "Błąd: APP_KEY nie został rozwinięty z Bitwarden." >&2
    echo "Uruchom: make bw-unlock && make laravel" >&2
    exit 1
fi

if [[ "$APP_KEY" != base64:* ]]; then
    echo "Błąd: APP_KEY musi zaczynać się od 'base64:' (wygeneruj: make secrets-generate-defaults)" >&2
    exit 1
fi

# Wyczyść cache configu (mógł zostać po wcześniejszej próbie z placeholderem)
"$ROOT/scripts/compose.sh" exec -T php php laravel/artisan config:clear >/dev/null 2>&1 || true

"$ROOT/scripts/compose.sh" exec \
    -e "APP_KEY=${APP_KEY}" \
    -e "DB_PASSWORD=${DB_PASSWORD}" \
    -e "DATABASE_URL=${DATABASE_URL}" \
    php php laravel/artisan serve --host=0.0.0.0 --port=8000
