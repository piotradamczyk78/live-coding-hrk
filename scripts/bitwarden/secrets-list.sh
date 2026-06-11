#!/usr/bin/env bash
# Lista secretów zarejestrowanych w manifeście + status w Bitwarden.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/bitwarden/lib.sh"

bw_load_session

echo "==> Secrety hrk-live-coding"
echo ""

jq -r '.secrets | to_entries[] | "\(.key)\t\(.value.source_file)\t\(.value.placeholder)"' "$BW_MANIFEST" | while IFS=$'\t' read -r label source placeholder; do
    status="OK"
    if ! bw_item_exists "$label"; then
        status="BRAK W BW"
    fi
    printf "%-45s %-25s %s\n" "$label" "$status" "$source"
done

echo ""
echo "Foldery Bitwarden:"
bw list folders --search "$BW_FOLDER_NAME" --session "$BW_SESSION" | jq -r '.[] | "  \(.name) (id: \(.id))"'
