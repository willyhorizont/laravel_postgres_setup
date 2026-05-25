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

clear

POSTGRES_IMAGE_NAME="postgres:18.4"
APP_IMAGE_NAME="laravel-postgres-$APP_NAME:configured"

POSTGRES_CONTAINER_ID=$(docker ps -a --filter ancestor=$POSTGRES_IMAGE_NAME --format "{{.ID}}")
if [ -z "$POSTGRES_CONTAINER_ID" ]; then
    docker images
    docker container ls -a

    sudo rm -rf laravel-postgres-projects/$APP_NAME

    docker rmi $APP_IMAGE_NAME || true
    docker rmi $POSTGRES_IMAGE_NAME || true

    docker images
    docker container ls -a

    exit 1
fi

APP_CONTAINER_ID=$(docker ps -a --filter ancestor=$APP_IMAGE_NAME --format "{{.ID}}")
if [ -z "$APP_CONTAINER_ID" ]; then
    docker images
    docker container ls -a

    sudo rm -rf laravel-postgres-projects/$APP_NAME

    docker rmi $APP_IMAGE_NAME || true
    docker rmi $POSTGRES_IMAGE_NAME || true

    docker images
    docker container ls -a

    exit 1
fi
docker images
docker container ls -a

sudo rm -rf laravel-postgres-projects/$APP_NAME

docker stop $POSTGRES_CONTAINER_ID || true
docker rm $POSTGRES_CONTAINER_ID || true
docker stop $APP_CONTAINER_ID || true
docker rm $APP_CONTAINER_ID || true

docker rmi $APP_IMAGE_NAME || true
docker rmi $POSTGRES_IMAGE_NAME || true

docker images
docker container ls -a