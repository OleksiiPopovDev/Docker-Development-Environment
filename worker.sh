#!/bin/bash

newProjectsList() {
  COUNTER=0;
  for repository in $(cat .repositories); do
    PROJECT_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1)
    FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | awk '{print tolower($0)}')
    FILE_CONF=docker/sites/$FILE_NAME.conf

    if [ ! -f "$FILE_CONF" ]; then
      echo "[$COUNTER] - "$PROJECT_NAME
    fi

    COUNTER=$(( COUNTER + 1 ))
  done

  if [ $COUNTER = 0 ]; then
    echo "No unidentified projects!"
    echo "Add repository url to file .repositories for new projects!"
    exit
  fi
}

oldProjectsList() {
  COUNTER=0;
  for project in api/*; do
    PROJECT_NAME=$(echo $project | cut -d '/' -f2 )
    FILE_NAME=$(echo $PROJECT_NAME | awk '{print tolower($0)}')
    FILE_CONF=docker/sites/$FILE_NAME.conf

    if [ -f "$FILE_CONF" ]; then
      echo "[$COUNTER] - "$PROJECT_NAME
      COUNTER=$(( COUNTER + 1 ))
    fi
  done

  if [ $COUNTER = 0 ]; then
    echo "No identified projects!"
    echo "Install project before uninstalling!"
    exit
  fi
}

[ "$1" = "monitor" ] && sampler --config ./docker/sampler/config.yml
[ "$1" = "bash" ] && docker exec -it $(grep CONTAINER_NAME_API .env | cut -d '=' -f2) /bin/bash
[ "$1" = "up" ] && docker-compose up --build
[ "$1" = "start" ] && docker-compose start
[ "$1" = "stop" ] && docker-compose stop
[ "$1" = "generate" ] && tr -dc A-Za-z0-9 </dev/urandom | head -c 13 ; echo ''

if [ "$1" = "install" ]; then
  echo "List of new projects:"; echo;

  newProjectsList

  echo; echo "Choose number of project for installation:"
  read CHOOSED_PROJECT

  COUNTER=0;
  for repository in $(cat .repositories); do
    if [ $COUNTER = $CHOOSED_PROJECT ]; then
      docker-compose down

      PROJECT_FOLDER=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1)
      NGINX_FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | awk '{print tolower($0)}')
      DB_FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | sed 's/\-//g')

      DOCKER_FILE_CONF=docker/sites/$NGINX_FILE_NAME.conf
      PROJECT_FILE_CONF=api/$PROJECT_FOLDER/docker/nginx.conf
      DOCKER_DB_CONF=docker/databases/$DB_FILE_NAME.db
      PROJECT_DB_CONF=api/$PROJECT_FOLDER/docker/database.db

      [ ! -d "api/" ] && mkdir api/
      [ ! -d "docker/sites/" ] && mkdir docker/sites/
      [ ! -d "docker/databases/" ] && mkdir docker/databases/

      # shellcheck disable=SC2164
      cd api/
      git clone $repository
      cd ../

      [ -f "$PROJECT_FILE_CONF" ] && cp $PROJECT_FILE_CONF $DOCKER_FILE_CONF
      [ -f "$PROJECT_DB_CONF" ] && cp $PROJECT_DB_CONF $DOCKER_DB_CONF

      cp .env.example .env && \
      echo "\n" >> .env && \
      echo "USERNAME=$(whoami)" >> .env && \
      echo "USERID=$(id -u $(whoami))" >> .env && \

      docker-compose up --build -d
      sleep 30

      MYSQL_ROOT_PASS=$(grep MYSQL_ROOT_PASSWORD .env | cut -d '=' -f2)
      docker exec -it $(grep CONTAINER_NAME_MYSQL .env | cut -d '=' -f2) sh -c "mysql -uroot -p$MYSQL_ROOT_PASS < /var/databases/$DB_FILE_NAME.db"
      docker exec -it $(grep CONTAINER_NAME_API .env | cut -d '=' -f2) sh -c "cd $PROJECT_FOLDER && cp .env.example .env && composer install && php artisan key:generate && php artisan migrate && php artisan db:seed"

      exit
    fi
    COUNTER=$(( COUNTER + 1 ))
  done
fi

if [ "$1" = "uninstall" ]; then
  echo "List of new projects:"; echo;

  oldProjectsList

  echo; echo "Choose number of project for uninstallation:"
  read CHOOSED_PROJECT

  COUNTER=0;
  for project in api/*; do
    if [ $COUNTER = $CHOOSED_PROJECT ]; then

      PROJECT_FOLDER=$(echo $project | cut -d '/' -f2)
      NGINX_FILE_NAME=$(echo $project | cut -d '/' -f2 | awk '{print tolower($0)}')
      DB_FILE_NAME=$(echo $project | cut -d '/' -f2 | sed 's/\-//g')

      DOCKER_FILE_CONF=docker/sites/$NGINX_FILE_NAME.conf
      DOCKER_DB_CONF=docker/databases/$DB_FILE_NAME.conf

      docker-compose down

      [ -f "$DOCKER_FILE_CONF" ] && rm $DOCKER_FILE_CONF
      [ -f "$DOCKER_DB_CONF" ] && rm $DOCKER_DB_CONF
      [ -d "api/"$PROJECT_FOLDER ] && rm -rf api/$PROJECT_FOLDER

      docker-compose up --build -d

      exit;
    fi
    COUNTER=$(( COUNTER + 1 ))
  done
fi