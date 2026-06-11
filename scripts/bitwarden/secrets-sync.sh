#!/usr/bin/env bash
# Kopiuje szablony z placeholderami {{bw:...}} do plików .env — BEZ rozwijania secretów.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

sync_one() {
    local template="$1"
    local target="$2"

    if [ ! -f "$template" ]; then
        echo "Pominięto (brak szablonu): $template" >&2
        return 0
    fi

    mkdir -p "$(dirname "$target")"
    cp "$template" "$target"
    echo "  → $target (placeholdery {{bw:...}})"
}

echo "==> Synchronizacja plików .env z szablonami (bez haseł w plaintext)"

sync_one "$ROOT/templates/laravel.env.template" "$ROOT/laravel/.env"
sync_one "$ROOT/templates/symfony.env.template" "$ROOT/symfony/.env"

echo ""
echo "Gotowe. Secrety pozostają jako {{bw:etykieta}} w plikach."
echo "Uruchamiaj komendy przez: make up  (albo ./scripts/bitwarden/secrets-wrap.sh ...)"
