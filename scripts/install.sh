#!/bin/bash

. ./scripts/new-projects-list.sh

function installDatabase() {
  [ ! -f "docker/databases/$DB_FILE_NAME.db" ] && return
  # shellcheck disable=SC2046
  while ! docker exec -it $(grep CONTAINER_NAME_MYSQL .env | cut -d '=' -f2) sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASSWORD; mysql -uroot < /var/databases/$DB_FILE_NAME.db" --silent; do
    echo "Waiting 10 seconds for start of MySQL and check again!"
    sleep 10
    attempts=$((attempts + 1))
    if [ $attempts = 5 ]; then
      echo "Can't configure mysql database. Skip configuration database and continue installation? (yes/no)"
      read SKIP_CONFIGURATI

      if [ "$SKIP_CONFIGURATION" = "yes" ]; then
        break
      fi
    fi
  done
}

echo
echo "Choose number of project for installation:"
read CHOOSED_PROJECT

COUNTER=0
for repository in $(cat .repositories); do
  if [ $COUNTER = $CHOOSED_PROJECT ]; then

    PROJECT_TYPE=$(echo $repository | cut -d ']' -f1 | cut -d '[' -f2)
    repository=$(echo $repository | cut -d ']' -f2)

    PROJECT_FOLDER=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1)
    if [ -z "$PROJECT_FOLDER" ]; then
      PROJECT_FOLDER=$(echo $repository | cut -d '/' -f2 | cut -d '.' -f1)
    fi

    NGINX_FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | awk '{print tolower($0)}')
    if [ -z "$NGINX_FILE_NAME" ]; then
      NGINX_FILE_NAME=$(echo $repository | cut -d '/' -f2 | cut -d '.' -f1 | awk '{print tolower($0)}')
    fi

    DB_FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | sed 's/\-//g')
    if [ -z "$DB_FILE_NAME" ]; then
      DB_FILE_NAME=$(echo $repository | cut -d '/' -f2 | cut -d '.' -f1 | sed 's/\-//g')
    fi

    SENTRY_FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | sed 's/\-//g')
    if [ -z "$SENTRY_FILE_NAME" ]; then
      SENTRY_FILE_NAME=$(echo $repository | cut -d '/' -f2 | cut -d '.' -f1 | sed 's/\-//g')
    fi

    COMMON_SRC_FOLDER=src/$PROJECT_TYPE

    DOCKER_FILE_CONF=docker/sites/$NGINX_FILE_NAME.conf
    PROJECT_FILE_CONF=$COMMON_SRC_FOLDER/$PROJECT_FOLDER/docker/nginx.conf

    DOCKER_DB_CONF=docker/databases/$DB_FILE_NAME.db
    PROJECT_DB_CONF=$COMMON_SRC_FOLDER/$PROJECT_FOLDER/docker/database.db

    PROJECT_SH_FILE=$COMMON_SRC_FOLDER/$PROJECT_FOLDER/docker/install.sh

    DOCKER_SENTRY_DUMP=docker/sentry/$SENTRY_FILE_NAME.json
    PROJECT_SENTRY_DUMP=$COMMON_SRC_FOLDER/$PROJECT_FOLDER/docker/sentry.json

    DOCKER_CRT=docker/ssl/$SENTRY_FILE_NAME.crt
    PROJECT_CRT=$COMMON_SRC_FOLDER/$PROJECT_FOLDER/docker/certificate.crt
    DOCKER_PRIVATE_KEY=docker/ssl/$SENTRY_FILE_NAME.key
    PROJECT_PRIVATE_KEY=$COMMON_SRC_FOLDER/$PROJECT_FOLDER/docker/private.key

    [ ! -d "src/" ] && mkdir src/
    [ ! -d "$COMMON_SRC_FOLDER/" ] && mkdir "$COMMON_SRC_FOLDER"/
    [ ! -d "docker/sites/" ] && mkdir docker/sites/
    [ ! -d "docker/databases/" ] && mkdir docker/databases/
    [ ! -d "docker/sentry/" ] && mkdir docker/sentry/
    [ ! -d "docker/ssl/" ] && mkdir docker/ssl/

    # shellcheck disable=SC2164
    cd $COMMON_SRC_FOLDER/
    git clone $repository
    cd ../../

    [ -f "$PROJECT_FILE_CONF" ] && cp $PROJECT_FILE_CONF $DOCKER_FILE_CONF
    [ -f "$PROJECT_DB_CONF" ] && cp $PROJECT_DB_CONF $DOCKER_DB_CONF
    [ -f "$PROJECT_SENTRY_DUMP" ] && cp $PROJECT_SENTRY_DUMP $DOCKER_SENTRY_DUMP
    [ -f "$PROJECT_CRT" ] && cp $PROJECT_CRT $DOCKER_CRT
    [ -f "$PROJECT_PRIVATE_KEY" ] && cp $PROJECT_PRIVATE_KEY $DOCKER_PRIVATE_KEY

    cp .env.example .env &&
      echo "\n" >>.env &&
      echo "USERNAME=$(whoami)" >>.env &&
      echo "USERID=$(id -u $(whoami))" >>.env

    if [ "$PROJECT_TYPE" = 'PHP' ]; then
      docker-compose -f docker-compose.nginx.yml stop
      docker-compose -f docker-compose.mysql.yml stop
      docker-compose -f docker-compose.php.yml stop
      docker-compose -f docker-compose.nginx.yml up --build -d
      docker-compose -f docker-compose.mysql.yml up --build -d
      docker-compose -f docker-compose.php.yml up --build -d
      docker-compose -f docker-compose.nginx.yml start

      echo "Installation database"
      MYSQL_ROOT_PASS=$(grep MYSQL_ROOT_PASSWORD .env | cut -d '=' -f2)

      attempts=0
      installDatabase

      echo "Run installation scripts of project"
      # shellcheck disable=SC2046
      [ -f "$PROJECT_SH_FILE" ] && docker exec -it $(grep CONTAINER_NAME_PHP .env | cut -d '=' -f2) sh -c "cd $PROJECT_FOLDER && sh docker/install.sh"
      exit
    fi

    if [ "$PROJECT_TYPE" = 'Node' ]; then
      docker-compose -f docker-compose.node.yml -f docker-compose.nginx.yml stop

      # shellcheck disable=SC2164
      cd "$COMMON_SRC_FOLDER"/
      sh ../../scripts/node-demon.sh
      cd ../../

      docker-compose -f docker-compose.node.yml -f docker-compose.nginx.yml up --build -d

      [ -f "$PROJECT_SH_FILE" ] && docker exec -it $(grep CONTAINER_NAME_NODE .env | cut -d '=' -f2) sh -c "cd $PROJECT_FOLDER && sh docker/install.sh"
      exit
    fi

    if [ "$PROJECT_TYPE" = 'Python' ]; then
      docker-compose -f docker-compose.mysql.yml -f docker-compose.python.yml -f docker-compose.nginx.yml stop
      docker-compose -f docker-compose.mysql.yml -f docker-compose.python.yml -f docker-compose.nginx.yml up --build -d
      docker-compose -f docker-compose.nginx.yml start

      installDatabase

      [ -f "$PROJECT_SH_FILE" ] && docker exec -it $(grep CONTAINER_NAME_PYTHON .env | cut -d '=' -f2) sh -c "cd $PROJECT_FOLDER && sh docker/install.sh"
      exit
    fi
  fi
  COUNTER=$((COUNTER + 1))
done
