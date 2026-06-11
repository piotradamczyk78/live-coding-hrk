<link rel="stylesheet" href="../styles/main.css">

# PostgreSQL

<!-- nav -->
[← README](README.md) › [Bazy danych](README.md#bazy-danych)

Laravel i Symfony łączą się z PostgreSQL. Schemat: `sql/schema-postgresql.sql`.

## Menu wsparcia (interaktywne)

```bash
make postgres-support   # lista komend → wpisz numer → wykonaj
```

## Interaktywna sesja

```bash
make psql
# lub
docker compose exec postgres psql -U dev -d hrk_demo
```

## Przydatne zapytania w psql

```sql
\dt                          -- lista tabel
\d invoices                  -- struktura tabeli
\dn                          -- schematy
\x                           -- tryb expanded
SELECT COUNT(*) FROM invoices;
SELECT * FROM invoices LIMIT 5;
```

## Jednorazowe zapytanie z terminala

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

## Transakcja testowa

```sql
BEGIN;
UPDATE invoices SET status = 'paid' WHERE id = 1;
ROLLBACK;   -- cofnij test
-- COMMIT;  -- zatwierdź na produkcji
```

## Przeładowanie schematu

Schemat ładuje się automatycznie z `sql/schema-postgresql.sql` przy pierwszym starcie kontenera.

```bash
docker compose exec -T postgres psql -U dev -d hrk_demo < sql/schema-postgresql.sql
```

## Powiązane

- [PostgreSQL vs MS SQL](PostgreSQL-vs-MSSQL.md)
- [Laravel](Laravel.md) · [Symfony](Symfony.md)
- [Model danych](Model-Danych.md)

---
[← README](README.md) › [Bazy danych](README.md#bazy-danych)
