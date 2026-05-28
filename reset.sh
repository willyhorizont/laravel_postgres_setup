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

POSTGRES_CONTAINER_ID=$(docker ps -a --filter ancestor=$POSTGRES_IMAGE_NAME --format "{{.ID}}")
echo "POSTGRES_CONTAINER_ID: $POSTGRES_CONTAINER_ID"
if [ -z "$POSTGRES_CONTAINER_ID" ]; then
    docker images
    docker container ls -a

    sudo rm -rf laravel-postgres-projects/$APP_NAME

    docker rmi -f $APP_IMAGE_NAME || true
    docker rmi -f $POSTGRES_IMAGE_NAME || true

    docker images
    docker container ls -a

    exit 1
fi

APP_CONTAINER_ID=$(docker ps -a --filter ancestor=$APP_IMAGE_NAME --format "{{.ID}}")
echo "APP_CONTAINER_ID: $APP_CONTAINER_ID"
if [ -z "$APP_CONTAINER_ID" ]; then
    docker images
    docker container ls -a

    sudo rm -rf laravel-postgres-projects/$APP_NAME

    docker rmi -f $APP_IMAGE_NAME || true
    docker rmi -f $POSTGRES_IMAGE_NAME || true

    docker images
    docker container ls -a

    exit 1
fi
docker images
docker container ls -a

sudo rm -rf laravel-postgres-projects/$APP_NAME

[ -n "$POSTGRES_CONTAINER_ID" ] && docker stop $POSTGRES_CONTAINER_ID || true
[ -n "$POSTGRES_CONTAINER_ID" ] && docker rm $POSTGRES_CONTAINER_ID || true
[ -n "$APP_CONTAINER_ID" ] && docker stop $APP_CONTAINER_ID || true
[ -n "$APP_CONTAINER_ID" ] && docker rm $APP_CONTAINER_ID || true

docker rmi -f $APP_IMAGE_NAME || true
docker rmi -f $POSTGRES_IMAGE_NAME || true

docker images
docker container ls -a