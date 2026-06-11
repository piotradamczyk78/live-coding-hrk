# Live coding — HRK (.NET + PHP + MS SQL)

Środowisko przygotowawcze do rozmowy technicznej na stanowisko migracji .NET → PHP.

## Szybki start

```bash
cd /Users/admin/Developer/Workspace/live-coding-hrk
chmod +x scripts/*.sh
make bootstrap    # pierwsze uruchomienie (~5–10 min)
make verify       # sprawdź, czy wszystko działa
```

Pierwsze uruchomienie pobiera obrazy Docker i generuje projekty Laravel + Symfony.

## Co jest w środku

| Komponent | Port | Dostęp |
|---|---|---|
| PostgreSQL 16 | 5432 | `dev` / *(z Bitwarden)*, baza `hrk_demo` |
| MS SQL (Azure SQL Edge) | 1433 | `sa` / *(z Bitwarden)* |
| Adminer (GUI PostgreSQL) | 8080 | http://localhost:8080 |
| Laravel dev server | 8000 | `make laravel` |
| Symfony dev server | 8001 | `make symfony` |

## Przydatne komendy

```bash
make status          # status kontenerów
make psql            # CLI PostgreSQL
make mssql           # CLI MS SQL (sqlcmd)
make init-mssql      # przeładuj schemat T-SQL
make laravel         # http://localhost:8000
make symfony         # http://localhost:8001
make logs            # logi kontenerów
make reset           # usuń wolumeny i przebuduj od zera
```

## Secrety (Bitwarden CLI)

Hasła **nie są w plikach .env** — tylko placeholdery `{{bw:etykieta}}`. Wartości z Bitwarden w runtime.

```bash
make secrets-setup      # pierwsza konfiguracja (bw + seed + sync placeholderów)
make bw-unlock          # przed każdą sesją pracy
make up                 # uruchamia z secretami z Bitwarden (nie zapisuje do plików)
make bw-lock            # po zakończeniu pracy
```

Dokumentacja: [`docs/bitwarden-secrets.md`](docs/bitwarden-secrets.md)

## Dokumentacja

- **Notatka techniczna** (komendy, checklist, ściągi): [`docs/notatka-techniczna.md`](docs/notatka-techniczna.md)
- Zadania: [`sql/exercises.md`](sql/exercises.md)
- Rozwiązania: [`sql/solutions/`](sql/solutions/) (nie zaglądaj przed próbą samodzielną)
- Legacy PHP do refaktoryzacji: [`exercises/legacy-invoice-processor.php`](exercises/legacy-invoice-processor.php)
- Ściąga migracyjna: [`docs/migration-cheatsheet.md`](docs/migration-cheatsheet.md)
- PostgreSQL vs MS SQL: [`docs/pg-vs-mssql.md`](docs/pg-vs-mssql.md)

## Połączenia z GUI (opcjonalnie)

Zainstaluj **Azure Data Studio** lub **DBeaver**:

- PostgreSQL: `localhost:5432`, user `dev`, hasło z Bitwarden (runtime), baza `hrk_demo`
- MS SQL: `localhost,1433`, user `sa`, hasło z Bitwarden

Adminer (PostgreSQL): http://localhost:8080 → System: PostgreSQL, Server: `postgres`, User: `dev`, Password: `dev`, Database: `hrk_demo`.

## Laravel — konfiguracja DB

Po `make bootstrap` plik `laravel/.env` jest ustawiony na PostgreSQL w Dockerze.
Test połączenia:

```bash
docker compose exec php php laravel/artisan migrate:status
```

## Symfony — konfiguracja DB

`symfony/.env` zawiera `DATABASE_URL` do PostgreSQL.
Test:

```bash
docker compose exec php php symfony/bin/console doctrine:query:sql "SELECT COUNT(*) FROM invoices"
```

## .NET (plan awaryjny)

Szkielet referencyjny w [`dotnet-skeleton/`](dotnet-skeleton/) — minimalne Web API w C#.
Wymaga .NET SDK 8:

```bash
brew install --cask dotnet-sdk
cd dotnet-skeleton && dotnet run
```

## Na dzień spotkania

1. `make status` — wszystkie kontenery `healthy` / `running`
2. Otwórz w Cursorze: `laravel/`, `symfony/`, `sql/`
3. Przetestuj `make psql` i `make mssql`
4. Wyłącz rozpraszacze; rozważ ograniczenie AI autocomplete podczas zadania

## Struktura

```
live-coding-hrk/
├── docker-compose.yml
├── docker/php/Dockerfile
├── laravel/              # generowany przez bootstrap
├── symfony/              # generowany przez bootstrap
├── dotnet-skeleton/      # referencja C# Web API
├── sql/
│   ├── schema-postgresql.sql
│   ├── schema-mssql.sql
│   ├── exercises.md
│   └── solutions/
├── exercises/
├── scripts/
├── docs/
└── Makefile
```
