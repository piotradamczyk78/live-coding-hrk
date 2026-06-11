#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ -f "$ROOT/scripts/load-secrets.sh" ]; then
    # shellcheck disable=SC1091
    source "$ROOT/scripts/load-secrets.sh" 2>/dev/null || {
        set -a
        # shellcheck disable=SC1090
        [ -f "$ROOT/.secrets/defaults.env" ] && source "$ROOT/.secrets/defaults.env"
        set +a
    }
fi

exec docker compose "$@"
