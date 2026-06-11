#!/usr/bin/env bash
# Interaktywne menu komend Docker / Compose.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/lib/support-menu.sh"

support_menu_run "Docker" \
    "Status kontenerów (compose ps)" \
        "./scripts/compose.sh ps" \
    "Uruchom kontenery (make up)" \
        "make up" \
    "Zatrzymaj kontenery (make down)" \
        "make down" \
    "Pełna stabilizacja (make doctor)" \
        "make doctor" \
    "Weryfikacja PG + MSSQL + frameworki (make verify)" \
        "make verify" \
    "Logi wszystkich serwisów (ostatnie 50 linii)" \
        "./scripts/compose.sh logs --tail=50" \
    "Logi PostgreSQL (tail 50)" \
        "./scripts/compose.sh logs --tail=50 postgres" \
    "Logi MS SQL (tail 50)" \
        "./scripts/compose.sh logs --tail=50 sqlserver" \
    "Logi PHP (tail 50)" \
        "./scripts/compose.sh logs --tail=50 php" \
    "Logi na żywo — PostgreSQL (Ctrl+C aby wyjść)" \
        "./scripts/compose.sh logs -f --tail=30 postgres" \
    "Restart kontenera PHP" \
        "./scripts/compose.sh restart php" \
    "Restart kontenera PostgreSQL" \
        "./scripts/compose.sh restart postgres" \
    "Restart kontenera MS SQL" \
        "./scripts/compose.sh restart sqlserver" \
    "Wymuś przebudowę kontenera PHP (force-recreate)" \
        "./scripts/bitwarden/secrets-wrap.sh ./scripts/compose.sh up -d --force-recreate php" \
    "Przebuduj obraz PHP (build --no-cache)" \
        "./scripts/bitwarden/secrets-wrap.sh ./scripts/compose.sh build php --no-cache" \
    "Zatrzymaj i usuń wolumeny (RESET DANYCH!)" \
        "echo 'UWAGA: usuwa dane PG i MSSQL! Wpisz TAK aby potwierdzić:' && read -r confirm && [ \"\$confirm\" = 'TAK' ] && ./scripts/compose.sh down -v || echo 'Anulowano.'" \
    "Zajęte porty (5432, 1433, 8000, 8001, 5050)" \
        "lsof -i :5432 -i :1433 -i :8000 -i :8001 -i :5050 2>/dev/null || echo 'Porty wolne lub brak lsof'"
