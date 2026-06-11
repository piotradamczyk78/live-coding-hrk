# Ćwiczenia SQL i PHP — live coding HRK

Rozwiązania w `sql/solutions/` — spróbuj samodzielnie przed podglądem.

## Zadania SQL

1. **Faktury nieopłacone w całości** — lista z `remaining > 0`, bez `draft` i `cancelled`.
2. **Zaległości > 30 dni** — `status = overdue` lub `due_at` starsze niż 30 dni.
3. **Transakcja** — dodaj płatność i ustaw `status = paid` gdy suma płatności ≥ kwota faktury.
4. **Procedura / funkcja** — `sp_CreatePayment` (MSSQL) lub funkcja PL/pgSQL rejestrująca płatność.
5. **Ostatnia płatność** — `ROW_NUMBER()` / `DISTINCT ON` per faktura.

## Zadania aplikacyjne

6. **REST API** — `GET /api/invoices/unpaid` w Laravel lub Symfony (JSON).
7. **Refaktoryzacja** — `exercises/legacy-invoice-processor.php` (PHP 8.3, typy, transakcje).
