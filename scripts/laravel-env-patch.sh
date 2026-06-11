#!/usr/bin/env bash
# Wstrzykuje rozwiązane APP_KEY i DB_PASSWORD do laravel/.env w kontenerze (bezpiecznie dla znaków specjalnych).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

if [[ -z "${APP_KEY:-}" || "$APP_KEY" == *'{{bw:'* ]]; then
    echo "Błąd: APP_KEY nie ustawiony. Uruchom: make bw-unlock && make doctor" >&2
    exit 1
fi

export DB_PASSWORD="${POSTGRES_PASSWORD}"

docker exec hrk-php env \
    APP_KEY="${APP_KEY}" \
    DB_PASSWORD="${DB_PASSWORD}" \
    php -r '
$path = "/app/laravel/.env";
if (!is_file($path)) {
    fwrite(STDERR, "Brak $path\n");
    exit(1);
}
$key = getenv("APP_KEY") ?: "";
$pass = getenv("DB_PASSWORD") ?: "";
if ($key === "" || str_contains($key, "{{bw:")) {
    fwrite(STDERR, "APP_KEY nieprawidłowy\n");
    exit(1);
}
$env = file_get_contents($path);
$env = preg_replace("/^APP_KEY=.*/m", "APP_KEY=" . $key, $env);
$env = preg_replace("/^DB_PASSWORD=.*/m", "DB_PASSWORD=" . $pass, $env);
file_put_contents($path, $env);
'

docker exec hrk-php sh -c 'rm -f /app/laravel/bootstrap/cache/config.php'
docker exec hrk-php env APP_KEY="${APP_KEY}" php /app/laravel/artisan config:clear >/dev/null 2>&1 || true
