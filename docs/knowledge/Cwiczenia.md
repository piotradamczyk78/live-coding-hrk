<link rel="stylesheet" href="../styles/main.css">

# Ćwiczenia

<!-- nav -->
[← README](README.md) › [Ćwiczenia i migracja](README.md#cwiczenia-i-migracja)

Pełna lista: [`sql/exercises.md`](../../sql/exercises.md)  
Rozwiązania: [`sql/solutions/`](../../sql/solutions/) — **nie zaglądaj przed samodzielną próbą**

| # | Zadanie | Technologia |
|---|---|---|
| 1 | Faktury nieopłacone w całości | SQL |
| 2 | Zaległości > 30 dni | SQL |
| 3 | Ustaw `status = paid` w transakcji | SQL |
| 4 | `sp_CreatePayment` / funkcja PG | T-SQL / PL/pgSQL |
| 5 | Ostatnia płatność per faktura (`ROW_NUMBER`) | SQL |
| 6 | `GET /api/invoices/unpaid` | Laravel lub Symfony |
| 7 | Refaktoryzacja `legacy-invoice-processor.php` | PHP 8.3 |

## Wzorzec architektury PHP (Zadanie 6)

```
Route → Controller → Service → DB (Eloquent / Doctrine DBAL)
```

Kluczowe:
- walidacja wejścia
- transakcja przy zapisie płatności
- sensowne kody HTTP (400, 404, 422, 500)
- JSON response z czytelną strukturą

## Zadanie 1 — wskazówka

```sql
-- PostgreSQL: suma płatności < kwota faktury
SELECT i.number, i.amount, COALESCE(SUM(p.amount), 0) AS paid
FROM invoices i
LEFT JOIN payments p ON p.invoice_id = i.id
GROUP BY i.id, i.number, i.amount
HAVING COALESCE(SUM(p.amount), 0) < i.amount;
```

## Zadanie 7 — legacy PHP

Plik: [`exercises/legacy-invoice-processor.php`](../../exercises/legacy-invoice-processor.php)

Cel: proceduralny kod → `InvoiceService` + DI + testowalność.

## Powiązane

- [Model danych](Model-Danych.md)
- [Laravel](Laravel.md) · [Symfony](Symfony.md)
- [PostgreSQL](PostgreSQL.md) · [MS SQL](MSSQL.md)

---
[← README](README.md) › [Ćwiczenia i migracja](README.md#cwiczenia-i-migracja)
