<link rel="stylesheet" href="../styles/main.css">

# Makefile

<!-- nav -->
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)

```bash
make up            # uruchom kontenery w tle
make down          # zatrzymaj kontenery (dane zostają)
make build         # przebuduj obraz PHP
make bootstrap     # pełna instalacja od zera
make verify        # test PG + MSSQL + Laravel + Symfony
make status        # docker compose ps
make logs          # logi wszystkich kontenerów (Ctrl+C aby wyjść)

make psql          # interaktywny CLI PostgreSQL
make mssql         # interaktywny CLI MS SQL (sqlcmd)
make init-mssql    # przeładuj schemat T-SQL + dane testowe

make laravel       # serwer dev → http://localhost:8000
make symfony       # serwer dev → http://localhost:8001
make dotnet        # serwer dev → http://localhost:5050 (w tle)
make laravel-support   # interaktywne menu komend Laravel
make symfony-support   # interaktywne menu komend Symfony
make dotnet-support    # interaktywne menu komend .NET
make postgres-support  # interaktywne menu komend PostgreSQL
make mssql-support     # interaktywne menu komend MS SQL
make php-support       # interaktywne menu komend PHP (kontener)
make docker-support    # interaktywne menu komend Docker
make doctor        # Bitwarden + kontenery + cache + serwery + smoke testy
make clear-cache   # Laravel + Symfony + .NET (bin/obj)
make check         # status-check (porty HTTP)
make sync-passwords # synchronizacja haseł DB

make reset         # USUWA wolumeny + przebudowuje wszystko
```

## Bitwarden

```bash
make bw-unlock
make bw-lock
make secrets-setup    # pierwsza konfiguracja (bw + seed + sync)
make secrets-sync     # etykiety {{bw:...}} w plikach .env
make secrets-export
make secrets-list
```

`make doctor` uruchamia pełny cykl Bitwarden (seed vault → sync etykiet → weryfikacja braku plaintext).

## Powiązane

- [Docker](Docker.md)
- [Szybki start](Szybki-Start.md)

---
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)
