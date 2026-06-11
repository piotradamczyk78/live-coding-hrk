#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=lib.sh
source "$ROOT/scripts/bitwarden/lib.sh"

bw_load_session
bw_save_session
bw sync --session "$BW_SESSION" >/dev/null

echo "Sejf odblokowany i zsynchronizowany."
