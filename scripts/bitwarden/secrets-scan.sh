#!/usr/bin/env bash
# Skanuje pliki, wykrywa secrety, zapisuje je w Bitwarden i zastępuje placeholderami {{bw:etykieta}}.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/bitwarden/lib.sh"

DRY_RUN=1
APPLY=0

usage() {
    cat <<'EOF'
Użycie: secrets-scan.sh [--dry-run] [--apply]

  --dry-run   (domyślnie) pokaż co zostanie zmigrowane, bez zmian w plikach
  --apply     zapisz secrety w Bitwarden i zamień wartości na {{bw:etykieta}}

Wymaga: bw zalogowane i odblokowane (make bw-unlock)
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run) DRY_RUN=1; APPLY=0 ;;
        --apply) DRY_RUN=0; APPLY=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Nieznany argument: $1" >&2; usage; exit 1 ;;
    esac
    shift
done

cd "$ROOT"
bw_load_session
mkdir -p "$BW_SECRETS_DIR"

file_stem() {
    local path="$1"
    basename "$path" | sed 's/\.[^.]*$//' | tr '[:upper:]' '[:lower:]' | tr '-' '_'
}

key_lower() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

make_label() {
    local template="$1"
    local file="$2"
    local key="${3:-}"
    local stem
    stem="$(file_stem "$file")"
    template="${template//\{prefix\}/$BW_LABEL_PREFIX}"
    template="${template//\{file_stem\}/$stem}"
    template="${template//\{key_lower\}/$(key_lower "$key")}"
    printf '%s' "$template"
}

scan_env_assignments() {
    local file="$1"
    local line key value label placeholder rule_template

    rule_template="$(jq -r '.rules[] | select(.id=="env_assignment") | .label_template' "$BW_CONFIG")"

    while IFS= read -r line; do
        [[ "$line" =~ ^([A-Z][A-Z0-9_]*(?:PASSWORD|SECRET|KEY|TOKEN)[A-Z0-9_]*)=(.+)$ ]] || continue
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        value="${value%\"}"; value="${value#\"}"
        value="${value%\'}"; value="${value#\'}"

        bw_should_skip_value "$value" && continue

        label="$(make_label "$rule_template" "$file" "$key")"
        placeholder="$(bw_placeholder "$label")"

        echo "  [$file] $key → $label"
        if [ "$APPLY" -eq 1 ]; then
            item_id="$(bw_create_secret "$label" "$value" "Źródło: $file | Klucz: $key")"
            bw_manifest_upsert "$label" "$item_id" "$file" "$key"
            sed -i.bak "s|^${key}=.*|${key}=${placeholder}|" "$file"
            rm -f "${file}.bak"
        fi
    done <"$file"
}

scan_yaml_passwords() {
    local file="$1"
    local line key value label placeholder rule_template

    rule_template="$(jq -r '.rules[] | select(.id=="yaml_password") | .label_template' "$BW_CONFIG")"

    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*([A-Z][A-Z0-9_]*PASSWORD):[[:space:]]+ ]] || continue
        key="${BASH_REMATCH[1]}"
        value="$(printf '%s' "$line" | sed -E 's/^[[:space:]]*[A-Z_]*PASSWORD:[[:space:]]*//; s/^["'\'']//; s/["'\'']$//; s/[[:space:]]+#.*//')"

        bw_should_skip_value "$value" && continue

        label="$(make_label "$rule_template" "$file" "$key")"
        placeholder="$(bw_placeholder "$label")"

        echo "  [$file] $key → $label"
        if [ "$APPLY" -eq 1 ]; then
            item_id="$(bw_create_secret "$label" "$value" "Źródło: $file | Klucz: $key")"
            bw_manifest_upsert "$label" "$item_id" "$file" "$key"
            sed -i.bak "s|${key}:.*|${key}: \"${placeholder}\"|" "$file"
            rm -f "${file}.bak"
        fi
    done <"$file"
}

scan_sqlcmd_passwords() {
    local file="$1"
    local label placeholder value rule_template item_id

    rule_template="$(jq -r '.rules[] | select(.id=="sqlcmd_password_flag") | .label_template' "$BW_CONFIG")"
    label="$(make_label "$rule_template" "$file" "mssql_sa_password")"

    if grep -q "${BW_PLACEHOLDER_PREFIX}" "$file" 2>/dev/null; then
        return 0
    fi

    value="$(grep -Eo "\-P ['\"][^'\"]+['\"]" "$file" | head -1 | sed -E "s/-P ['\"]//; s/['\"]$//")"
    [ -n "$value" ] || return 0
    bw_should_skip_value "$value" && return 0

    placeholder="$(bw_placeholder "$label")"
    echo "  [$file] sqlcmd -P → $label"

    if [ "$APPLY" -eq 1 ]; then
        item_id="$(bw_create_secret "$label" "$value" "Źródło: $file | sqlcmd -P")"
        bw_manifest_upsert "$label" "$item_id" "$file" "MSSQL_SA_PASSWORD"
        sed -i.bak "s|-P ['\"][^'\"]*['\"]|-P \"\${MSSQL_SA_PASSWORD}\"|g" "$file"
        rm -f "${file}.bak"
    fi
}

scan_connection_string_passwords() {
    local file="$1"
    local label placeholder value rule_template item_id

    rule_template="$(jq -r '.rules[] | select(.id=="connection_string_password") | .label_template' "$BW_CONFIG")"
    label="$(make_label "$rule_template" "$file" "postgres-password")"

    value="$(grep -Eo 'postgresql://[^:]+:[^@]+@' "$file" | head -1 | sed -E 's|postgresql://[^:]+:||; s|@$||')"
    [ -n "$value" ] || return 0
    bw_should_skip_value "$value" && return 0

    placeholder="$(bw_placeholder "$label")"
    echo "  [$file] DATABASE_URL password → $label"

    if [ "$APPLY" -eq 1 ]; then
        item_id="$(bw_create_secret "$label" "$value" "Źródło: $file | connection string")"
        bw_manifest_upsert "$label" "$item_id" "$file" "DATABASE_URL"
        sed -i.bak -E "s|postgresql://([^:]+):[^@]+@|postgresql://\1:${placeholder}@|g" "$file"
        rm -f "${file}.bak"
    fi
}

scan_app_keys() {
    local file="$1"
    local line key value label placeholder rule_template item_id

    rule_template="$(jq -r '.rules[] | select(.id=="laravel_app_key") | .label_template' "$BW_CONFIG")"

    while IFS= read -r line; do
        [[ "$line" =~ ^APP_KEY=(base64:[A-Za-z0-9+/=]+)$ ]] || continue
        value="${BASH_REMATCH[1]}"

        bw_should_skip_value "$value" && continue

        label="$(make_label "$rule_template" "$file" "app-key")"
        placeholder="$(bw_placeholder "$label")"

        echo "  [$file] APP_KEY → $label"
        if [ "$APPLY" -eq 1 ]; then
            item_id="$(bw_create_secret "$label" "$value" "Źródło: $file | APP_KEY")"
            bw_manifest_upsert "$label" "$item_id" "$file" "APP_KEY"
            sed -i.bak "s|^APP_KEY=.*|APP_KEY=${placeholder}|" "$file"
            rm -f "${file}.bak"
        fi
    done <"$file"
}

scan_symfony_app_secret() {
    local file="$1"
    local value label placeholder item_id

    value="$(grep -E '^APP_SECRET=' "$file" | head -1 | cut -d= -f2- | tr -d '"')"
    [ -n "$value" ] || return 0
    bw_should_skip_value "$value" && return 0

    label="${BW_LABEL_PREFIX}/symfony/app-secret"
    placeholder="$(bw_placeholder "$label")"

    echo "  [$file] APP_SECRET → $label"
    if [ "$APPLY" -eq 1 ]; then
        item_id="$(bw_create_secret "$label" "$value" "Źródło: $file | APP_SECRET")"
        bw_manifest_upsert "$label" "$item_id" "$file" "APP_SECRET"
        sed -i.bak "s|^APP_SECRET=.*|APP_SECRET=${placeholder}|" "$file"
        rm -f "${file}.bak"
    fi
}

echo "==> Skan secretów (tryb: $([ "$APPLY" -eq 1 ] && echo APPLY || echo DRY-RUN))"

while IFS= read -r rel_path; do
    [ -f "$rel_path" ] || continue
    echo ""
    echo "Plik: $rel_path"
    scan_env_assignments "$rel_path"
    scan_yaml_passwords "$rel_path"
    scan_app_keys "$rel_path"
    scan_symfony_app_secret "$rel_path"
    scan_connection_string_passwords "$rel_path"
    scan_sqlcmd_passwords "$rel_path"
done < <(jq -r '.scan_paths[]' "$BW_CONFIG")

echo ""
if [ "$APPLY" -eq 1 ]; then
    echo "Migracja zakończona. Manifest: $BW_MANIFEST"
    echo "Następnie: make secrets-sync && make up"
else
    echo "Dry-run zakończony. Aby zastosować: ./scripts/bitwarden/secrets-scan.sh --apply"
fi
