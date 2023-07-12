#!/bin/bash

echo "List of installed projects:"
echo

COUNTER=0

for repository in $(cat .repositories); do
  PROJECT_NAME=$(echo $repository | cut -d '/' -f5 | cut -d '.' -f1)
  if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(echo $repository | cut -d '/' -f2 | cut -d '.' -f1)
  fi
  PROJECT_TYPE=$(echo $repository | cut -d ']' -f1 | cut -d '[' -f2)
  PROJECT_FOLDER=src/$PROJECT_TYPE/$PROJECT_NAME

  if [ -d "$PROJECT_FOLDER" ]; then
    echo "[$COUNTER] - "$PROJECT_NAME
  fi

  COUNTER=$((COUNTER + 1))
done


#for project in src/*/*; do
#  PROJECT_NAME=$(echo $project | cut -d '/' -f3)
#  FILE_NAME=$(echo $PROJECT_NAME | awk '{print tolower($0)}')
#  FILE_CONF=docker/sites/$FILE_NAME.conf

#  if [ -f "$FILE_CONF" ]; then
#    echo "[$COUNTER] - "$PROJECT_NAME
#    COUNTER=$((COUNTER + 1))
#  fi
#done

if [ $COUNTER = 0 ]; then
  echo "No identified projects!"
  echo "Install project before uninstalling!"
  exit
fi
