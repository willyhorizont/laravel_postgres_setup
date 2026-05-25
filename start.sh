#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: ./setup.sh <app-name>"
    exit 1
fi

APP_NAME="$1"
export IMAGE_NAME_SUFFIX="$APP_NAME"
WORKDIR="/workspace"

echo "APP_NAME=$APP_NAME"

bash ./print-specification.sh

echo "docker compose up -d --build"
docker compose up -d --build

until docker compose exec -T app php -r "
try {
    new PDO('pgsql:host=postgres;port=5432;dbname=laravel', 'postgres', 'secret');
    echo 'OK';
} catch (Exception \$e) {
    exit(1);
}
" >/dev/null 2>&1; do
    echo "Waiting for PostgreSQL..."
    sleep 1
done

POSTGRES_CONTAINER_ID=$(docker ps -a --filter ancestor=postgres:18.4 --format \"{{.ID}}\")
APP_CONTAINER_ID=$(docker ps -a --filter ancestor=laravel-postgres-$APP_NAME:configured --format \"{{.ID}}\")

echo "
stop:
clear
\$APP_NAME=\"$APP_NAME\"
export IMAGE_NAME_SUFFIX=\"$APP_NAME\"
docker compose down
or just: ./stop.sh $APP_NAME

reset:
clear
\$APP_NAME=\"$APP_NAME\"
\$POSTGRES_CONTAINER_ID=\$(docker ps -a --filter ancestor=postgres:18.4 --format \"{{.ID}}\")
\$APP_CONTAINER_ID=\$(docker ps -a --filter ancestor=laravel-postgres-$APP_NAME:configured --format \"{{.ID}}\")
export IMAGE_NAME_SUFFIX=\"$APP_NAME\"
docker images
docker container ls -a
sudo rm -rf laravel-postgres-projects/$APP_NAME
docker stop $POSTGRES_CONTAINER_ID || true
docker rm $POSTGRES_CONTAINER_ID || true
docker stop $APP_CONTAINER_ID || true
docker rm $APP_CONTAINER_ID || true
docker rmi laravel-postgres-$APP_NAME:configured || true
docker rmi postgres:18.4 || true
or just: ./reset.sh $APP_NAME
"

COMMAND_START_PROJECT="
cd $WORKDIR/laravel-postgres-projects/$APP_NAME && php artisan serve --host=0.0.0.0 --port=8000
"

echo "docker compose exec app bash -lc \"$COMMAND_START_PROJECT\""

docker compose exec app bash -lc "$COMMAND_START_PROJECT"