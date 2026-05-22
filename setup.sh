#!/bin/bash

set -e

APP_NAME="new-app"
WORKDIR="/workspace"

echo "laravel_setup"

echo "
php:8.5.6-cli
composer/composer:2.9.8-bin
postgres:18.4
laravel/framework:13.11.2==laravel/laravel:13.7.0
node:26.1.0
npm:11.13.0

reset:
clear &&
docker images &&
docker compose down &&
sudo rm -rf new-app &&
docker rmi postgres:18.4 &&
docker rmi php-composer-postgres-node-laravel:configured
"

git config --global --add safe.directory "$WORKDIR"

echo "laravel_setup [1/4] Build & start containers..."
docker compose build --no-cache
docker compose up -d --build

echo "laravel_setup [2/4] Create Laravel project..."

docker compose exec app bash -lc "
  cd $WORKDIR &&
  rm -rf $APP_NAME &&
  echo 'laravel_setup -> php --version:' &&
  php --version &&
  echo 'laravel_setup -> composer --version:' &&
  composer --version &&
  git config --global --add safe.directory $WORKDIR &&
  composer create-project laravel/laravel:13.7.0 $APP_NAME
"

echo "laravel_setup [3/4] Install frontend..."

docker compose exec app bash -lc "
  cd $WORKDIR/$APP_NAME &&
  echo 'laravel_setup -> php artisan --version:' &&
  php artisan --version &&
  npm install npm@11.13.0 --no-fund --no-audit &&
  echo 'laravel_setup -> npm --version:' &&
  npm --version &&
  npm install --no-fund --no-audit &&
  npm run build
"

echo "laravel_setup [4/4] Migrate database..."

docker compose exec app bash -lc "
  cd $WORKDIR/$APP_NAME &&
  php artisan migrate
"

echo "laravel_setup DONE"
echo "laravel_setup Run:"
echo "sudo chown -R \$USER:\$USER $APP_NAME && docker compose exec app bash -lc \"cd $APP_NAME && php artisan serve --host=0.0.0.0 --port=8000\""