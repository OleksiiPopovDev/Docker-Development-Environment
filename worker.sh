#!/bin/bash

if [ "$1" = "monitor" ]; then
  sampler --config ./docker/sampler/config.yml
fi

if [ "$1" = "bash" ]; then
  docker exec -it $(grep CONTAINER_NAME_API .env | cut -d '=' -f2) /bin/bash
fi

if [ "$1" = "start" ]; then
  docker-compose up --build
fi

if [ "$1" = "test" ]; then
  echo "List of new projects:"; echo;

  COUNTER=0;
  for d in $(cat .repositories); do
    echo $d
  done
  for d in api/*/; do
    #cp "$d"docker/nginx.conf docker/sites/$(echo $d | cut -d '/' -f2)-test.conf
    #PROJECT_NAME=$(echo $d | cut -d '/' -f2 | awk '{print tolower($0)}')
    FILE=docker/sites/$PROJECT_NAME-test.conf

    if [ ! -f "$FILE" ]; then
      echo $(echo $d | cut -d '/' -f2)" - [$COUNTER]"
      COUNTER=$(( COUNTER + 1 ))
    fi
  done

  echo; echo "Choose number of project for installation:"
  read CHOOSED_PROJECT

  COUNTER=0;
  for d in api/*/; do
    if [ $COUNTER = $CHOOSED_PROJECT ]; then
      PROJECT_NAME=$(echo $d | cut -d '/' -f2 | awk '{print tolower($0)}')
      FILE=docker/sites/$PROJECT_NAME-test.conf

      echo;
      echo "Choosed project: "$PROJECT_NAME
      echo "Copy conf file: "$FILE
    fi
    COUNTER=$(( COUNTER + 1 ))
  done

fi

if [ "$1" = "install" ]; then
  cp .env.example .env

  # shellcheck disable=SC2129
  # shellcheck disable=SC2028
  echo "\n" >> .env
  echo "USERNAME=$(whoami)" >> .env
  # shellcheck disable=SC2046
  echo "USERID=$(id -u $(whoami))" >> .env

  docker-compose up --build
fi