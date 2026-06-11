#!/usr/bin/env bash
# Uruchamia .NET MVC w tle na porcie 5050 (MS SQL).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# shellcheck disable=SC1091
source "$ROOT/scripts/load-secrets.sh"

PORT="${DOTNET_PORT:-5050}"
LOG="/tmp/hrk-dotnet.log"
PID_FILE="/tmp/hrk-dotnet.pid"

if ! command -v dotnet >/dev/null 2>&1; then
    echo "SKIP .NET — brak dotnet SDK (brew install --cask dotnet-sdk)" >&2
    exit 0
fi

if [ ! -f "$ROOT/dotnet-skeleton/hrk-demo.csproj" ]; then
    echo "SKIP .NET — brak dotnet-skeleton/hrk-demo.csproj" >&2
    exit 0
fi

export MSSQL_SA_PASSWORD="${MSSQL_SA_PASSWORD:?}"

# Zatrzymaj poprzednią instancję
if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
fi
lsof -ti ":$PORT" | xargs kill -9 2>/dev/null || true
pkill -f "dotnet.*hrk-demo" 2>/dev/null || true
sleep 1

cd "$ROOT/dotnet-skeleton"
dotnet restore -v q
dotnet build -v q

nohup env MSSQL_SA_PASSWORD="${MSSQL_SA_PASSWORD}" \
    dotnet run --no-build --urls "http://localhost:${PORT}" >"$LOG" 2>&1 &

echo $! >"$PID_FILE"
echo ".NET uruchomiony w tle → http://localhost:${PORT}/invoices (PID $(cat "$PID_FILE"), log: $LOG)"
