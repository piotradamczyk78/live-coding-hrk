<link rel="stylesheet" href="../styles/main.css">

# Szybki start

<!-- nav -->
[← README](README.md) › [Start i kontekst](README.md#start-i-kontekst)

```bash
cd /Users/admin/Developer/Workspace/live-coding-hrk

# Pierwsze uruchomienie (pobiera obrazy, generuje Laravel + Symfony)
chmod +x scripts/*.sh
make bootstrap

# Codzienne sprawdzenie przed spotkaniem
make bw-unlock    # jeśli używasz Bitwarden
make up
make verify
make status
```

<div class="callout callout--warn">
  <span class="badge">UWAGA</span>
  <p><code>make up</code> uruchamia <strong>tylko kontenery Docker</strong> (PostgreSQL, MS SQL, PHP, Adminer). <strong>Nie startuje</strong> serwerów Laravel, Symfony ani .NET — bez nich <code>/invoices</code> nie odpowie, mimo że bazy mają dane.</p>
</div>

## Serwery aplikacji

Po `make up` uruchom serwery dev osobno:

```bash
# Laravel + Symfony w tle (zalecane)
make start

# albo interaktywnie (osobne terminale)
make laravel      # http://localhost:8000/invoices
make symfony      # http://localhost:8001/invoices
```

**.NET** (poza Dockerem, MS SQL):

```bash
make dotnet        # w tle → http://localhost:5050/invoices

# lub interaktywnie:
cd dotnet-skeleton
export MSSQL_SA_PASSWORD="$(grep MSSQL_SA_PASSWORD ../.secrets/defaults.env | cut -d= -f2)"
dotnet run --urls http://localhost:5050
```

### Wszystko jednym strzałem

```bash
make doctor
```

`make doctor` wykonuje m.in.:

1. **Bitwarden** — odblokowanie sejfu, seed haseł do vault, `secrets-sync` (w plikach tylko etykiety `{{bw:...}}`)
2. Kontenery Docker z secretami z Bitwarden (runtime)
3. Synchronizacja haseł DB, schematy
4. **Czyszczenie cache** — Laravel, Symfony, .NET (`make clear-cache`)
5. Serwery Laravel + Symfony + **.NET** w tle
6. Smoke testy HTTP na `/invoices` (wszystkie trzy frameworki)

### Szybki test faktur

```bash
curl -s -o /dev/null -w "Laravel %{http_code}\n" http://localhost:8000/invoices
curl -s -o /dev/null -w "Symfony %{http_code}\n" http://localhost:8001/invoices
curl -s -o /dev/null -w "dotnet  %{http_code}\n" http://localhost:5050/invoices
```

Oczekiwany wynik: **HTTP 200** na wszystkich trzech.

### Po `make secrets-sync`

Placeholdery `{{bw:...}}` wracają do `laravel/.env` — uruchom ponownie serwer:

```bash
./scripts/laravel-env-patch.sh
make laravel      # lub: make start
```

`make doctor` robi to automatycznie (Bitwarden + sync + patch + restart serwerów).

## Powiązane

- [Makefile](Makefile.md)
- [Komponenty i dostęp](Komponenty-i-Dostep.md)
- [Bitwarden Secrets](Bitwarden-Secrets.md)
- [Laravel — APP_KEY](Laravel.md#app-key-blad-szyfrowania)
- [Checklist na spotkanie](Checklist-Spotkania.md)

---
[← README](README.md) › [Start i kontekst](README.md#start-i-kontekst)
