#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/bitwarden/lib.sh"

bw_require_cli

if bw login --check >/dev/null 2>&1; then
    echo "Już zalogowany do Bitwarden CLI."
    bw login --check
    exit 0
fi

echo "Logowanie do Bitwarden CLI..."
echo "Podaj e-mail konta Bitwarden."
bw login

echo ""
echo "Zalogowano. Teraz: make bw-unlock"
