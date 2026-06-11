#!/usr/bin/env bash
# Interaktywne menu komend .NET.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"
# shellcheck disable=SC1091
source "$ROOT/scripts/lib/support-menu.sh"

export MSSQL_SA_PASSWORD="${MSSQL_SA_PASSWORD:?}"

dotnet_in_skeleton() {
    (cd "$ROOT/dotnet-skeleton" && export MSSQL_SA_PASSWORD && "$@")
}

support_menu_run ".NET 10" \
    "Uruchom serwer dev w tle (:5050)" \
        "./scripts/dotnet-serve.sh" \
    "Uruchom interaktywnie (dotnet run)" \
        "dotnet_in_skeleton dotnet run --urls http://localhost:5050" \
    "Uruchom z auto-reload (dotnet watch)" \
        "dotnet_in_skeleton dotnet watch run --urls http://localhost:5050" \
    "Wersja SDK" \
        "dotnet --version" \
    "Restore + build" \
        "dotnet_in_skeleton dotnet restore && dotnet_in_skeleton dotnet build" \
    "Wyczyść cache builda (clean + bin/obj)" \
        "dotnet_in_skeleton dotnet clean && rm -rf $ROOT/dotnet-skeleton/bin $ROOT/dotnet-skeleton/obj && echo 'bin/obj usunięte'" \
    "Migracje EF — status bazy" \
        "dotnet_in_skeleton dotnet ef migrations list" \
    "Migracje EF — zastosuj (database update)" \
        "dotnet_in_skeleton dotnet ef database update" \
    "Nowa migracja (szablon — podaj nazwę ręcznie)" \
        "echo 'Użyj: cd dotnet-skeleton && dotnet ef migrations add NazwaMigracji'" \
    "Lista procesów dotnet" \
        "pgrep -lf dotnet || echo 'Brak procesów dotnet'" \
    "Kto trzyma port 5050" \
        "lsof -i :5050 || echo 'Port 5050 wolny'" \
    "Zatrzymaj proces na porcie 5050" \
        "lsof -ti :5050 | xargs kill -9 2>/dev/null; echo 'Port 5050 zwolniony (lub był wolny)'" \
    "Test web — lista faktur (HTTP)" \
        "curl -s -o /dev/null -w 'GET /invoices → HTTP %{http_code}\n' http://localhost:5050/invoices" \
    "Test API — nieopłacone faktury" \
        "curl -s http://localhost:5050/api/invoices/unpaid | head -c 500; echo" \
    "Test API — dodaj płatność (POST)" \
        "curl -s -X POST http://localhost:5050/api/invoices/1/payments -H 'Content-Type: application/json' -d '{\"amount\": 7500, \"method\": \"transfer\"}' | head -c 500; echo"
