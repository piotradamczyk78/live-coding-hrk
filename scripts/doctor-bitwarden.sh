#!/usr/bin/env bash
# Faza Bitwarden dla make doctor:
# - odblokowanie sejfu
# - seed secretów do vault (jeśli brak)
# - synchronizacja plików konfiguracyjnych (tylko etykiety {{bw:...}})
# - weryfikacja braku plaintext w .env

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck source=lib.sh
source "$ROOT/scripts/bitwarden/lib.sh"

log() { echo "==> $*"; }

verify_placeholders() {
    local file="$1"
    local line key value

    [ -f "$file" ] || return 0

    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^(APP_KEY|APP_SECRET|DB_PASSWORD|POSTGRES_PASSWORD|MSSQL_SA_PASSWORD)= ]] || continue

        key="${line%%=*}"
        value="${line#*=}"
        value="${value%$'\r'}"

        if [[ "$value" == *'{{bw:'* ]]; then
            continue
        fi

        if [ -z "$value" ]; then
            echo "Błąd: $file — $key jest puste (oczekiwano {{bw:etykieta}})" >&2
            return 1
        fi

        echo "Błąd: $file — $key ma plaintext zamiast etykiety Bitwarden" >&2
        return 1
    done <"$file"
}

log "Bitwarden — odblokowanie sejfu..."
bw_load_session
bw_save_session

if [ ! -f "$ROOT/.secrets/defaults.env" ]; then
    log "Brak .secrets/defaults.env — generowanie..."
    "$ROOT/scripts/bitwarden/secrets-generate-defaults.sh"
fi

log "Bitwarden — seed secretów (hasła w vault)..."
"$ROOT/scripts/bitwarden/secrets-seed.sh"

log "Bitwarden — synchronizacja plików konfiguracyjnych (etykiety {{bw:...}})..."
"$ROOT/scripts/bitwarden/secrets-sync.sh"

log "Weryfikacja: pliki konfiguracyjne bez plaintext..."
ERR=0
verify_placeholders "$ROOT/laravel/.env" || ERR=1
verify_placeholders "$ROOT/symfony/.env" || ERR=1
verify_placeholders "$ROOT/docker-compose.env.template" || ERR=1

if [ "$ERR" -ne 0 ]; then
    echo "Uruchom: make secrets-scan-apply  (migracja pozostałych secretów do Bitwarden)" >&2
    exit 1
fi

# Wymuś świeże secrety z Bitwarden (nie cache defaults.env)
rm -f "$ROOT/.secrets/runtime.env"

log "Ładowanie secretów z Bitwarden (runtime)..."
# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

if [[ -z "${APP_KEY:-}" || "$APP_KEY" == *'{{bw:'* ]]; then
    echo "Błąd: nie udało się rozwiązać APP_KEY z Bitwarden" >&2
    exit 1
fi

log "Etykiety w Bitwarden:"
"$ROOT/scripts/bitwarden/secrets-list.sh"

echo ""
echo "Bitwarden OK — hasła w vault, konfiguracja ma wyłącznie etykiety {{bw:...}}."
