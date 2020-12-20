if [ "$1" = "monitor" ]; then
  sampler --config ./docker/sampler/config.yml
fi

if [ "$1" = "bash" ]; then
  docker exec -it AlekseyPopov-Dev-Env-api /bin/bash
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