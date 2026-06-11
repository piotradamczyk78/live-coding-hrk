<link rel="stylesheet" href="../styles/main.css">

# Symfony

<!-- nav -->
[← README](README.md) › [Frameworki i aplikacje](README.md#frameworki-i-aplikacje)

Symfony 7.4 + PostgreSQL. CRUD faktur: http://localhost:8001/invoices

## Menu wsparcia (interaktywne)

```bash
make symfony-support   # lista komend → wpisz numer → wykonaj
```

## Serwer i podstawy

```bash
make symfony
# lub
docker compose exec php php -S 0.0.0.0:8001 -t symfony/public

docker compose exec php php symfony/bin/console --version
docker compose exec php php symfony/bin/console list
```

## Baza danych (Doctrine)

```bash
docker compose exec php php symfony/bin/console doctrine:query:sql "SELECT COUNT(*) FROM invoices"

docker compose exec php php symfony/bin/console doctrine:query:sql "
SELECT i.number, c.name, i.amount
FROM invoices i
JOIN customers c ON c.id = i.customer_id
LIMIT 5"

docker compose exec php php symfony/bin/console dbal:run-sql "SELECT * FROM invoices LIMIT 3"
```

## Generowanie kodu

```bash
docker compose exec -w /app/symfony php php bin/console make:controller Api/InvoiceController
docker compose exec -w /app/symfony php php bin/console make:entity Invoice
```

## Routing — przykład Zadania 6

```php
#[Route('/api/invoices/unpaid', methods: ['GET'])]
public function unpaid(InvoiceService $service): JsonResponse
{
    return $this->json($service->getUnpaidInvoices());
}
```

CRUD (web): `src/Controller/InvoiceController.php`

```bash
curl http://localhost:8001/api/invoices/unpaid
curl http://localhost:8001/invoices
```

## Cache i routing

```bash
docker compose exec php php symfony/bin/console cache:clear
docker compose exec php php symfony/bin/console debug:router
```

## Konfiguracja DB (`.env`)

```
DATABASE_URL="postgresql://dev:{{bw:...}}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8"
```

## Architektura CRUD faktur

```
Route → InvoiceController → InvoiceService → Doctrine (Entity + Repository)
```

## Powiązane

- [Ćwiczenia](Cwiczenia.md)
- [PostgreSQL](PostgreSQL.md)

---
[← README](README.md) › [Frameworki i aplikacje](README.md#frameworki-i-aplikacje)
