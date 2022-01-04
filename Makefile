#!/bin/bash
include .env
export $(shell sed 's/=.*//' .env)

.PHONY: help

help:
	@echo "Hi!"

monitor:
	@sampler --config ./docker/sampler/config.yml

bash:
	@docker exec -it ${CONTAINER_NAME_API} /bin/bash

start:
	@docker-compose -f docker-compose.base.yml start

stop:
	@docker-compose -f docker-compose.base.yml stop

generate:
	@tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo ''

up:
	@sh scripts/docker-up.sh

down:
	@docker-compose -f docker-compose.base.yml down

rebuild: down up

install:
	@sh scripts/install.sh

uninstall:
	@sh scripts/uninstall.sh

sentry-install: sentry-import
	@sh scripts/install-sentry.sh install

sentry-import:
	@sh scripts/install-sentry.sh import
