#!/usr/bin/env bash
# Rozwija placeholdery {{bw:etykieta}} z Bitwarden do zmiennych środowiskowych (runtime).
# Nie zapisuje haseł do plików .env.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/bitwarden/lib.sh"

bw_load_session

export_line() {
    local line="$1"
    local key value resolved

    [[ "$line" =~ ^[[:space:]]*# ]] && return 0
    [[ "$line" =~ ^[A-Z][A-Z0-9_]*= ]] || return 0

    key="${line%%=*}"
    value="${line#*=}"
    value="${value%$'\r'}"

    if [[ "$value" == \"*\" ]]; then
        value="${value#\"}"
        value="${value%\"}"
    fi

    if [[ "$value" == *'{{bw:'* ]]; then
        resolved="$(bw_resolve_placeholders_in_string "$value")"
    else
        resolved="$value"
    fi

    printf 'export %s=%q\n' "$key" "$resolved"
}

export_template_file() {
    local file="$1"
    local line

    [ -f "$file" ] || return 0

    while IFS= read -r line || [ -n "$line" ]; do
        export_line "$line"
    done <"$file"
}

# Docker Compose + wspólne zmienne
export_template_file "$ROOT/docker-compose.env.template"

# Laravel / Symfony — klucze specyficzne dla frameworków
for key in APP_KEY APP_SECRET; do
    for file in "$ROOT/laravel/.env" "$ROOT/symfony/.env"; do
        [ -f "$file" ] || continue
        line="$(grep -m1 "^${key}=" "$file" 2>/dev/null || true)"
        [ -n "$line" ] && export_line "$line"
    done
done

# Laravel oczekuje DB_PASSWORD (mapowanie z POSTGRES_PASSWORD)
if [ -n "${POSTGRES_PASSWORD:-}" ]; then
    printf 'export %s=%q\n' "DB_PASSWORD" "$POSTGRES_PASSWORD"
fi
