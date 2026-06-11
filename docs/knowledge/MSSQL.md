<link rel="stylesheet" href="../styles/main.css">

# MS SQL (T-SQL)

<!-- nav -->
[← README](README.md) › [Bazy danych](README.md#bazy-danych)

.NET (`dotnet-skeleton`) łączy się z MS SQL. Schemat: `sql/schema-mssql.sql`.

## Menu wsparcia (interaktywne)

```bash
make mssql-support   # lista komend → wpisz numer → wykonaj
```

<div class="callout callout--warn">
  <span class="badge">UWAGA</span>
  <p>Azure SQL Edge nie ma <code>sqlcmd</code> wewnątrz kontenera. Używamy obrazu <code>mcr.microsoft.com/mssql-tools</code> jako klienta.</p>
</div>

## Interaktywna sesja

```bash
make mssql
```

## Połączenie z GUI (DBeaver, Azure Data Studio)

| Pole | Wartość |
|---|---|
| Host | `localhost` |
| Port | `1433` |
| User | `sa` |
| Password | `MSSQL_SA_PASSWORD` (z `.secrets/defaults.env`) |
| Database | `hrk_demo` |
| Encrypt | wyłączone lub Trust Server Certificate |

## Jednorazowe zapytanie

```bash
NETWORK=$(docker compose ps -q sqlserver | xargs docker inspect --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' | head -1)

docker run --rm --network "$NETWORK" mcr.microsoft.com/mssql-tools:latest \
  /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" \
  -Q "SELECT number, amount, status FROM dbo.invoices"
```

## Przeładowanie schematu

```bash
make init-mssql
# lub
./scripts/init-mssql.sh
```

## Przydatne w sqlcmd

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

## Wywołanie procedury (Zadanie 4)

```sql
EXEC dbo.sp_CreatePayment @invoice_id = 1, @amount = 7500.00, @method = N'transfer';
GO
```

## Powiązane

- [.NET 10](DotNet.md)
- [PostgreSQL vs MS SQL](PostgreSQL-vs-MSSQL.md)
- [Model danych](Model-Danych.md)

---
[← README](README.md) › [Bazy danych](README.md#bazy-danych)
