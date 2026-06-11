#!/usr/bin/env bash
# Jednorazowe załadowanie secretów z .secrets/defaults.env do Bitwarden.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DEFAULTS="$ROOT/.secrets/defaults.env"
# shellcheck source=lib.sh
source "$ROOT/scripts/bitwarden/lib.sh"

if [ ! -f "$DEFAULTS" ]; then
    echo "Brak $DEFAULTS" >&2
    echo "Uruchom: make secrets-generate-defaults" >&2
    exit 1
fi

set -a
# shellcheck disable=SC1090
source "$DEFAULTS"
set +a

for var in POSTGRES_PASSWORD MSSQL_SA_PASSWORD LARAVEL_APP_KEY SYMFONY_APP_SECRET; do
    if [ -z "${!var:-}" ]; then
        echo "Błąd: $var jest puste w $DEFAULTS" >&2
        exit 1
    fi
done

bw_load_session

seed_one() {
    local label="$1"
    local value="$2"
    local item_id
    if ! item_id="$(bw_create_secret "$label" "$value" "Secret live-coding-hrk — seed z defaults.env")"; then
        echo "Błąd seed: $label" >&2
        exit 1
    fi
    bw_manifest_upsert "$label" "$item_id" "secrets-seed.sh" "seed"
}

echo "==> Seed secretów do Bitwarden (z $DEFAULTS)"

seed_one "${BW_LABEL_PREFIX}/docker/postgres-password" "$POSTGRES_PASSWORD"
seed_one "${BW_LABEL_PREFIX}/docker/mssql-sa-password" "$MSSQL_SA_PASSWORD"
seed_one "${BW_LABEL_PREFIX}/db/postgres-password" "$POSTGRES_PASSWORD"
seed_one "${BW_LABEL_PREFIX}/laravel/app-key" "$LARAVEL_APP_KEY"
seed_one "${BW_LABEL_PREFIX}/symfony/app-secret" "$SYMFONY_APP_SECRET"

echo ""
echo "Seed zakończony. Uruchom: make secrets-sync && make up"
