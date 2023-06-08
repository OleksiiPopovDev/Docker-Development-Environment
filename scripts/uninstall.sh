#!/bin/bash

. ./scripts/old-projects-list.sh

echo
echo "Choose number of project for uninstallation:"
read CHOOSED_PROJECT

COUNTER=0
for project in src/*/*; do
  if [ $COUNTER = $CHOOSED_PROJECT ]; then

    PROJECT_FOLDER=$(echo $project | cut -d '/' -f3)
    NGINX_FILE_NAME=$(echo $project | cut -d '/' -f3 | awk '{print tolower($0)}')
    PROJECT_NAME=$(echo $project | cut -d '/' -f3 | sed 's/\-//g')
    #PROJECT_TYPE=$(cat .repositories | grep $PROJECT_FOLDER | cut -d ']' -f1 | cut -d '[' -f2)
    PROJECT_TYPE=$(echo $project | cut -d '/' -f2 | sed 's/\-//g')

    DOCKER_FILE_CONF=docker/sites/$NGINX_FILE_NAME.conf
    DOCKER_DB_CONF=docker/databases/$PROJECT_NAME.db
    DOCKER_SENTRY_DUMP=docker/sentry/$PROJECT_NAME.json
    DOCKER_SSL_CRT=docker/ssl/$PROJECT_NAME.crt
    DOCKER_SSL_KEY=docker/ssl/$PROJECT_NAME.key

    if [ "$PROJECT_TYPE" = 'PHP' ]; then
      docker-compose -f docker-compose.php.yml stop
      docker-compose -f docker-compose.nginx.yml stop
    elif [ "$PROJECT_TYPE" = 'Node' ]; then
      docker-compose -f docker-compose.nginx.yml stop
      docker-compose -f docker-compose.node.yml stop
    else
      echo "Can't identify project type! Please check type in .repositories like [PHP], [Node], etc."
      exit
    fi

    [ -f "$DOCKER_FILE_CONF" ] && rm $DOCKER_FILE_CONF
    [ -f "$DOCKER_DB_CONF" ] && rm $DOCKER_DB_CONF
    [ -f "$DOCKER_SENTRY_DUMP" ] && rm $DOCKER_SENTRY_DUMP
    [ -f "$DOCKER_SSL_CRT" ] && rm $DOCKER_SSL_CRT
    [ -f "$DOCKER_SSL_KEY" ] && rm $DOCKER_SSL_KEY
    [ -d "$project" ] && rm -rf $project

    if [ "$PROJECT_TYPE" = 'PHP' ]; then
      docker-compose -f docker-compose.php.yml up --build -d
      docker-compose -f docker-compose.nginx.yml up --build -d
    elif [ "$PROJECT_TYPE" = 'Node' ]; then
      docker-compose -f docker-compose.nginx.yml up --build -d
      docker-compose -f docker-compose.node.yml up --build -d
    fi

    exit
  fi
  COUNTER=$((COUNTER + 1))
done
