#!/usr/bin/env bash
# Generuje silne hasła do .secrets/defaults.env (przed secrets-seed).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/.secrets/defaults.env"

mkdir -p "$ROOT/.secrets"
chmod 700 "$ROOT/.secrets"

postgres_pw="$(openssl rand -base64 32 | tr -d '/+=' | head -c 28)"
mssql_pw="$(openssl rand -base64 20 | tr -d '/+=')Aa1!"
# Laravel wymaga dokładnie 32 bajtów po dekodowaniu base64 (AES-256)
laravel_key="base64:$(openssl rand -base64 32 | tr -d '\n')"
symfony_secret="$(openssl rand -hex 32)"

cat >"$OUT" <<EOF
# Wartości seed dla Bitwarden — NIE COMMITUJ (gitignored).
# Wygenerowano: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# Regeneruj: make secrets-generate-defaults

POSTGRES_PASSWORD=${postgres_pw}
MSSQL_SA_PASSWORD=${mssql_pw}
LARAVEL_APP_KEY=${laravel_key}
SYMFONY_APP_SECRET=${symfony_secret}
EOF

chmod 600 "$OUT"

echo "Wygenerowano: $OUT"
echo "Następnie: make secrets-seed"
