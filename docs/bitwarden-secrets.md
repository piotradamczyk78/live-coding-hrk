# Bitwarden CLI — zarządzanie secretami

**Zasada:** hasła nigdy nie trafiają do plików `.env` w plaintext. W plikach są tylko placeholdery `{{bw:etykieta}}`. Wartości są pobierane z Bitwarden **w runtime** (przy uruchamianiu komend).

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

---

## Pierwsza konfiguracja

```bash
make secrets-setup      # bw + seed + secrets-sync
make up                 # runtime z Bitwarden
make verify
```

---

## Codzienna praca

```bash
make bw-unlock
make up                 # lub make laravel, make verify, ...
make bw-lock            # po zakończeniu
```

---

## Komendy

| Komenda | Opis |
|---|---|
| `make secrets-sync` | Kopiuje szablony → `.env` z placeholderami (bez haseł) |
| `make secrets-export` | Wypisuje `export VAR=...` z Bitwarden (do eval) |
| `make up` | `secrets-wrap` → docker compose z env vars z BW |
| `make secrets-seed` | Załaduj secrety z `defaults.env` do vault |
| `make secrets-scan-apply` | Skan kodu → BW + zamiana na `{{bw:...}}` |

### secrets-wrap (ręcznie)

```bash
./scripts/bitwarden/secrets-wrap.sh docker compose up -d
./scripts/bitwarden/secrets-wrap.sh docker compose exec php php laravel/artisan migrate
```

---

## Placeholdery w plikach

```dotenv
# laravel/.env
DB_PASSWORD={{bw:hrk-live-coding/db/postgres-password}}
APP_KEY={{bw:hrk-live-coding/laravel/app-key}}

# symfony/.env
APP_SECRET={{bw:hrk-live-coding/symfony/app-secret}}
DATABASE_URL="postgresql://dev:{{bw:hrk-live-coding/db/postgres-password}}@postgres:5432/hrk_demo?serverVersion=16&charset=utf8"
```

Laravel/Symfony dostają **prawdziwe wartości** przez zmienne środowiskowe kontenera (`docker-compose.yml` → `secrets-wrap`), które nadpisują placeholdery w `.env`.

---

## Co commitujemy

| Tak | Nie |
|---|---|
| `laravel/.env` z `{{bw:...}}` | plaintext haseł |
| `symfony/.env` z `{{bw:...}}` | `.env.docker` |
| `docker-compose.env.template` | `.secrets/defaults.env` |
| `templates/*.template` | `.secrets/.bw-session` |

---

## Jak pokazać na spotkaniu

1. Otwórz `laravel/.env` — widać `{{bw:hrk-live-coding/db/postgres-password}}`, nie hasło
2. `make secrets-export` — w terminalu widać export (można pokazać że nie zapisuje do pliku)
3. `make up` — kontenery startują z runtime env z Bitwarden
4. `make secrets-list` — etykiety w vault
5. `make bw-lock` — sejf zablokowany

**Narracja:** „W repozytorium trzymam etykiety Bitwarden. Hasła pobieram w runtime przez CLI — nigdy nie zapisuję ich do plików .env.”

---

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
