#!/usr/bin/env bash
set -euo pipefail

echo "==> Instalacja Bitwarden CLI"

if command -v bw >/dev/null 2>&1; then
    echo "Bitwarden CLI już zainstalowane: $(bw --version)"
    exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "Błąd: Homebrew nie znaleziony. Zainstaluj ręcznie: https://bitwarden.com/help/cli/" >&2
    exit 1
fi

brew install bitwarden-cli jq

echo ""
echo "Zainstalowano: $(bw --version)"
echo ""
echo "Następne kroki:"
echo "  make bw-login     # jednorazowe logowanie"
echo "  make bw-unlock    # odblokowanie sejfu przed pracą"
echo "  make secrets-scan # skan i migracja secretów do Bitwarden (pierwszy raz)"
