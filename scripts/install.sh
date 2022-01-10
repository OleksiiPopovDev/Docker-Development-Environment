#!/bin/bash

. ./scripts/new-projects-list.sh

echo
echo "Choose number of project for installation:"
read CHOOSED_PROJECT

COUNTER=0
for repository in $(cat .repositories); do
  if [ $COUNTER = $CHOOSED_PROJECT ]; then
    docker-compose -f docker-compose.base.yml down

    PROJECT_FOLDER=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1)
    NGINX_FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | awk '{print tolower($0)}')
    DB_FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | sed 's/\-//g')
    SENTRY_FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | sed 's/\-//g')

    DOCKER_FILE_CONF=docker/sites/$NGINX_FILE_NAME.conf
    PROJECT_FILE_CONF=src/$PROJECT_FOLDER/docker/nginx.conf
    DOCKER_DB_CONF=docker/databases/$DB_FILE_NAME.db
    PROJECT_DB_CONF=src/$PROJECT_FOLDER/docker/database.db
    DOCKER_SENTRY_DUMP=docker/sentry/$SENTRY_FILE_NAME.json
    PROJECT_SENTRY_DUMP=src/$PROJECT_FOLDER/docker/sentry.json

    [ ! -d "src/" ] && mkdir src/
    [ ! -d "docker/sites/" ] && mkdir docker/sites/
    [ ! -d "docker/databases/" ] && mkdir docker/databases/
    [ ! -d "docker/sentry/" ] && mkdir docker/sentry/

    # shellcheck disable=SC2164
    cd src/
    git clone $repository
    cd ../

    [ -f "$PROJECT_FILE_CONF" ] && cp $PROJECT_FILE_CONF $DOCKER_FILE_CONF
    [ -f "$PROJECT_DB_CONF" ] && cp $PROJECT_DB_CONF $DOCKER_DB_CONF
    [ -f "$PROJECT_SENTRY_DUMP" ] && cp $PROJECT_SENTRY_DUMP $DOCKER_SENTRY_DUMP

    cp .env.example .env &&
      echo "\n" >>.env &&
      echo "USERNAME=$(whoami)" >>.env &&
      echo "USERID=$(id -u $(whoami))" >>.env &&
      docker-compose -f docker-compose.base.yml up --build -d

    echo "Please wait!"
    sleep 30

    MYSQL_ROOT_PASS=$(grep MYSQL_ROOT_PASSWORD .env | cut -d '=' -f2)
    docker exec -it $(grep CONTAINER_NAME_MYSQL .env | cut -d '=' -f2) sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASS ; mysql -uroot < /var/databases/$DB_FILE_NAME.db"
    docker exec -it $(grep CONTAINER_NAME_API .env | cut -d '=' -f2) sh -c "cd $PROJECT_FOLDER && cp .env.example .env && composer install && php artisan key:generate && php artisan migrate && php artisan db:seed"

    exit
  fi
  COUNTER=$((COUNTER + 1))
done
