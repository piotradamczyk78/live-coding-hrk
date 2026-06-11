<link rel="stylesheet" href="../styles/main.css">

# Docker

<!-- nav -->
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)

## Menu wsparcia (interaktywne)

```bash
make docker-support   # Docker / Compose — lista komend → wpisz numer
make php-support      # PHP 8.3 w kontenerze hrk-php
```

## Status i logi

```bash
docker compose ps
docker compose ps -a
docker compose logs postgres
docker compose logs sqlserver
docker compose logs php
docker compose logs -f --tail=100 sqlserver    # śledzenie na żywo
```

## Wejście do kontenerów

```bash
docker compose exec php bash
docker compose exec postgres sh
docker compose exec php php -v
docker compose exec php composer --version
```

## Restart pojedynczego serwisu

```bash
docker compose restart php
docker compose restart postgres
docker compose restart sqlserver
docker compose up -d --force-recreate php
```

## Czyszczenie

```bash
docker compose down              # zatrzymaj, zachowaj dane
docker compose down -v           # zatrzymaj + usuń wolumeny (reset danych!)
docker system prune -f           # usuń nieużywane obrazy (ostrożnie)
```

## Jednorazowe polecenie w kontenerze PHP

```bash
docker compose exec php php -r "echo 'OK';"
docker compose exec php php -m | grep -E 'pdo|pgsql|intl'
docker compose run --rm --no-deps php composer --version
```

## MS SQL — sqlcmd bez interakcji

```bash
NETWORK=$(docker compose ps -q sqlserver | xargs docker inspect --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}{{end}}' | head -1)

docker run --rm --network "$NETWORK" mcr.microsoft.com/mssql-tools:latest \
  /opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P "$MSSQL_SA_PASSWORD" \
  -Q "SELECT TOP 5 number, amount, status FROM dbo.invoices"
```

<div class="callout callout--warn">
  <span class="badge">UWAGA</span>
  <p>Azure SQL Edge nie ma <code>sqlcmd</code> wewnątrz kontenera. Używamy obrazu <code>mcr.microsoft.com/mssql-tools</code> jako klienta.</p>
</div>

## Powiązane

- [Makefile](Makefile.md)
- [MS SQL](MSSQL.md)
- [Rozwiązywanie problemów](Rozwiazywanie-Problemow.md)

---
[← README](README.md) › [Infrastruktura](README.md#infrastruktura)
