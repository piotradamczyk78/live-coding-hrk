#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "==> Budowanie obrazu PHP..."
docker compose build php

echo "==> Synchronizacja .env z placeholderami..."
"$ROOT/scripts/bitwarden/secrets-sync.sh" 2>/dev/null || true

echo "==> Uruchamianie kontenerów..."
if [ -f "$ROOT/.secrets/.bw-session" ] && command -v bw >/dev/null 2>&1; then
    "$ROOT/scripts/bitwarden/secrets-wrap.sh" "$ROOT/scripts/compose.sh" up -d
else
    echo "UWAGA: Bitwarden niedostępny — uruchom: make secrets-setup && make up"
fi

echo "==> Oczekiwanie na PostgreSQL..."
until docker compose exec -T postgres pg_isready -U dev -d hrk_demo >/dev/null 2>&1; do
    sleep 1
done

echo "==> Inicjalizacja MS SQL (może potrwać 1–3 min)..."
"$ROOT/scripts/init-mssql.sh" || {
    echo "UWAGA: MS SQL nie zainicjalizowany — uruchom ponownie: make init-mssql"
}

if [ ! -f "$ROOT/laravel/artisan" ]; then
    echo "==> Tworzenie projektu Laravel..."
    docker compose run --rm --no-deps php composer create-project laravel/laravel laravel
else
    echo "==> Laravel już istnieje — pomijam."
fi

if [ ! -f "$ROOT/symfony/bin/console" ]; then
    echo "==> Tworzenie projektu Symfony..."
    docker compose run --rm --no-deps php composer create-project symfony/skeleton symfony
    docker compose run --rm --no-deps -w /app/symfony php composer require symfony/orm-pack symfony/maker-bundle --dev
else
    echo "==> Symfony już istnieje — pomijam."
fi

echo "==> Pliki .env (placeholdery {{bw:...}})..."
"$ROOT/scripts/bitwarden/secrets-sync.sh" 2>/dev/null || true


echo ""
echo "Gotowe. Następne kroki:"
echo "  make secrets-setup — konfiguracja Bitwarden (pierwszy raz)"
echo "  make verify        — test całego środowiska"
echo "  make psql          — PostgreSQL CLI"
echo "  make mssql         — MS SQL CLI"
echo "  make laravel       — serwer Laravel :8000"
echo "  make symfony       — serwer Symfony :8001"
echo "  open http://localhost:8080  — Adminer (PostgreSQL)"
