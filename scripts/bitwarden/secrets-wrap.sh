#!/usr/bin/env bash
# Uruchamia dowolną komendę ze zmiennymi środowiskowymi rozwiniętymi z Bitwarden (runtime).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [ $# -eq 0 ]; then
    echo "Użycie: secrets-wrap.sh <komenda> [argumenty...]" >&2
    echo "Przykład: secrets-wrap.sh docker compose up -d" >&2
    exit 1
fi

eval "$("$ROOT/scripts/bitwarden/secrets-export-env.sh")"
cd "$ROOT"
exec "$@"
