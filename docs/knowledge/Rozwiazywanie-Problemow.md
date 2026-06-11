<link rel="stylesheet" href="../styles/main.css">

# Rozwiązywanie problemów

<!-- nav -->
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)

## Kontenery nie startują

```bash
docker compose down
docker compose up -d
docker compose logs postgres
docker compose logs sqlserver
```

## MS SQL nie odpowiada

```bash
docker compose logs sqlserver --tail=50
./scripts/init-mssql.sh
```

Pierwsze uruchomienie na Apple Silicon może trwać 1–3 min (emulacja amd64 dla `mssql-tools`).

## PostgreSQL pusta (brak tabel)

```bash
make reset    # usuwa wolumeny i przebudowuje od zera
```

## Laravel: błąd połączenia z DB

Sprawdź `laravel/.env` — `DB_HOST` musi być `postgres` (nie `localhost`) wewnątrz Dockera.

## Laravel: Unsupported cipher or incorrect key length

`APP_KEY` w `.env` to placeholder `{{bw:...}}` (często po `make secrets-sync`).

```bash
make bw-unlock
./scripts/laravel-env-patch.sh
make laravel
```

Więcej: [Laravel — APP_KEY](Laravel.md#app-key-blad-szyfrowania)

## Symfony: błąd Doctrine

Sprawdź `symfony/.env` — `DATABASE_URL` musi wskazywać na `postgres:5432`.

## Port zajęty

```bash
lsof -i :5432
lsof -i :1433
lsof -i :8000
lsof -i :8001
lsof -i :5000   # .NET dev server (domyślny)
lsof -i :5050   # .NET (alternatywny port)
```

```bash
lsof -ti :5000 | xargs kill -9   # zabij proces na porcie
```

Więcej: [Procesy dotnet](DotNet.md#procesy-dotnet)

## Przebudowa obrazu PHP (po zmianie Dockerfile)

```bash
docker compose build php --no-cache
docker compose up -d php
```

## Bitwarden / secrety

Zobacz [Bitwarden Secrets](Bitwarden-Secrets.md) — sekcja „Rozwiązywanie problemów”.

## Powiązane

- [Docker](Docker.md)
- [Makefile](Makefile.md)
- [Checklist na spotkanie](Checklist-Spotkania.md)

---
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)
