<link rel="stylesheet" href="../styles/main.css">

# Laravel

<!-- nav -->
[← README](README.md) › [Frameworki i aplikacje](README.md#frameworki-i-aplikacje)

Laravel 13 + PostgreSQL. CRUD faktur: http://localhost:8000/invoices

## Menu wsparcia (interaktywne)

```bash
make laravel-support   # lista komend → wpisz numer → wykonaj
```

## Serwer i podstawy

```bash
make laravel
# lub
docker compose exec php php laravel/artisan serve --host=0.0.0.0 --port=8000

docker compose exec php php laravel/artisan --version
docker compose exec php php laravel/artisan list
docker compose exec php php laravel/artisan about
```

## Baza danych

```bash
docker compose exec php php laravel/artisan db:show
docker compose exec php php laravel/artisan migrate:status

docker compose exec php php laravel/artisan tinker
# >>> DB::table('invoices')->count();
# >>> DB::select('SELECT number, amount FROM invoices LIMIT 3');
```

## Generowanie kodu (live coding)

```bash
docker compose exec php php laravel/artisan make:controller Api/InvoiceController
docker compose exec php php laravel/artisan make:controller Api/InvoiceController --api
docker compose exec php php laravel/artisan make:model Invoice
docker compose exec php php laravel/artisan make:request StorePaymentRequest
```

## Routing — przykład Zadania 6

Plik: `laravel/routes/api.php`

```php
Route::get('/invoices/unpaid', [InvoiceController::class, 'unpaid']);
```

CRUD (web): `laravel/routes/web.php` — `Route::resource('invoices', ...)`

```bash
curl http://localhost:8000/api/invoices/unpaid
curl http://localhost:8000/invoices
```

## Cache / czyszczenie

```bash
docker compose exec php php laravel/artisan config:clear
docker compose exec php php laravel/artisan route:list
docker compose exec php php laravel/artisan route:list --path=api
```

## Konfiguracja DB (`.env`)

```
DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=hrk_demo
DB_USERNAME=dev
DB_PASSWORD={{bw:hrk-live-coding/db/postgres-password}}
```

## Architektura CRUD faktur

```
Route → InvoiceController → InvoiceService → Eloquent (Invoice, Customer)
```

<a id="app-key-blad-szyfrowania"></a>

## APP_KEY — błąd szyfrowania

Komunikat:

```
Unsupported cipher or incorrect key length
```

**Przyczyna:** `laravel/.env` ma placeholder `{{bw:...}}` zamiast prawdziwego klucza — np. po `make secrets-sync` bez ponownego uruchomienia serwera.

**Naprawa:**

```bash
make bw-unlock
./scripts/laravel-env-patch.sh   # wstrzykuje APP_KEY do .env w kontenerze
make laravel                     # restart serwera dev
```

<div class="callout callout--warn">
  <span class="badge">UWAGA</span>
  <p>Po <code>make secrets-sync</code> zawsze uruchom ponownie <code>make laravel</code>. Placeholdery w pliku są OK w repo — runtime ustawia skrypt startowy.</p>
</div>

## Powiązane

- [Ćwiczenia](Cwiczenia.md)
- [PostgreSQL](PostgreSQL.md)

---
[← README](README.md) › [Frameworki i aplikacje](README.md#frameworki-i-aplikacje)
