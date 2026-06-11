#!/usr/bin/env bash
# Wrapper docker compose — ładuje secrety z Bitwarden jeśli sejf odblokowany.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ -f "$ROOT/.secrets/.bw-session" ] && command -v bw >/dev/null 2>&1; then
    if eval "$("$ROOT/scripts/bitwarden/secrets-export-env.sh" 2>/dev/null)"; then
        :
    fi
fi

exec docker compose "$@"
