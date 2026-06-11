# .NET 10 — HRK Demo (MS SQL)

Aplikacja MVC w C# z CRUD faktur na **MS SQL Server** (Azure SQL Edge) oraz referencyjnym API ćwiczeniowym.

## Wymagania

- .NET SDK 10
- Działający kontener MS SQL: `make up` + `make init-mssql` (opcjonalnie — migracje EF tworzą schemat samodzielnie)

## Uruchomienie

```bash
cd dotnet-skeleton
export MSSQL_SA_PASSWORD="$(grep MSSQL_SA_PASSWORD ../.secrets/defaults.env | cut -d= -f2)"
dotnet restore
dotnet ef database update   # migracje
dotnet run
```

Interfejs: **http://localhost:5050/invoices** (lub `make dotnet`)

## Widoki Razor — przebudowa i cache

```bash
dotnet watch run                              # auto-reload (zalecane w dev)
dotnet clean && rm -rf bin obj && dotnet run  # pełny reset cache builda
```

Szczegóły: [`docs/knowledge/DotNet.md`](../docs/knowledge/DotNet.md#widoki-razor-przebudowa-cache)

## Procesy dotnet

```bash
pgrep -lf dotnet                              # lista procesów
lsof -i :5000                                 # kto trzyma port
lsof -ti :5000 | xargs kill -9 2>/dev/null    # zabij proces na porcie
```

Szczegóły: [`docs/knowledge/DotNet.md`](../docs/knowledge/DotNet.md#procesy-dotnet)

## Migracje EF Core

```bash
# nowa migracja po zmianie modelu
dotnet ef migrations add NazwaMigracji

# zastosowanie na bazie
dotnet ef database update
```

## API (ćwiczenia)

```bash
curl http://localhost:5000/api/invoices/unpaid
curl -X POST http://localhost:5000/api/invoices/1/payments \
  -H 'Content-Type: application/json' \
  -d '{"amount": 7500, "method": "transfer"}'
```

## Struktura

```
Models/          — encje EF Core
Data/            — HrkDbContext, migracje, seed
Services/        — InvoiceService
Controllers/     — InvoicesController (MVC)
Views/Invoices/  — widoki Razor
Migrations/      — migracje EF Core
```
