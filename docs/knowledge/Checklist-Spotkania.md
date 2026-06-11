<link rel="stylesheet" href="../styles/main.css">

# Checklist na spotkanie

<!-- nav -->
[← README](README.md) › [Start i kontekst](README.md#start-i-kontekst)

## Technicznie (15 min przed)

- [ ] `make doctor` — Bitwarden + kontenery + serwery + smoke testy (zalecane zamiast samo `make up`)
- [ ] albo: `make bw-unlock && make up && make start && make verify`
- [ ] `make status` — postgres, sqlserver, php: `running`
- [ ] Otwarte w Cursorze: `laravel/`, `symfony/`, `sql/`, `exercises/`
- [ ] Przetestowane: `make psql`, `make mssql`
- [ ] Wi-Fi + plan B (hotspot)
- [ ] Kamera / mikrofon / screen share

## W Cursorze

- [ ] Font i zoom czytelny na screen share
- [ ] Rozważ wyłączenie agresywnego AI autocomplete na czas zadania
- [ ] Znasz skróty: multi-cursor, rename symbol, go to definition

## Merytorycznie

- [ ] 2 min na głos: „jak migrowałbym moduł fakturowania z .NET do PHP”
- [ ] Znasz różnicę Symfony vs Laravel (bez fanatyzmu)
- [ ] Przygotuj 2 pytania o stack klienta

## Szybki test 5 min przed

```bash
make verify
curl -s http://localhost:8000/up          # Laravel health (jeśli serwer włączony)
./scripts/compose.sh exec -T postgres psql -U dev -d hrk_demo -c "SELECT COUNT(*) FROM invoices;"
```

## Powiązane

- [Szybki start](Szybki-Start.md)
- [Bitwarden Secrets](Bitwarden-Secrets.md)
- [Rozwiązywanie problemów](Rozwiazywanie-Problemow.md)

---
[← README](README.md) › [Start i kontekst](README.md#start-i-kontekst)
