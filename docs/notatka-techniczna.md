# Notatka techniczna — live coding HRK

Stanowisko: **Programista .NET + PHP** (migracja legacy → PHP, systemy finansowe / business travel).

Środowisko: `/Users/admin/Developer/Workspace/live-coding-hrk/`

---

## Spis treści

1. [Kontekst roli i czego się spodziewać](#kontekst-roli-i-czego-się-spodziewać)
2. [Szybki start](#szybki-start)
3. [Komponenty i dane dostępowe](#komponenty-i-dane-dostępowe)
4. [Komendy Makefile](#komendy-makefile)
5. [Docker — komendy rozszerzone](#docker--komendy-rozszerzone)
6. [PostgreSQL — komendy](#postgresql--komendy)
7. [MS SQL (T-SQL) — komendy](#ms-sql-t-sql--komendy)
8. [Laravel — komendy](#laravel--komendy)
9. [Symfony — komendy](#symfony--komendy)
10. [.NET — plan awaryjny](#net--plan-awaryjny)
11. [Model danych ćwiczeniowych](#model-danych-ćwiczeniowych)
12. [Ćwiczenia — skrót zadań](#ćwiczenia--skrót-zadań)
13. [Różnice PostgreSQL vs MS SQL](#różnice-postgresql-vs-ms-sql)
14. [Migracja .NET → PHP — co powiedzieć](#migracja-net--php--co-powiedzieć)
15. [Git — typowe komendy](#git--typowe-komendy)
16. [Checklist na dzień spotkania](#checklist-na-dzień-spotkania)
17. [Rozwiązywanie problemów](#rozwiązywanie-problemów)
18. [Bezpieczeństwo — Bitwarden CLI](#bezpieczeństwo--bitwarden-cli)
19. [Struktura katalogów](#struktura-katalogów)

---

## Kontekst roli i czego się spodziewać

To rola **migracyjna**, nie greenfield. Klient (business travel) przechodzi z .NET na PHP przy zachowaniu systemów finansowych.

| Prawdopodobieństwo | Temat na spotkaniu |
|---|---|
| **Wysokie** | PHP 8.x — REST API, OOP, PSR, endpoint z logiką biznesową |
| **Wysokie** | SQL — zapytania, JOIN, transakcje (PostgreSQL lub T-SQL) |
| **Średnie** | Refaktoryzacja legacy PHP (proceduralny kod → Service + DI) |
| **Średnie** | Dyskusja architektury migracji (Strangler Fig, ACL) |
| **Niskie** | Pełny live coding .NET |
| **Niskie** | Frontend React/Angular od zera |

Zadeklarowane frameworki PHP: **Symfony**, **Laravel**. MS SQL używany wcześniej — warto odświeżyć T-SQL.

---

## Szybki start

```bash
cd /Users/admin/Developer/Workspace/live-coding-hrk

# Pierwsze uruchomienie (pobiera obrazy, generuje Laravel + Symfony)
chmod +x scripts/*.sh
make bootstrap

# Codzienne sprawdzenie przed spotkaniem
make up
make verify
make status
```

---

## Komponenty i dane dostępowe

| Komponent | Port | Host z Maca | Host z kontenera PHP |
|---|---|---|---|
| PostgreSQL 16 | 5432 | `localhost` | `postgres` |
| MS SQL (Azure SQL Edge) | 1433 | `localhost` | `sqlserver` |
| Adminer (GUI PG) | 8080 | http://localhost:8080 | — |
| Laravel dev server | 8000 | http://localhost:8000 | — |
| Symfony dev server | 8001 | http://localhost:8001 | — |

### PostgreSQL

| Parametr | Wartość |
|---|---|
| Baza | `hrk_demo` |
| User | `dev` |
| Hasło | *(z Bitwarden w runtime — `make up`)* |
| Connection string | `postgresql://dev:dev@postgres:5432/hrk_demo` |

### MS SQL

| Parametr | Wartość |
|---|---|
| User | `sa` |
| Hasło | *(z Bitwarden w runtime — `make up`)* |
| Server (z Maca) | `localhost,1433` |
| Server (z kontenera) | `sqlserver` |

### Adminer (PostgreSQL w Dockerze)

http://localhost:8080

| Pole | Wartość |
|---|---|
| System | PostgreSQL |
| Server | `postgres` ← **nie** `localhost` |
| User | `dev` |
| Password | `dev` |
| Database | `hrk_demo` |

### GUI zewnętrzne (opcjonalnie)

- **DBeaver** lub **Azure Data Studio** — połączenie do obu baz przez `localhost`
- PostgreSQL: port `5432`, user `dev`
- MS SQL: port `1433`, user `sa`

---

## Komendy Makefile

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

make reset         # USUWA wolumeny + przebudowuje wszystko
```

---

## Docker — komendy rozszerzone

### Status i logi

```bash
docker compose ps
docker compose ps -a
docker compose logs postgres
docker compose logs sqlserver
docker compose logs php
docker compose logs -f --tail=100 sqlserver    # śledzenie na żywo
```

### Wejście do kontenerów

```bash
docker compose exec php bash
docker compose exec postgres sh
docker compose exec php php -v
docker compose exec php composer --version
```

### Restart pojedynczego serwisu

```bash
docker compose restart php
docker compose restart postgres
docker compose restart sqlserver
docker compose up -d --force-recreate php
```

### Czyszczenie

```bash
docker compose down              # zatrzymaj, zachowaj dane
docker compose down -v           # zatrzymaj + usuń wolumeny (reset danych!)
docker system prune -f           # usuń nieużywane obrazy (ostrożnie)
```

### Jednorazowe polecenie w kontenerze PHP

```bash
docker compose exec php php -r "echo 'OK';"
docker compose exec php php -m | grep -E 'pdo|pgsql|intl'
docker compose run --rm --no-deps php composer --version
```

### MS SQL — sqlcmd bez interakcji (jedno zapytanie)

```bash
NETWORK=$(docker compose ps -q sqlserver | xargs docker inspect --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' | head -1)

docker run --rm --network "$NETWORK" mcr.microsoft.com/mssql-tools:latest \
  /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" \
  -Q "SELECT TOP 5 number, amount, status FROM dbo.invoices"
```

---

## PostgreSQL — komendy

### Interaktywna sesja

```bash
make psql
# lub
docker compose exec postgres psql -U dev -d hrk_demo
```

### Przydatne zapytania w psql

```sql
\dt                          -- lista tabel
\d invoices                  -- struktura tabeli
\dn                          -- schematy
\x                           -- tryb expanded (czytelniejszy output)
SELECT COUNT(*) FROM invoices;
SELECT * FROM invoices LIMIT 5;
```

### Jednorazowe zapytanie z terminala

```bash
docker compose exec -T postgres psql -U dev -d hrk_demo -c "SELECT number, amount, status FROM invoices;"

docker compose exec -T postgres psql -U dev -d hrk_demo -c "
SELECT i.number, c.name, i.amount, COALESCE(SUM(p.amount),0) AS paid
FROM invoices i
JOIN customers c ON c.id = i.customer_id
LEFT JOIN payments p ON p.invoice_id = i.id
GROUP BY i.id, i.number, c.name, i.amount
HAVING COALESCE(SUM(p.amount),0) < i.amount;"
```

### Transakcja testowa

```sql
BEGIN;
UPDATE invoices SET status = 'paid' WHERE id = 1;
ROLLBACK;   -- cofnij test
-- COMMIT;  -- zatwierdź na produkcji
```

### Przeładowanie schematu PostgreSQL (po make reset)

Schemat ładuje się automatycznie z `sql/schema-postgresql.sql` przy pierwszym starcie kontenera.

Ręczne przeładowanie (gdy kontener już działa):

```bash
docker compose exec -T postgres psql -U dev -d hrk_demo < sql/schema-postgresql.sql
```

---

## MS SQL (T-SQL) — komendy

> **Uwaga:** Azure SQL Edge nie ma `sqlcmd` wewnątrz kontenera. Używamy obrazu `mcr.microsoft.com/mssql-tools` jako klienta.

### Interaktywna sesja

```bash
make mssql
```

### Jednorazowe zapytanie

```bash
NETWORK=$(docker compose ps -q sqlserver | xargs docker inspect --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' | head -1)

docker run --rm --network "$NETWORK" mcr.microsoft.com/mssql-tools:latest \
  /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" \
  -Q "SELECT number, amount, status FROM dbo.invoices"
```

### Przeładowanie schematu

```bash
make init-mssql
# lub
./scripts/init-mssql.sh
```

### Przydatne w sqlcmd

```sql
SELECT TOP 10 * FROM dbo.invoices;
GO

SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo';
GO

BEGIN TRAN;
UPDATE dbo.invoices SET status = N'paid' WHERE id = 2;
ROLLBACK TRAN;
GO
```

### Wywołanie procedury (po rozwiązaniu Zadania 4)

```sql
EXEC dbo.sp_CreatePayment @invoice_id = 1, @amount = 7500.00, @method = N'transfer';
GO
```

---

## Laravel — komendy

Wszystkie poniższe przez kontener PHP (`docker compose exec php`).

### Serwer i podstawy

```bash
make laravel
# lub
docker compose exec php php laravel/artisan serve --host=0.0.0.0 --port=8000

docker compose exec php php laravel/artisan --version
docker compose exec php php laravel/artisan list
docker compose exec php php laravel/artisan about
```

### Baza danych

```bash
docker compose exec php php laravel/artisan db:show
docker compose exec php php laravel/artisan migrate:status

# Tinker — szybki REPL
docker compose exec php php laravel/artisan tinker
# >>> DB::table('invoices')->count();
# >>> DB::select('SELECT number, amount FROM invoices LIMIT 3');
```

### Generowanie kodu (live coding)

```bash
docker compose exec php php laravel/artisan make:controller Api/InvoiceController
docker compose exec php php laravel/artisan make:controller Api/InvoiceController --api
docker compose exec php php laravel/artisan make:model Invoice
docker compose exec php php laravel/artisan make:request StorePaymentRequest
```

### Routing — przykład dla Zadania 6

Plik: `laravel/routes/api.php`

```php
Route::get('/invoices/unpaid', [InvoiceController::class, 'unpaid']);
```

Test:

```bash
curl http://localhost:8000/api/invoices/unpaid
```

### Cache / czyszczenie

```bash
docker compose exec php php laravel/artisan config:clear
docker compose exec php php laravel/artisan route:list
docker compose exec php php laravel/artisan route:list --path=api
```

### Konfiguracja DB (już ustawiona w `.env`)

```
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=hrk_demo
DB_USERNAME=dev
DB_PASSWORD=<z Bitwarden>
```

---

## Symfony — komendy

### Serwer i podstawy

```bash
make symfony
# lub
docker compose exec php php -S 0.0.0.0:8001 -t symfony/public

docker compose exec php php symfony/bin/console --version
docker compose exec php php symfony/bin/console list
```

### Baza danych (Doctrine)

```bash
docker compose exec php php symfony/bin/console doctrine:query:sql "SELECT COUNT(*) FROM invoices"

docker compose exec php php symfony/bin/console doctrine:query:sql "
SELECT i.number, c.name, i.amount
FROM invoices i
JOIN customers c ON c.id = i.customer_id
LIMIT 5"

docker compose exec php php symfony/bin/console dbal:run-sql "SELECT * FROM invoices LIMIT 3"
```

### Generowanie kodu (live coding)

```bash
docker compose exec -w /app/symfony php php bin/console make:controller Api/InvoiceController
docker compose exec -w /app/symfony php php bin/console make:entity Invoice
```

### Routing — przykład dla Zadania 6

```php
#[Route('/api/invoices/unpaid', methods: ['GET'])]
public function unpaid(InvoiceService $service): JsonResponse
{
    return $this->json($service->getUnpaidInvoices());
}
```

Test:

```bash
curl http://localhost:8001/api/invoices/unpaid
```

### Cache

```bash
docker compose exec php php symfony/bin/console cache:clear
docker compose exec php php symfony/bin/console debug:router
```

### Konfiguracja DB (już ustawiona w `.env`)

```
DATABASE_URL="postgresql://dev:dev@postgres:5432/hrk_demo?serverVersion=16&charset=utf8"
```

---

## .NET — plan awaryjny

Szkielet referencyjny: `dotnet-skeleton/` — minimalne Web API (faktury nieopłacone, dodawanie płatności).

### Instalacja SDK (jednorazowo)

```bash
brew install --cask dotnet-sdk
dotnet --version
```

### Uruchomienie

```bash
cd dotnet-skeleton
dotnet restore
dotnet run
dotnet watch run          # auto-reload przy zmianach
```

### Test endpointów

```bash
curl http://localhost:5000/api/invoices/unpaid
curl http://localhost:5000/api/invoices/unpaid | jq

curl -X POST http://localhost:5000/api/invoices/1/payments \
  -H 'Content-Type: application/json' \
  -d '{"amount": 7500, "method": "transfer"}'
```

Port może być `5000` lub `8080` — sprawdź output `dotnet run`.

### Szybka ściąga C# / ASP.NET Core

```
Controller → Service → Repository
async/await, IEnumerable<T>, LINQ
DbContext + Entity Framework (migracje)
Legacy: Web Forms / MVC vs nowoczesne ASP.NET Core
VB i C# — ten sam CLR, różna składnia
```

---

## Model danych ćwiczeniowych

Wspólny model w PostgreSQL i MS SQL (5 faktur testowych):

```
customers
  id, name, tax_id, created_at

invoices
  id, number (unikalny), customer_id, amount, status, issued_at, due_at, created_at
  status: draft | issued | paid | overdue | cancelled

invoice_items
  id, invoice_id, description, quantity, unit_price, line_total

payments
  id, invoice_id, amount, paid_at, method
```

### Przykładowe dane

| Numer | Klient | Kwota | Status | Zapłacono |
|---|---|---|---|---|
| FV/2026/001 | Acme Travel | 12 500 | issued | 5 000 (częściowo) |
| FV/2026/002 | Acme Travel | 8 400 | paid | 8 400 |
| FV/2026/003 | Globex | 22 000 | overdue | 800 |
| FV/2026/004 | Wayfarer | 3 100 | draft | 0 |
| FV/2026/005 | Globex | 5 600 | issued | 0 |

---

## Ćwiczenia — skrót zadań

Pełna lista: [`sql/exercises.md`](../sql/exercises.md)  
Rozwiązania: [`sql/solutions/`](../sql/solutions/) — **nie zaglądaj przed samodzielną próbą**

| # | Zadanie | Technologia |
|---|---|---|
| 1 | Faktury nieopłacone w całości | SQL |
| 2 | Zaległości > 30 dni | SQL |
| 3 | Ustaw `status = paid` w transakcji | SQL |
| 4 | `sp_CreatePayment` / funkcja PG | T-SQL / PL/pgSQL |
| 5 | Ostatnia płatność per faktura (`ROW_NUMBER`) | SQL |
| 6 | `GET /api/invoices/unpaid` | Laravel lub Symfony |
| 7 | Refaktoryzacja `legacy-invoice-processor.php` | PHP 8.3 |

### Wzorzec architektury PHP (Zadanie 6)

```
Route → Controller → Service → DB (Eloquent / Doctrine DBAL)
```

Kluczowe:
- walidacja wejścia
- transakcja przy zapisie płatności
- sensowne kody HTTP (400, 404, 422, 500)
- JSON response z czytelną strukturą

---

## Różnice PostgreSQL vs MS SQL

| Temat | PostgreSQL | MS SQL (T-SQL) |
|---|---|---|
| Auto-increment | `SERIAL` | `INT IDENTITY(1,1)` |
| Limit | `LIMIT 10` | `TOP 10` |
| Data teraz | `NOW()` | `GETDATE()` |
| Null → 0 | `COALESCE(x, 0)` | `ISNULL(x, 0)` |
| 30 dni temu | `CURRENT_DATE - INTERVAL '30 days'` | `DATEADD(DAY, -30, CAST(GETDATE() AS DATE))` |
| Boolean | `BOOLEAN` | `BIT` |
| Unicode | `VARCHAR` | `NVARCHAR` |
| Po INSERT | `RETURNING *` | `OUTPUT INSERTED.*` |
| Wyjątek | `RAISE EXCEPTION` | `THROW` |
| Transakcja | `BEGIN;` / `COMMIT;` | `BEGIN TRAN` / `COMMIT TRAN` |
| Procedura | `CREATE FUNCTION ... plpgsql` | `CREATE PROCEDURE` |

Więcej: [`docs/pg-vs-mssql.md`](pg-vs-mssql.md)

---

## Migracja .NET → PHP — co powiedzieć

### Strategia inkrementalna (Strangler Fig)

1. Zacznij od modułu brzegowego (np. fakturowanie) — mało zależności.
2. Postaw API w PHP **obok** starego .NET.
3. Przekieruj ruch przez feature flag / reverse proxy.
4. Wyłącz stary moduł po okresie dual-run i weryfikacji danych.

### Anti-Corruption Layer (ACL)

```
.NET InvoiceDto  →  ACL  →  PHP Invoice (domain model)
MS SQL schema    →  ACL  →  PostgreSQL / nowy schemat
```

### MS SQL jako legacy

- Logika często w **stored procedures** + ADO.NET w .NET
- Przy migracji: zostawić procedury / przenieść do PHP Service / hybryda
- Mapowanie typów: `NVARCHAR` → `VARCHAR`, `IDENTITY` → `SERIAL`, `DATETIME2` → `TIMESTAMP`

### Integralność danych finansowych

- Operacje wieloetapowe zawsze w **transakcji**
- Idempotencja przy importach (hash wyciągu)
- Audyt: `created_at`, `created_by`, historia statusów
- Testy regresji: te same wejścia → ten sam wynik w .NET i PHP

### Pytania do rekrutera

- Jaka wersja PHP i docelowy framework?
- MS SQL zostaje na czas migracji, czy docelowo PostgreSQL?
- Architektura .NET: Web Forms, MVC, Core?
- Logika w stored procedures czy w C#?

Więcej: [`docs/migration-cheatsheet.md`](migration-cheatsheet.md)

---

## Git — typowe komendy

Przydatne na live coding i przy omawianiu workflow. Projekt: `live-coding-hrk/`.

### Status i podgląd zmian

```bash
git status                    # co zmienione / unstaged / staged
git status -sb                # krótki format + branch
git diff                      # diff unstaged
git diff --staged             # diff staged (do commita)
git diff laravel/routes/      # diff konkretnego pliku/katalogu
git log --oneline -10         # ostatnie 10 commitów
git log --oneline --graph -15 # historia z grafem branchy
git show HEAD                 # ostatni commit (diff + meta)
git show HEAD:laravel/.env    # zawartość pliku z ostatniego commita
git blame app/Http/Controllers/InvoiceController.php   # kto zmienił linie
```

### Branching

```bash
git branch                    # lista branchy lokalnych
git branch -a                 # lokalne + zdalne
git switch -c feature/invoices-unpaid   # nowy branch (Git 2.23+)
git checkout -b feature/invoices-unpaid  # to samo (starsza składnia)
git switch main               # przełącz na main
git merge feature/invoices-unpaid
```

### Stage, commit, cofanie

```bash
git add laravel/routes/api.php          # dodaj plik
git add laravel/app/                    # dodaj katalog
git add -p                              # interaktywnie (fragmenty pliku)
git add -u                              # tylko zmodyfikowane (bez nowych)
git commit -m "Add GET /api/invoices/unpaid endpoint"
git commit -am "Fix unpaid invoices query"   # add + commit (tylko tracked)

git restore laravel/routes/api.php      # cofnij unstaged w pliku
git restore --staged laravel/routes/api.php  # usuń ze stage
git reset HEAD~1                        # cofnij ostatni commit (zmiany zostają)
git reset --hard HEAD~1                 # cofnij commit + usuń zmiany (ostrożnie!)
```

### Stash (odkładanie pracy na później)

```bash
git stash push -m "wip invoice controller"
git stash list
git stash show -p stash@{0}
git stash pop                           # przywróć i usuń ze stasha
git stash apply stash@{0}               # przywróć, zostaw w stashu
git stash drop stash@{0}
```

### Remote (jeśli repozytorium jest na GitHubie)

```bash
git remote -v
git fetch origin
git pull origin main                    # fetch + merge
git push -u origin feature/invoices-unpaid
git push origin main
```

### Przydatne na live coding

```bash
# Szybki podgląd co wysyłasz na commit
git diff --staged --stat

# Tylko nazwy zmienionych plików
git diff --name-only

# Czy plik jest śledzony
git ls-files laravel/.env

# Ignorowane pliki (np. vendor, .secrets/)
git status --ignored

# Jedna linia — kto ostatnio commitował plik
git log -1 --format='%h %s (%an, %ar)' -- sql/exercises.md
```

### Czego unikać na spotkaniu

```bash
# NIE używaj bez wyraźnej prośby rekrutera:
git push --force
git reset --hard
git clean -fdx          # usuwa nieśledzone pliki (w tym .env lokalne!)
git commit --no-verify  # omija hooki
```

### Dobre praktyki podczas zadania

- Commituj **małymi krokami** z sensownymi komunikatami (`Add InvoiceService`, `Fix SQL join`)
- Przed commitem: `git diff --staged` — upewnij się, że nie commitujesz secretów (`.secrets/defaults.env`, rozwinięte hasła)
- Placeholdery `{{bw:...}}` w `.env` — **OK do commita**
- `vendor/`, `node_modules/`, `.secrets/.bw-session` — **nigdy** nie commituj

### .gitignore — co jest wykluczone w tym projekcie

```
vendor/, node_modules/
.secrets/.bw-session, .secrets/defaults.env
laravel/vendor/, symfony/vendor/
*.log, *.bak
```

Sprawdź przed pierwszym commitem:

```bash
cd /Users/admin/Developer/Workspace/live-coding-hrk
git status
git check-ignore -v .secrets/defaults.env laravel/vendor/
```

---

## Checklist na dzień spotkania

### Technicznie (15 min przed)

- [ ] `make bw-unlock` — sejf odblokowany przed `make up`
- [ ] `make up && make verify` — wszystko OK
- [ ] `make status` — postgres, sqlserver, php: `running`
- [ ] Otwarte w Cursorze: `laravel/`, `symfony/`, `sql/`, `exercises/`
- [ ] Przetestowane: `make psql`, `make mssql`
- [ ] Wi-Fi + plan B (hotspot)
- [ ] Kamera / mikrofon / screen share

### W Cursorze

- [ ] Font i zoom czytelny na screen share
- [ ] Rozważ wyłączenie agresywnego AI autocomplete na czas zadania
- [ ] Znasz skróty: multi-cursor, rename symbol, go to definition

### Merytorycznie

- [ ] 2 min na głos: „jak migrowałbym moduł fakturowania z .NET do PHP”
- [ ] Znasz różnicę Symfony vs Laravel (bez fanatyzmu)
- [ ] Przygotuj 2 pytania o stack klienta

### Szybki test 5 min przed

```bash
make verify
curl -s http://localhost:8000/up          # Laravel health (jeśli serwer włączony)
./scripts/compose.sh exec -T postgres psql -U dev -d hrk_demo -c "SELECT COUNT(*) FROM invoices;"
```

---

## Rozwiązywanie problemów

### Kontenery nie startują

```bash
docker compose down
docker compose up -d
docker compose logs postgres
docker compose logs sqlserver
```

### MS SQL nie odpowiada

```bash
docker compose logs sqlserver --tail=50
./scripts/init-mssql.sh
```

Pierwsze uruchomienie na Apple Silicon może trwać 1–3 min (emulacja amd64 dla `mssql-tools`).

### PostgreSQL pusta (brak tabel)

```bash
make reset    # usuwa wolumeny i przebudowuje od zera
```

### Laravel: błąd połączenia z DB

Sprawdź `laravel/.env` — `DB_HOST` musi być `postgres` (nie `localhost`) wewnątrz Dockera.

### Symfony: błąd Doctrine

Sprawdź `symfony/.env` — `DATABASE_URL` musi wskazywać na `postgres:5432`.

### Port zajęty

```bash
lsof -i :5432
lsof -i :1433
lsof -i :8000
lsof -i :8001
```

### Przebudowa obrazu PHP (po zmianie Dockerfile)

```bash
docker compose build php --no-cache
docker compose up -d php
```

---

## Bezpieczeństwo — Bitwarden CLI

Hasła **nie są w plikach .env** — tylko placeholdery `{{bw:etykieta}}`. Wartości pobierane z Bitwarden **w runtime** (`secrets-wrap`), nie zapisywane do dysku.

### Pierwsza konfiguracja

```bash
make secrets-setup
# = bw-install + bw-login + bw-unlock + secrets-seed + secrets-sync
```

### Przed każdą sesją

```bash
make bw-unlock
make up          # secrets-wrap → env vars z Bitwarden → docker compose
```

### Po zakończeniu

```bash
make bw-lock
```

### Komendy

```bash
make secrets-sync         # .env z placeholderami {{bw:...}} (bez haseł)
make secrets-export       # podgląd export VAR=... (terminal, nie plik)
make up                   # runtime z Bitwarden przez secrets-wrap
make secrets-seed         # załaduj secrety do vault
make secrets-scan-apply   # skan kodu → BW + placeholdery
make secrets-list         # lista etykiet
```

### Pliki z placeholderami (bezpieczne)

```
laravel/.env              DB_PASSWORD={{bw:hrk-live-coding/db/postgres-password}}
symfony/.env              APP_SECRET={{bw:...}}
docker-compose.env.template
```

### Jak pokazać na spotkaniu

1. Otwórz `laravel/.env` — `{{bw:...}}`, nie hasło
2. `make secrets-export` — widać export w terminalu, nie w pliku
3. `make up` — kontenery startują z runtime env
4. `make secrets-list` — etykiety w vault
5. `make bw-lock` — sejf zablokowany

Pełna dokumentacja: [`docs/bitwarden-secrets.md`](bitwarden-secrets.md)

---

## Struktura katalogów

```
live-coding-hrk/
├── docker-compose.yml          # orchestracja kontenerów
├── docker/php/Dockerfile       # PHP 8.3 + composer + pdo_pgsql + intl
├── Makefile                    # skróty komend
├── README.md                   # szybki start
├── docs/
│   ├── notatka-techniczna.md   # ten plik
│   ├── bitwarden-secrets.md    # Bitwarden CLI
│   ├── migration-cheatsheet.md
│   └── pg-vs-mssql.md
├── .secrets/
│   ├── config.json             # reguły skanowania
│   └── manifest.json           # mapowanie etykiet
├── docker-compose.env.template # placeholdery {{bw:...}}
├── templates/
│   ├── laravel.env.template
│   └── symfony.env.template
├── sql/
│   ├── schema-postgresql.sql   # schemat + dane PG
│   ├── schema-mssql.sql        # schemat + dane T-SQL
│   ├── exercises.md            # zadania
│   └── solutions/              # rozwiązania SQL
├── exercises/
│   └── legacy-invoice-processor.php
├── laravel/                    # Laravel 13 (generowany)
├── symfony/                    # Symfony 7.4 (generowany)
├── dotnet-skeleton/            # C# Web API (referencja)
└── scripts/
    ├── bootstrap.sh
    ├── init-mssql.sh
    ├── verify.sh
    └── bitwarden/              # skan, resolve, seed secretów
```

---

*Ostatnia aktualizacja: przygotowanie do live coding HRK — .NET + PHP + MS SQL.*
