#!/bin/bash
include .env
export $(shell sed 's/=.*//' .env)
DEFAULT_GOAL := help
.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nThis is simple CLI commands for quick deployment of your development environment\nAuthor: Oleksii Popov\nE-Mail: popov.scar@gmail.com\n\n make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-40s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: monitor
monitor:
	@sampler --config ./docker/sampler/config.yml

##@ [Docker commands]
.PHONY: bash
bash: ## Enter to Bash of Container
	@docker exec -it ${CONTAINER_NAME_API} /bin/bash

.PHONY: start
start: ## Start Docker Containers
	@docker-compose -f docker-compose.base.yml start
	@docker-compose -f docker-compose.grafana.yml start 2> /dev/null
	@docker-compose -f docker-compose.sentry.yml start 2> /dev/null

.PHONY: stop
stop: ## Stop Docker Containers
	@docker-compose -f docker-compose.base.yml stop
	@docker-compose -f docker-compose.grafana.yml stop 2> /dev/null
	@docker-compose -f docker-compose.sentry.yml stop 2> /dev/null

.PHONY: restart
restart: stop start ## Restart Docker Containers

.PHONY: generate
generate:
	@tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo ''

.PHONY: up
up: ## Build and up Containers
	@sh scripts/docker-up.sh

.PHONY: down
down: ## Remove Containers
	@docker-compose -f docker-compose.base.yml -f docker-compose.grafana.yml -f docker-compose.sentry.yml down

.PHONY: rebuild
rebuild: down up ## Remove, build and up Containers with refreshing database, migrations and seeds

##@ [Installer commands]
.PHONY: install
install: ## Installation new project to Container
	@sh scripts/install.sh

.PHONY: uninstall
uninstall: ## Reinstall project from Container
	@sh scripts/uninstall.sh

##@ [Sentry commands]
.PHONY: sentry-install
sentry-install: ## Install the Sentry for projects. Installation with redis and Postgres
	@sh scripts/install-sentry.sh install
	@sh scripts/install-sentry.sh import

.PHONY: sentry-import
sentry-import: ## Import a projects to Sentry
	@sh scripts/install-sentry.sh import

.PHONY: sentry-uninstall
sentry-uninstall: ## Yahh! This is uninstalling the Sentry
	@docker-compose -f docker-compose.sentry.yml down

##@ [Grafana commands]
.PHONY: grafana-install
grafana-install: ## Installation Grafana with default credentials
	@docker-compose -f docker-compose.grafana.yml up -d

.PHONY: grafana-uninstall
grafana-uninstall: ## Uninstall the Grafana
	@docker-compose -f docker-compose.grafana.yml down