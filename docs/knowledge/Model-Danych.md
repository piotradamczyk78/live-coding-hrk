<link rel="stylesheet" href="../styles/main.css">

# Model danych ćwiczeniowych

<!-- nav -->
[← README](README.md) › [Bazy danych](README.md#bazy-danych)

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

## Przykładowe dane

| Numer | Klient | Kwota | Status | Zapłacono |
|---|---|---|---|---|
| FV/2026/001 | Acme Travel | 12 500 | issued | 5 000 (częściowo) |
| FV/2026/002 | Acme Travel | 8 400 | paid | 8 400 |
| FV/2026/003 | Globex | 22 000 | overdue | 800 |
| FV/2026/004 | Wayfarer | 3 100 | draft | 0 |
| FV/2026/005 | Globex | 5 600 | issued | 0 |

## Pliki schematu

- PostgreSQL: `sql/schema-postgresql.sql`
- MS SQL: `sql/schema-mssql.sql`

## Powiązane

- [Ćwiczenia](Cwiczenia.md)
- [PostgreSQL](PostgreSQL.md) · [MS SQL](MSSQL.md)

---
[← README](README.md) › [Bazy danych](README.md#bazy-danych)
