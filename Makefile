#!/bin/bash
include .env
export $(shell sed 's/=.*//' .env)

.PHONY: help

help:
	@echo
	@echo "\033[37mThis is simple CLI commands for quick deployment of your development environment\033[0m"
	@echo "\033[37mAuthor: Oleksii Popov\033[0m"
	@echo "\033[37mE-Mail: popov.scar@gmail.com\033[0m"
	@echo
	@echo "\033[36mBase Commands:\033[0m"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make install" "Installation new project to Container"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make uninstall" "Reinstall project from Container"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make bash" "Enter to Bash of Container"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make start" "Start Docker Containers"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make stop" "Stop Docker Containers"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make up" "Build and up Containers"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make down" "Remove Containers"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make rebuild" "Remove, build and up Containers with refreshing database, migrations and seeds"
	@echo
	@echo "\033[36mAdditional service's commands:\033[0m"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make sentry-install" "Install the Sentry for projects. Installation with redis and Postgres"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make sentry-import" "Import a projects to Sentry"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make sentry-uninstall" "Yahh! This is uninstalling the Sentry"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make grafana-install" "Installation Grafana with default credentials"
	@printf "\x1B[92m%-30s \033[32m%10s\033[0m\n" "make grafana-uninstall" "Uninstall the Grafana"
	@echo

monitor:
	@sampler --config ./docker/sampler/config.yml

bash:
	@docker exec -it ${CONTAINER_NAME_API} /bin/bash

start:
	@docker-compose -f docker-compose.base.yml start
	@docker-compose -f docker-compose.grafana.yml start 2> /dev/null
	@docker-compose -f docker-compose.sentry.yml start 2> /dev/null

stop:
	@docker-compose -f docker-compose.base.yml stop
	@docker-compose -f docker-compose.grafana.yml stop 2> /dev/null
	@docker-compose -f docker-compose.sentry.yml stop 2> /dev/null

restart: stop start

generate:
	@tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo ''

up:
	@sh scripts/docker-up.sh

down:
	@docker-compose -f docker-compose.base.yml -f docker-compose.grafana.yml -f docker-compose.sentry.yml down

rebuild: down up

install:
	@sh scripts/install.sh

uninstall:
	@sh scripts/uninstall.sh

sentry-install:
	@sh scripts/install-sentry.sh install
	@sh scripts/install-sentry.sh import

sentry-import:
	@sh scripts/install-sentry.sh import

sentry-uninstall:
	@docker-compose -f docker-compose.sentry.yml down

grafana-install:
	@docker-compose -f docker-compose.grafana.yml up -d

grafana-uninstall:
	@docker-compose -f docker-compose.grafana.yml down