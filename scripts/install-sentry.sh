#!/bin/bash

if [ "$1" = "install" ]; then
  SENTRY_ADMIN_EMAIL=$(grep SENTRY_ADMIN_EMAIL .env | cut -d '=' -f2)
  SENTRY_ADMIN_PASSWORD=$(grep SENTRY_ADMIN_PASSWORD .env | cut -d '=' -f2)

  docker-compose -f docker-compose.sentry.yml up --build -d
  docker exec -it $(grep CONTAINER_NAME_SENTRY .env | cut -d '=' -f2) sh -c "sentry upgrade --noinput"
  docker exec -it $(grep CONTAINER_NAME_SENTRY .env | cut -d '=' -f2) sh -c "sentry createuser --email $SENTRY_ADMIN_EMAIL --password $SENTRY_ADMIN_PASSWORD --superuser"
fi

if [ "$1" = "import" ]; then
  for project in docker/sentry/*; do
    IMPORT_FILE=$(echo $project | cut -d '/' -f3 | cut -d '.' -f1)
    docker exec -it $(grep CONTAINER_NAME_SENTRY .env | cut -d '=' -f2) sh -c "sentry import /var/backups/$IMPORT_FILE.json"
  done
fi
