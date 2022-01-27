#!/bin/bash

docker-compose -f docker-compose.base.yml up --build -d

[ ! -d "docker/databases/" ] && exit

MYSQL_ROOT_PASS=$(grep MYSQL_ROOT_PASSWORD .env | cut -d '=' -f2)
CONTAINER_MYSQL=$(grep CONTAINER_NAME_MYSQL .env | cut -d '=' -f2)
CONTAINER_API=$(grep CONTAINER_NAME_API .env | cut -d '=' -f2)

for config in docker/databases/*; do
  DB_FILE_NAME=$(echo $config | cut -d '/' -f3 | sed 's/\-//g')
  while ! docker exec -it $CONTAINER_MYSQL sh -c "export MYSQL_PWD=$MYSQL_ROOT_PASS ; mysql -uroot < /var/databases/$DB_FILE_NAME" --silent; do
    echo "Waiting 10 seconds for start of MySQL and check again!"
    sleep 10
  done
  echo "Configured Database of $DB_FILE_NAME"
done

for project in src/*; do
  PROJECT_FOLDER=$(echo $project | cut -d '/' -f2)
  docker exec -it $CONTAINER_API sh -c "cd $PROJECT_FOLDER && cp .env.example .env && composer install"
  docker exec -it $CONTAINER_API sh -c "cd $PROJECT_FOLDER && php artisan key:generate && php artisan migrate && php artisan db:seed"
done
