#!/usr/bin/env bash
# Naprawia manifest.json — pobiera poprawne ID z Bitwarden po nazwie etykiety.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/bitwarden/lib.sh"

bw_load_session

echo "==> Naprawa manifestu secretów"

while IFS= read -r label; do
    item_id="$(bw_lookup_item_id_in_vault "$label")"
    if bw_is_uuid "$item_id"; then
        source_file="$(jq -r --arg l "$label" '.secrets[$l].source_file // "secrets-repair-manifest.sh"' "$BW_MANIFEST")"
        source_key="$(jq -r --arg l "$label" '.secrets[$l].source_key // "repair"' "$BW_MANIFEST")"
        bw_manifest_upsert "$label" "$item_id" "$source_file" "$source_key"
        echo "  OK $label → $item_id"
    else
        echo "  BRAK $label" >&2
    fi
done < <(jq -r '.secrets | keys[]' "$BW_MANIFEST")

echo "Manifest naprawiony."
