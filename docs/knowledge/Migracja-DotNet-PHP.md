<link rel="stylesheet" href="../styles/main.css">

# Migracja .NET → PHP

<!-- nav -->
[← README](README.md) › [Ćwiczenia i migracja](README.md#cwiczenia-i-migracja)

Ściąga na rozmowę o migracji legacy .NET do PHP przy zachowaniu systemów finansowych.

## Strategia inkrementalna (Strangler Fig)

1. Zacznij od modułu brzegowego (np. fakturowanie) — mało zależności.
2. Postaw API w PHP **obok** starego .NET.
3. Przekieruj ruch przez feature flag / reverse proxy.
4. Wyłącz stary moduł po okresie dual-run i weryfikacji danych.

## Anti-Corruption Layer (ACL)

```
.NET InvoiceDto  →  ACL  →  PHP Invoice (domain model)
MS SQL schema    →  ACL  →  PostgreSQL / nowy schemat
```

## MS SQL jako legacy

- Logika często w **stored procedures** + ADO.NET w .NET
- Przy migracji: zostawić procedury / przenieść do PHP Service / hybryda
- Mapowanie typów: `NVARCHAR` → `VARCHAR`, `IDENTITY` → `SERIAL`, `DATETIME2` → `TIMESTAMP`

## Integralność danych finansowych

- Operacje wieloetapowe zawsze w **transakcji**
- Idempotencja przy importach (hash wyciągu)
- Audyt: `created_at`, `created_by`, historia statusów
- Testy regresji: te same wejścia → ten sam wynik w .NET i PHP

## Pytania do rekrutera

- Jaka wersja PHP i docelowy framework?
- MS SQL zostaje na czas migracji, czy docelowo PostgreSQL?
- Architektura .NET: Web Forms, MVC, Core?
- Logika w stored procedures czy w C#?

## 2 minuty na głos

> „Zacząłbym od modułu fakturowania jako brzegowego. Postawiłbym API w Symfony/Laravel obok .NET, dual-run z porównaniem wyników. Logikę z stored procedures przeniósłbym do PHP Service z transakcjami. ACL izoluje modele legacy od nowej domeny.”

## Powiązane

- [Kontekst roli](Kontekst-Roli.md)
- [PostgreSQL vs MS SQL](PostgreSQL-vs-MSSQL.md)
- [.NET 10](DotNet.md)

---
[← README](README.md) › [Ćwiczenia i migracja](README.md#cwiczenia-i-migracja)
