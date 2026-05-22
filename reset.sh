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
POSTGRES_CONTAINER_ID=$(docker ps -a --filter ancestor=postgres:18.4 --format "{{.ID}}")
if [ -z "$POSTGRES_CONTAINER_ID" ]; then
    docker images
    docker container ls -a
    echo "no need to reset $APP_NAME"
    exit 1
fi
APP_CONTAINER_ID=$(docker ps -a --filter ancestor=laravel-postgres-$APP_NAME:configured --format "{{.ID}}")
if [ -z "$APP_CONTAINER_ID" ]; then
    docker images
    docker container ls -a
    echo "no need to reset $APP_NAME"
    exit 1
fi
export IMAGE_NAME_SUFFIX=$APP_NAME
docker images
docker container ls -a
sudo rm -rf laravel-projects/$APP_NAME
docker stop $POSTGRES_CONTAINER_ID || true
docker rm $POSTGRES_CONTAINER_ID || true
docker stop $APP_CONTAINER_ID || true
docker rm $APP_CONTAINER_ID || true
docker rmi laravel-postgres-$APP_NAME:configured || true
docker rmi postgres:18.4 || true
docker images
docker container ls -a