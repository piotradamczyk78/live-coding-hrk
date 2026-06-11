# Migracja .NET → PHP — ściąga na rozmowę

## Strategia inkrementalna (Strangler Fig)

1. Identyfikuj **moduł brzegowy** (np. wystawianie faktur) — mało zależności wewnętrznych.
2. Postaw **API w PHP** obok istniejącego .NET.
3. Przekieruj ruch przez **feature flag** lub reverse proxy.
4. Stary moduł .NET wyłącz dopiero po okresie **dual-run** i weryfikacji danych.

## Anti-Corruption Layer (ACL)

Warstwa tłumacząca modele legacy na nowe:

```
.NET InvoiceDto  →  ACL  →  PHP Invoice (domain model)
MS SQL schema    →  ACL  →  PostgreSQL / nowy schemat
```

## MS SQL → PostgreSQL — mapowanie typów

| MS SQL | PostgreSQL |
|---|---|
| `INT IDENTITY` | `SERIAL` / `GENERATED ALWAYS AS IDENTITY` |
| `NVARCHAR(n)` | `VARCHAR(n)` |
| `DATETIME2` | `TIMESTAMP` |
| `BIT` | `BOOLEAN` |
| `DECIMAL(18,2)` | `NUMERIC(18,2)` |
| `GETDATE()` | `NOW()` |
| Stored procedures | Logika w PHP Service lub funkcje PG |

## Integralność danych finansowych

- Operacje wieloetapowe zawsze w **transakcji**
- Idempotencja przy importach (np. hash wyciągu bankowego)
- Audyt: `created_at`, `created_by`, wersjonowanie statusów
- Testy regresji: te same wejścia → ten sam wynik w .NET i PHP

## Pytania warto zadać rekruterowi

- Jaka wersja PHP i który framework docelowy?
- MS SQL zostaje na czas migracji, czy docelowo PostgreSQL?
- Jak wygląda obecna architektura .NET (Web Forms, MVC, Core)?
- Czy logika siedzi w stored procedures czy w C#?
