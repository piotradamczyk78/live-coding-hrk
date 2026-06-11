#!/usr/bin/env bash
# DEPRECATED: nie zapisujemy haseł do plików .env.
# Użyj: make secrets-sync  +  make up (runtime z Bitwarden)

set -euo pipefail

echo "secrets-resolve nie zapisuje już haseł do plików." >&2
echo "  make secrets-sync  — pliki .env z placeholderami {{bw:...}}" >&2
echo "  make up            — secrety z Bitwarden w runtime (env vars)" >&2
exit 1
