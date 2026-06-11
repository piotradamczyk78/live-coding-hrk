.PHONY: up down build bootstrap init-mssql psql mssql laravel symfony logs status verify reset doctor \
        bw-install bw-login bw-unlock bw-lock secrets-generate-defaults secrets-seed secrets-scan \
        secrets-sync secrets-export secrets-list secrets-repair-manifest secrets-setup

RUN := ./scripts/bitwarden/secrets-wrap.sh
COMPOSE := ./scripts/compose.sh

up:
	$(RUN) $(COMPOSE) up -d

down:
	$(COMPOSE) down

build:
	$(RUN) $(COMPOSE) build

bootstrap:
	./scripts/bootstrap.sh

init-mssql:
	$(RUN) ./scripts/init-mssql.sh

psql:
	$(COMPOSE) exec postgres psql -U dev -d hrk_demo

mssql:
	$(RUN) bash -c '\
		NETWORK=$$($(COMPOSE) ps -q sqlserver | xargs docker inspect --format "{{range \$$k, \$$v := .NetworkSettings.Networks}}{{\$$k}}{{end}}" | head -1); \
		docker run --rm -it --network "$$NETWORK" mcr.microsoft.com/mssql-tools:latest \
			/opt/mssql-tools/bin/sqlcmd -S sqlserver -U sa -P "$$MSSQL_SA_PASSWORD"'

laravel:
	./scripts/laravel-serve.sh

symfony:
	./scripts/symfony-serve.sh

start:
	./scripts/start-servers.sh

doctor:
	./scripts/doctor.sh

check:
	./scripts/status-check.sh

sync-passwords:
	./scripts/sync-db-passwords.sh

logs:
	$(COMPOSE) logs -f

status:
	$(COMPOSE) ps

verify:
	$(RUN) ./scripts/verify.sh

reset:
	$(COMPOSE) down -v
	./scripts/bootstrap.sh

# --- Bitwarden / secrets ---

bw-install:
	./scripts/bitwarden/install.sh

bw-login:
	./scripts/bitwarden/bw-login.sh

bw-unlock:
	./scripts/bitwarden/bw-unlock.sh

bw-lock:
	./scripts/bitwarden/bw-lock.sh

secrets-generate-defaults:
	./scripts/bitwarden/secrets-generate-defaults.sh

secrets-seed:
	./scripts/bitwarden/secrets-seed.sh

secrets-scan:
	./scripts/bitwarden/secrets-scan.sh --dry-run

secrets-scan-apply:
	./scripts/bitwarden/secrets-scan.sh --apply

secrets-sync:
	./scripts/bitwarden/secrets-sync.sh

secrets-export:
	./scripts/bitwarden/secrets-export-env.sh

secrets-list:
	./scripts/bitwarden/secrets-list.sh

secrets-repair-manifest:
	./scripts/bitwarden/secrets-repair-manifest.sh

secrets-setup: bw-install bw-login bw-unlock secrets-generate-defaults secrets-seed secrets-sync
	@echo ""
	@echo "Bitwarden skonfigurowany. Pliki .env mają placeholdery {{bw:...}}."
	@echo "Uruchom: make up"
