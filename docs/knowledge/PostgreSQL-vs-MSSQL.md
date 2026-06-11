<link rel="stylesheet" href="../styles/main.css">

# PostgreSQL vs MS SQL

<!-- nav -->
[← README](README.md) › [Bazy danych](README.md#bazy-danych)

| Temat | PostgreSQL | MS SQL (T-SQL) |
|---|---|---|
| Auto-increment | `SERIAL` / `GENERATED ALWAYS AS IDENTITY` | `INT IDENTITY(1,1)` |
| Limit wierszy | `LIMIT 10` | `TOP 10` lub `OFFSET ... FETCH` |
| Aktualna data | `NOW()` / `CURRENT_DATE` | `GETDATE()` / `CAST(GETDATE() AS DATE)` |
| Null → wartość | `COALESCE(x, 0)` | `ISNULL(x, 0)` |
| Konkatenacja | `\|\|` lub `CONCAT()` | `+` lub `CONCAT()` |
| Boolean | `BOOLEAN` | `BIT` |
| Unicode string | `VARCHAR` / `TEXT` | `NVARCHAR` |
| Zwróć po INSERT | `RETURNING *` | `OUTPUT INSERTED.*` |
| Wyjątek w SQL | `RAISE EXCEPTION` | `THROW` / `RAISERROR` |
| Procedura | `CREATE FUNCTION ... LANGUAGE plpgsql` | `CREATE PROCEDURE` |
| Transakcja | `BEGIN;` ... `COMMIT;` | `BEGIN TRAN` ... `COMMIT TRAN` |
| 30 dni temu | `CURRENT_DATE - INTERVAL '30 days'` | `DATEADD(DAY, -30, CAST(GETDATE() AS DATE))` |

## Przykład — 30 dni temu

PostgreSQL:

```sql
due_at < CURRENT_DATE - INTERVAL '30 days'
```

MS SQL:

```sql
due_at < DATEADD(DAY, -30, CAST(GETDATE() AS DATE))
```

## Mapowanie typów (migracja)

| MS SQL | PostgreSQL |
|---|---|
| `INT IDENTITY` | `SERIAL` |
| `NVARCHAR(n)` | `VARCHAR(n)` |
| `DATETIME2` | `TIMESTAMP` |
| `BIT` | `BOOLEAN` |
| `DECIMAL(18,2)` | `NUMERIC(18,2)` |
| `GETDATE()` | `NOW()` |

## Powiązane

- [PostgreSQL](PostgreSQL.md) · [MS SQL](MSSQL.md)
- [Migracja .NET → PHP](Migracja-DotNet-PHP.md)

---
[← README](README.md) › [Bazy danych](README.md#bazy-danych)
