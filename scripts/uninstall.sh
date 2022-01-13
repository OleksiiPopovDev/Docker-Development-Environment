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
    DB_FILE_NAME=$(echo $project | cut -d '/' -f2 | sed 's/\-//g')
    SENTRY_FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | sed 's/\-//g')

    DOCKER_FILE_CONF=docker/sites/$NGINX_FILE_NAME.conf
    DOCKER_DB_CONF=docker/databases/$DB_FILE_NAME.db
    DOCKER_SENTRY_DUMP=docker/sentry/$SENTRY_FILE_NAME.json

    docker-compose -f docker-compose.base.yml down

    [ -f "$DOCKER_FILE_CONF" ] && rm $DOCKER_FILE_CONF
    [ -f "$DOCKER_DB_CONF" ] && rm $DOCKER_DB_CONF
    [ -f "$DOCKER_SENTRY_DUMP" ] && rm $DOCKER_SENTRY_DUMP
    [ -d "src/$PROJECT_FOLDER" ] && rm -rf src/$PROJECT_FOLDER

    docker-compose -f docker-compose.base.yml up --build -d

    exit
  fi
  COUNTER=$((COUNTER + 1))
done
