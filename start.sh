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

POSTGRES_IMAGE_NAME="postgres:18.4"
APP_IMAGE_NAME="laravelpostgresdockerized:configured"

bash ./print-specification.sh

POSTGRES_CONTAINER_ID=$(docker ps -a --filter ancestor=$POSTGRES_IMAGE_NAME --format \"{{.ID}}\")
APP_CONTAINER_ID=$(docker ps -a --filter ancestor=$APP_IMAGE_NAME --format \"{{.ID}}\")

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
\$POSTGRES_CONTAINER_ID=\$(docker ps -a --filter ancestor=$POSTGRES_IMAGE_NAME --format \"{{.ID}}\")
\$APP_CONTAINER_ID=\$(docker ps -a --filter ancestor=$APP_IMAGE_NAME --format \"{{.ID}}\")
export IMAGE_NAME_SUFFIX=\"$APP_NAME\"
docker images
docker container ls -a
sudo rm -rf laravel-postgres-projects/$APP_NAME
[ -n "$POSTGRES_CONTAINER_ID" ] && docker stop $POSTGRES_CONTAINER_ID || true
[ -n "$POSTGRES_CONTAINER_ID" ] && docker rm $POSTGRES_CONTAINER_ID || true
[ -n "$APP_CONTAINER_ID" ] && docker stop $APP_CONTAINER_ID || true
[ -n "$APP_CONTAINER_ID" ] && docker rm $APP_CONTAINER_ID || true
docker rmi $APP_IMAGE_NAME || true
docker rmi $POSTGRES_IMAGE_NAME || true
or just: ./reset.sh $APP_NAME
"

COMMAND_START_PROJECT="
cd $WORKDIR/laravel-postgres-projects/$APP_NAME && php artisan serve --host=0.0.0.0 --port=8000
"

echo "docker compose exec -T app bash -lc \"$COMMAND_START_PROJECT\""

docker compose exec -T app bash -lc "$COMMAND_START_PROJECT"