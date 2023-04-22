#!/bin/bash

. ./scripts/old-projects-list.sh

echo
echo "Choose number of project for uninstallation:"
read CHOOSED_PROJECT

COUNTER=0
for project in src/*; do
  if [ $COUNTER = $CHOOSED_PROJECT ]; then

    PROJECT_FOLDER=$(echo $project | cut -d '/' -f2)
    NGINX_FILE_NAME=$(echo $project | cut -d '/' -f2 | awk '{print tolower($0)}')
    PROJECT_NAME=$(echo $project | cut -d '/' -f2 | sed 's/\-//g')

    DOCKER_FILE_CONF=docker/sites/$NGINX_FILE_NAME.conf
    DOCKER_DB_CONF=docker/databases/$PROJECT_NAME.db
    DOCKER_SENTRY_DUMP=docker/sentry/$PROJECT_NAME.json
    DOCKER_SSL_CRT=docker/ssl/$PROJECT_NAME.crt
    DOCKER_SSL_KEY=docker/ssl/$PROJECT_NAME.key

    docker-compose -f docker-compose.base.yml stop

    [ -f "$DOCKER_FILE_CONF" ] && rm $DOCKER_FILE_CONF
    [ -f "$DOCKER_DB_CONF" ] && rm $DOCKER_DB_CONF
    [ -f "$DOCKER_SENTRY_DUMP" ] && rm $DOCKER_SENTRY_DUMP
    [ -f "$DOCKER_SSL_CRT" ] && rm $DOCKER_SSL_CRT
    [ -f "$DOCKER_SSL_KEY" ] && rm $DOCKER_SSL_KEY
    [ -d "src/$PROJECT_FOLDER" ] && rm -rf src/$PROJECT_FOLDER
    echo $DOCKER_SSL_CRT
    echo $DOCKER_SSL_KEY
    docker-compose -f docker-compose.base.yml up --build -d

    exit
  fi
  COUNTER=$((COUNTER + 1))
done
