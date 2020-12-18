cp .env.example .env

echo "\n" >> .env
echo "USERNAME=$(whoami)" >> .env
echo "USERID=$(id -u $(whoami))" >> .env

docker-compose up --build