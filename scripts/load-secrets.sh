#!/usr/bin/env bash
# Ładuje secrety: cache runtime → Bitwarden → defaults.env
# Bezpieczne do source z innych skryptów.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULTS="$ROOT/.secrets/defaults.env"
RUNTIME="$ROOT/.secrets/runtime.env"

load_defaults() {
    if [ ! -f "$DEFAULTS" ]; then
        echo "Błąd: brak $DEFAULTS — uruchom: make secrets-generate-defaults" >&2
        return 1
    fi
    set -a
    # shellcheck disable=SC1090
    source "$DEFAULTS"
    set +a
    export DB_PASSWORD="${POSTGRES_PASSWORD}"
    echo "Secrety: defaults.env (fallback)" >&2
    return 0
}

save_runtime() {
    mkdir -p "$ROOT/.secrets"
    {
        printf 'export POSTGRES_PASSWORD=%q\n' "${POSTGRES_PASSWORD}"
        printf 'export MSSQL_SA_PASSWORD=%q\n' "${MSSQL_SA_PASSWORD}"
        printf 'export DATABASE_URL=%q\n' "${DATABASE_URL:-postgresql://dev:${POSTGRES_PASSWORD}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8}"
        printf 'export APP_KEY=%q\n' "${APP_KEY:-}"
        printf 'export APP_SECRET=%q\n' "${APP_SECRET:-}"
        printf 'export DB_PASSWORD=%q\n' "${POSTGRES_PASSWORD}"
    } >"$RUNTIME"
}

load_runtime() {
    if [ -f "$RUNTIME" ]; then
        set -a
        # shellcheck disable=SC1090
        source "$RUNTIME"
        set +a
        if [[ -n "${APP_KEY:-}" && "$APP_KEY" != *'{{bw:'* ]]; then
            echo "Secrety: runtime.env (cache)" >&2
            return 0
        fi
    fi
    return 1
}

load_from_bitwarden() {
    if [ ! -f "$ROOT/.secrets/.bw-session" ] || ! command -v bw >/dev/null 2>&1; then
        return 1
    fi
    if eval "$("$ROOT/scripts/bitwarden/secrets-export-env.sh" 2>/dev/null)"; then
        export DB_PASSWORD="${POSTGRES_PASSWORD}"
        save_runtime
        echo "Secrety: Bitwarden" >&2
        return 0
    fi
    return 1
}

load_secrets() {
    load_runtime || load_from_bitwarden || load_defaults
    save_runtime 2>/dev/null || true
}

load_secrets
