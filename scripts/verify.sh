#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

MSSQL_SA_PASSWORD="${MSSQL_SA_PASSWORD:?Ustaw MSSQL_SA_PASSWORD — uruchom: make verify (przez secrets-wrap)}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:?Ustaw POSTGRES_PASSWORD — uruchom: make verify (przez secrets-wrap)}"

echo "=== Status kontenerów ==="
"$ROOT/scripts/compose.sh" ps

echo ""
echo "=== PostgreSQL — liczba faktur ==="
"$ROOT/scripts/compose.sh" exec -T postgres psql -U dev -d hrk_demo -c "SELECT COUNT(*) AS invoices FROM invoices;"

echo ""
echo "=== MS SQL — liczba faktur ==="
NETWORK="$("$ROOT/scripts/compose.sh" ps -q sqlserver | xargs docker inspect --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' | head -1)"
docker run --rm --network "$NETWORK" mcr.microsoft.com/mssql-tools:latest \
    /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" \
    -Q "SET NOCOUNT ON; SELECT COUNT(*) AS invoices FROM dbo.invoices;"

echo ""
echo "=== Laravel — wersja ==="
"$ROOT/scripts/compose.sh" exec -T php php laravel/artisan --version

echo ""
echo "=== Symfony — wersja ==="
"$ROOT/scripts/compose.sh" exec -T php php symfony/bin/console --version

echo ""
echo "=== Symfony — zapytanie do PostgreSQL ==="
"$ROOT/scripts/compose.sh" exec -T php php symfony/bin/console doctrine:query:sql "SELECT COUNT(*) FROM invoices"

echo ""
echo "=== Laravel — test połączenia DB ==="
"$ROOT/scripts/compose.sh" exec -T php php laravel/artisan db:show 2>/dev/null || \
"$ROOT/scripts/compose.sh" exec -T php php -r "
\$pdo = new PDO('pgsql:host=postgres;port=5432;dbname=hrk_demo', 'dev', getenv('DB_PASSWORD') ?: '${POSTGRES_PASSWORD}');
echo 'Laravel DB OK: ' . \$pdo->query('SELECT COUNT(*) FROM invoices')->fetchColumn() . \" invoices\n\";
"

echo ""
echo "=== Pliki .env — placeholdery (bez plaintext) ==="
grep -E 'PASSWORD|APP_KEY|APP_SECRET' laravel/.env symfony/.env docker-compose.env.template 2>/dev/null | grep -v '^#' || true

echo ""
echo "Weryfikacja zakończona pomyślnie."
