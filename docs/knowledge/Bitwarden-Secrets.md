<link rel="stylesheet" href="../styles/main.css">

# Bitwarden Secrets

<!-- nav -->
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)

<div class="callout callout--info">
  <span class="badge">ZASADA</span>
  <p>Hasła <strong>nigdy</strong> nie trafiają do plików <code>.env</code> w plaintext. W plikach są tylko placeholdery <code>{{bw:etykieta}}</code>. Wartości pobierane z Bitwarden <strong>w runtime</strong>.</p>
</div>

## Architektura

```
Pliki (placeholdery)              Runtime (Bitwarden)           Procesy
────────────────────              ───────────────────           ───────
laravel/.env                      make bw-unlock                docker compose
  DB_PASSWORD={{bw:...}}    →     secrets-wrap.sh         →     POSTGRES_PASSWORD=***
symfony/.env                      pobiera z vault               php artisan serve
  APP_SECRET={{bw:...}}                                         (env vars w kontenerze)
docker-compose.env.template
```

**Nie ma** pliku `.env.docker` z hasłami. `make up` rozwija secrety do zmiennych środowiskowych procesu, nie do pliku.

## Pierwsza konfiguracja

```bash
make secrets-setup      # bw + seed + secrets-sync
make up
make verify
```

## Codzienna praca

```bash
make doctor             # zalecane: Bitwarden + kontenery + serwery + testy
# lub ręcznie:
make bw-unlock
make up                 # lub make laravel, make verify, ...
make bw-lock            # po zakończeniu
```

## make doctor — cykl Bitwarden

Skrypt `scripts/doctor-bitwarden.sh` (wywoływany przez `make doctor`):

1. Odblokowanie sejfu (`bw_load_session` + zapis sesji)
2. `secrets-seed` — hasła z `.secrets/defaults.env` → Bitwarden vault (jeśli brak etykiety)
3. `secrets-sync` — `laravel/.env`, `symfony/.env` → wyłącznie placeholdery `{{bw:...}}`
4. Weryfikacja — brak plaintext w `APP_KEY`, `DB_PASSWORD`, `POSTGRES_PASSWORD`, itd.
5. Odświeżenie `runtime.env` z Bitwarden (nie ze starego cache)

Po `make doctor` w plikach konfiguracyjnych są **tylko etykiety**; wartości są w Bitwarden i trafiają do procesów przez `secrets-wrap` przy starcie kontenerów.

Dalej `doctor` czyści cache (`clear-caches.sh`), uruchamia Laravel, Symfony i .NET w tle oraz testuje `http://localhost:*/invoices`.

## Komendy

| Komenda | Opis |
|---|---|
| `make secrets-sync` | Kopiuje szablony → `.env` z placeholderami (bez haseł) |
| `make secrets-export` | Wypisuje `export VAR=...` z Bitwarden (do eval) |
| `make up` | `secrets-wrap` → docker compose z env vars z BW |
| `make secrets-seed` | Załaduj secrety z `defaults.env` do vault |
| `make secrets-scan-apply` | Skan kodu → BW + zamiana na `{{bw:...}}` |
| `make secrets-list` | Lista etykiet w vault |

### secrets-wrap (ręcznie)

```bash
./scripts/bitwarden/secrets-wrap.sh docker compose up -d
./scripts/bitwarden/secrets-wrap.sh docker compose exec php php laravel/artisan migrate
```

## Placeholdery w plikach

```dotenv
# laravel/.env
DB_PASSWORD={{bw:hrk-live-coding/db/postgres-password}}
APP_KEY={{bw:hrk-live-coding/laravel/app-key}}

# symfony/.env
APP_SECRET={{bw:hrk-live-coding/symfony/app-secret}}
DATABASE_URL="postgresql://dev:{{bw:hrk-live-coding/db/postgres-password}}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8"
```

Laravel/Symfony dostają **prawdziwe wartości** przez zmienne środowiskowe kontenera, które nadpisują placeholdery w `.env`.

## Co commitujemy

| Tak | Nie |
|---|---|
| `laravel/.env` z `{{bw:...}}` | plaintext haseł |
| `symfony/.env` z `{{bw:...}}` | `.env.docker` |
| `docker-compose.env.template` | `.secrets/defaults.env` |
| `templates/*.template` | `.secrets/.bw-session` |

## Jak pokazać na spotkaniu

1. Otwórz `laravel/.env` — widać `{{bw:...}}`, nie hasło
2. `make secrets-export` — export w terminalu, nie w pliku
3. `make up` — kontenery startują z runtime env z Bitwarden
4. `make secrets-list` — etykiety w vault
5. `make bw-lock` — sejf zablokowany

**Narracja:** „W repozytorium trzymam etykiety Bitwarden. Hasła pobieram w runtime przez CLI — nigdy nie zapisuję ich do plików .env.”

## Rozwiązywanie problemów

### `POSTGRES_PASSWORD: unbound variable`

```bash
make bw-unlock
make up    # nie: docker compose up bez wrap
```

### Stare hasło w wolumenie Docker

```bash
make down -v
make up
```

### `Error parsing the encoded request data` (BW 2026.x)

Zaktualizuj skrypty z repo, potem `make secrets-seed`.

### Uszkodzony manifest

```bash
make secrets-repair-manifest
```

---
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)
