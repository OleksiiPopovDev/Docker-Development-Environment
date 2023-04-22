#!/bin/bash

echo "List of new projects:"
echo

COUNTER=0
COUNT_READY_INSTALL=0
for repository in $(cat .repositories); do
  PROJECT_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1)
  if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(echo $repository | cut -d '/' -f2 | cut -d '.' -f1)
  fi

  FILE_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1 | awk '{print tolower($0)}')
  if [ -z "$FILE_NAME" ]; then
    FILE_NAME=$(echo $repository | cut -d '/' -f2 | cut -d '.' -f1 | awk '{print tolower($0)}')
  fi

  FILE_CONF=docker/sites/$FILE_NAME.conf
  if [ ! -f "$FILE_CONF" ]; then
    echo "[$COUNTER] - "$PROJECT_NAME
    COUNT_READY_INSTALL=$((COUNT_READY_INSTALL + 1))
  fi

  COUNTER=$((COUNTER + 1))
done

if [ $COUNTER = 0 ]; then
  echo "No unidentified projects!"
  echo "Add repository url to file .repositories for new projects!"
  exit
fi

if [ $COUNT_READY_INSTALL = 0 ]; then
  echo "All available projects is installed!"
  echo "Add new repository url to file .repositories for new projects!"
  exit
fi
