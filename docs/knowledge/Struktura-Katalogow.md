<link rel="stylesheet" href="../styles/main.css">

# Struktura katalogów

<!-- nav -->
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)

```
live-coding-hrk/
├── docker-compose.yml          # orchestracja kontenerów
├── docker/php/Dockerfile       # PHP 8.3 + composer + pdo_pgsql + intl
├── Makefile                    # skróty komend
├── README.md                   # szybki start
├── docs/
│   ├── README.md               # wejście do dokumentacji
│   ├── styles/main.css         # style kart i calloutów
│   ├── knowledge/              # baza wiedzy (tematy w osobnych plikach)
│   ├── notatka-techniczna.md   # → przekierowanie do knowledge/
│   ├── bitwarden-secrets.md    # → przekierowanie
│   ├── migration-cheatsheet.md # → przekierowanie
│   └── pg-vs-mssql.md          # → przekierowanie
├── .secrets/
│   ├── config.json             # reguły skanowania
│   └── manifest.json           # mapowanie etykiet
├── docker-compose.env.template # placeholdery {{bw:...}}
├── templates/
│   ├── laravel.env.template
│   └── symfony.env.template
├── sql/
│   ├── schema-postgresql.sql   # schemat + dane PG
│   ├── schema-mssql.sql        # schemat + dane T-SQL
│   ├── exercises.md            # zadania
│   └── solutions/              # rozwiązania SQL
├── exercises/
│   └── legacy-invoice-processor.php
├── laravel/                    # Laravel 13 (generowany)
├── symfony/                    # Symfony 7.4 (generowany)
├── dotnet-skeleton/            # .NET 10 MVC + EF Core na MS SQL
└── scripts/
    ├── bootstrap.sh
    ├── init-mssql.sh
    ├── verify.sh
    └── bitwarden/              # skan, resolve, seed secretów
```

## Powiązane

- [Szybki start](Szybki-Start.md)
- [Komponenty i dostęp](Komponenty-i-Dostep.md)

---
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)
