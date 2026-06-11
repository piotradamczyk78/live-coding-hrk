#!/usr/bin/env bash
# Wspólna biblioteka Bitwarden CLI dla live-coding-hrk.

set -euo pipefail

BW_LIB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BW_SECRETS_DIR="$BW_LIB_ROOT/.secrets"
BW_CONFIG="$BW_SECRETS_DIR/config.json"
BW_MANIFEST="$BW_SECRETS_DIR/manifest.json"
BW_SESSION_FILE="$BW_SECRETS_DIR/.bw-session"
BW_LABEL_PREFIX="hrk-live-coding"
BW_FOLDER_NAME="hrk-live-coding"
BW_PLACEHOLDER_PREFIX='{{bw:'

bw_load_config() {
    if [ -f "$BW_CONFIG" ]; then
        BW_LABEL_PREFIX="$(jq -r '.label_prefix // "hrk-live-coding"' "$BW_CONFIG")"
        BW_FOLDER_NAME="$(jq -r '.folder_name // "hrk-live-coding"' "$BW_CONFIG")"
    fi
}

bw_require_cli() {
    if ! command -v bw >/dev/null 2>&1; then
        echo "Błąd: Bitwarden CLI (bw) nie jest zainstalowane." >&2
        echo "Uruchom: make bw-install" >&2
        exit 1
    fi
    if ! command -v jq >/dev/null 2>&1; then
        echo "Błąd: jq jest wymagane (brew install jq)." >&2
        exit 1
    fi
    bw_load_config
}

bw_ensure_logged_in() {
    bw_require_cli
    if ! bw login --check >/dev/null 2>&1; then
        echo "Nie jesteś zalogowany do Bitwarden CLI." >&2
        echo "Uruchom: bw login" >&2
        echo "lub:     make bw-login" >&2
        exit 1
    fi
}

bw_load_session() {
    bw_ensure_logged_in

    if [ -n "${BW_SESSION:-}" ]; then
        return 0
    fi

    if [ -f "$BW_SESSION_FILE" ]; then
        BW_SESSION="$(<"$BW_SESSION_FILE")"
        export BW_SESSION
        if bw sync --session "$BW_SESSION" >/dev/null 2>&1; then
            return 0
        fi
        rm -f "$BW_SESSION_FILE"
    fi

    echo "Odblokuj sejf Bitwarden (hasło master):" >&2
    BW_SESSION="$(bw unlock --raw)"
    export BW_SESSION
}

bw_save_session() {
    bw_load_session
    mkdir -p "$BW_SECRETS_DIR"
    chmod 700 "$BW_SECRETS_DIR"
    printf '%s' "$BW_SESSION" >"$BW_SESSION_FILE"
    chmod 600 "$BW_SESSION_FILE"
    echo "Sesja zapisana w $BW_SESSION_FILE (gitignored)."
}

bw_lock() {
    bw lock 2>/dev/null || true
    rm -f "$BW_SESSION_FILE"
    unset BW_SESSION
    echo "Sejf Bitwarden zablokowany."
}

bw_placeholder() {
    local label="$1"
    printf '{{bw:%s}}' "$label"
}

bw_is_placeholder() {
    [[ "$1" == *"${BW_PLACEHOLDER_PREFIX}"* ]]
}

bw_create_encoded() {
    local object="$1"
    local json="$2"
    local result

    if ! result="$(printf '%s' "$json" | bw encode | bw create "$object" --session "$BW_SESSION" 2>&1)"; then
        echo "Błąd Bitwarden (create $object): $result" >&2
        return 1
    fi

    if echo "$result" | grep -qi "error parsing"; then
        echo "Błąd Bitwarden (create $object): $result" >&2
        return 1
    fi

    printf '%s' "$result"
}

bw_get_folder_id() {
    local folder_name="$1"
    local folder_id folder_json

    folder_id="$(bw list folders --search "$folder_name" --session "$BW_SESSION" 2>/dev/null | jq -r --arg n "$folder_name" '.[] | select(.name == $n) | .id' | head -1)"

    if [ -n "$folder_id" ] && [ "$folder_id" != "null" ]; then
        printf '%s' "$folder_id"
        return 0
    fi

    folder_json="$(jq -n --arg name "$folder_name" '{name: $name}')"
    folder_id="$(bw_create_encoded folder "$folder_json" | jq -r '.id')"

    if [ -z "$folder_id" ] || [ "$folder_id" = "null" ]; then
        echo "Błąd: nie udało się utworzyć folderu Bitwarden: $folder_name" >&2
        return 1
    fi

    printf '%s' "$folder_id"
}

bw_is_uuid() {
    [[ "$1" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]
}

bw_lookup_item_id_in_vault() {
    local label="$1"
    bw list items --search "$label" --session "$BW_SESSION" 2>/dev/null | jq -r --arg n "$label" '
        [.[] | select(.name == $n)] |
        if length >= 1 then .[0].id else empty end
    '
}

bw_get_item_id_by_label() {
    local label="$1"
    local item_id

    item_id="$(jq -r --arg l "$label" '.secrets[$l].bitwarden_item_id // empty' "$BW_MANIFEST" 2>/dev/null)"
    if bw_is_uuid "$item_id"; then
        printf '%s' "$item_id"
        return 0
    fi

    item_id="$(bw_lookup_item_id_in_vault "$label")"

    if ! bw_is_uuid "$item_id"; then
        return 1
    fi

    printf '%s' "$item_id"
}

bw_item_exists() {
    local label="$1"
    bw_get_item_id_by_label "$label" >/dev/null 2>&1
}

bw_get_secret() {
    local label="$1"
    local item_id value

    if ! item_id="$(bw_get_item_id_by_label "$label")"; then
        echo "Błąd: nie znaleziono sekretu w Bitwarden: $label" >&2
        return 1
    fi

    value="$(bw get item "$item_id" --session "$BW_SESSION" | jq -r '
        if .login.password then .login.password
        else (.fields[]? | select(.name == "secret") | .value) // empty
        end
    ')"

    if [ -z "$value" ] || [ "$value" = "null" ]; then
        echo "Błąd: pusty sekret w Bitwarden: $label" >&2
        return 1
    fi

    printf '%s' "$value"
}

bw_create_secret() {
    local label="$1"
    local value="$2"
    local notes="${3:-}"

    local folder_id item_json item_id

    folder_id="$(bw_get_folder_id "$BW_FOLDER_NAME")"

    if bw_item_exists "$label"; then
        item_id="$(bw_get_item_id_by_label "$label")"
        echo "  [istnieje] $label — pomijam tworzenie" >&2
        printf '%s' "$item_id"
        return 0
    fi

    item_json="$(jq -n \
        --arg folderId "$folder_id" \
        --arg name "$label" \
        --arg password "$value" \
        --arg notes "$notes" \
        '{
            type: 1,
            name: $name,
            notes: $notes,
            login: {
                username: "secret",
                password: $password
            }
        }
        + (if ($folderId | length) > 0 then {folderId: $folderId} else {} end)')"

    item_id="$(bw_create_encoded item "$item_json" | jq -r '.id')"

    if [ -z "$item_id" ] || [ "$item_id" = "null" ]; then
        echo "Błąd: nie udało się utworzyć sekretu: $label" >&2
        return 1
    fi

    echo "  [utworzono] $label (id: $item_id)" >&2
    printf '%s' "$item_id"
}

bw_manifest_upsert() {
    local label="$1"
    local item_id="$2"
    local source_file="$3"
    local source_key="${4:-}"
    local placeholder
    local tmp

    placeholder="$(bw_placeholder "$label")"
    tmp="$(mktemp)"

    jq \
        --arg label "$label" \
        --arg item_id "$item_id" \
        --arg source_file "$source_file" \
        --arg source_key "$source_key" \
        --arg placeholder "$placeholder" \
        --arg updated "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        '
        .secrets[$label] = {
            bitwarden_item_id: $item_id,
            placeholder: $placeholder,
            source_file: $source_file,
            source_key: $source_key,
            updated_at: $updated
        }
        ' "$BW_MANIFEST" >"$tmp"

    mv "$tmp" "$BW_MANIFEST"
}

bw_resolve_placeholders_in_string() {
    local input="$1"
    local output="$input"
    local label value placeholder

    while [[ "$output" =~ \{\{bw:([^}]+)\}\} ]]; do
        label="${BASH_REMATCH[1]}"
        placeholder="{{bw:${label}}}"
        value="$(bw_get_secret "$label")"
        output="${output//${placeholder}/${value}}"
    done

    printf '%s' "$output"
}

bw_resolve_file() {
    local template_file="$1"
    local output_file="$2"
    local content resolved

    if [ ! -f "$template_file" ]; then
        echo "Błąd: brak pliku szablonu: $template_file" >&2
        return 1
    fi

    content="$(<"$template_file")"
    resolved="$(bw_resolve_placeholders_in_string "$content")"
    mkdir -p "$(dirname "$output_file")"
    printf '%s\n' "$resolved" >"$output_file"
    echo "  → $output_file"
}

bw_should_skip_value() {
    local value="$1"
    local exclude

    if [ -z "$value" ]; then
        return 0
    fi

    if bw_is_placeholder "$value"; then
        return 0
    fi

    while IFS= read -r exclude; do
        [ -z "$exclude" ] && continue
        if [[ "$value" == *"$exclude"* ]]; then
            return 0
        fi
    done < <(jq -r '.exclude_patterns[]?' "$BW_CONFIG" 2>/dev/null)

    return 1
}
