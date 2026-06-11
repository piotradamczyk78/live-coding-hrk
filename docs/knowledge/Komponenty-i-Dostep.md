<link rel="stylesheet" href="../styles/main.css">

# Komponenty i dostęp

<!-- nav -->
[← README](README.md) › [Start i kontekst](README.md#start-i-kontekst)

| Komponent | Port | Host z Maca | Host z kontenera PHP |
|---|---|---|---|
| PostgreSQL 16 | 5432 | `localhost` | `postgres` |
| MS SQL (Azure SQL Edge) | 1433 | `localhost` | `sqlserver` |
| Adminer (GUI PG) | 8080 | http://localhost:8080 | — |
| Laravel dev server | 8000 | http://localhost:8000 | — |
| Symfony dev server | 8001 | http://localhost:8001 | — |
| .NET (lokalnie) | 5000 | http://localhost:5000 | — |

## PostgreSQL

| Parametr | Wartość |
|---|---|
| Baza | `hrk_demo` |
| User | `dev` |
| Hasło | *(z Bitwarden w runtime — `make up`)* |
| Connection string (z kontenera) | `postgresql://dev:***@postgres:5432/hrk_demo` |

## MS SQL

| Parametr | Wartość |
|---|---|
| User | `sa` |
| Hasło | *(z Bitwarden — `MSSQL_SA_PASSWORD`)* |
| Baza | `hrk_demo` |
| Server (z Maca) | `localhost,1433` |
| Server (z kontenera) | `sqlserver` |

Connection string (.NET / ADO):

```
Server=localhost,1433;Database=hrk_demo;User Id=sa;Password=<MSSQL_SA_PASSWORD>;TrustServerCertificate=True;Encrypt=False
```

## Adminer (PostgreSQL w Dockerze)

http://localhost:8080

| Pole | Wartość |
|---|---|
| System | PostgreSQL |
| Server | `postgres` ← **nie** `localhost` |
| User | `dev` |
| Password | *(z Bitwarden)* |
| Database | `hrk_demo` |

## GUI zewnętrzne

- **DBeaver** lub **Azure Data Studio** — połączenie do obu baz przez `localhost`
- PostgreSQL: port `5432`, user `dev`
- MS SQL: port `1433`, user `sa`, baza `hrk_demo`, Trust Server Certificate

## Powiązane

- [PostgreSQL](PostgreSQL.md)
- [MS SQL](MSSQL.md)
- [Bitwarden Secrets](Bitwarden-Secrets.md)

---
[← README](README.md) › [Start i kontekst](README.md#start-i-kontekst)
