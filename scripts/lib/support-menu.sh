#!/usr/bin/env bash
# Interaktywne menu komend — wspólna biblioteka.
# Użycie w skrypcie platformy:
#   source scripts/lib/support-menu.sh
#   support_menu_run "Tytuł" \
#       "Opis 1" "komenda 1" \
#       "Opis 2" "komenda 2"

support_menu_run() {
    local title="$1"
    shift
    local -a items=("$@")
    local count=$((${#items[@]} / 2))

    if [ "$count" -lt 1 ]; then
        echo "Błąd: puste menu" >&2
        return 1
    fi

    while true; do
        echo ""
        echo "══════════════════════════════════════════════════════════"
        echo "  $title"
        echo "══════════════════════════════════════════════════════════"
        echo ""

        local i
        for ((i = 0; i < count; i++)); do
            printf "  %2d) %s\n" "$((i + 1))" "${items[i * 2]}"
        done
        echo ""
        printf "   0) Wyjście\n"
        echo ""
        printf "Wybierz numer: "
        read -r choice

        if [ "$choice" = "0" ] || [ -z "$choice" ]; then
            echo "Koniec."
            return 0
        fi

        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$count" ]; then
            echo "Nieprawidłowy wybór — wpisz numer 0–$count."
            continue
        fi

        local idx=$((choice - 1))
        local desc="${items[idx * 2]}"
        local cmd="${items[idx * 2 + 1]}"

        echo ""
        echo "▶ $desc"
        echo "  \$ $cmd"
        echo "──────────────────────────────────────────────────────────"

        set +e
        eval "$cmd"
        local exit_code=$?
        set -e

        echo "──────────────────────────────────────────────────────────"
        if [ "$exit_code" -eq 0 ]; then
            echo "✓ Zakończono (kod 0)"
        else
            echo "✗ Błąd (kod $exit_code)" >&2
        fi
    done
}
