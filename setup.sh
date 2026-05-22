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

echo "laravel_postgres_setup"

echo "
php:8.5.6-cli
composer/composer:2.9.8-bin
postgres:18.4
laravel/framework:13.11.2==laravel/laravel:13.7.0
node:26.1.0
npm:11.15.0
"

echo "git config --global --add safe.directory \"$WORKDIR\""

git config --global --add safe.directory "$WORKDIR"

echo "laravel_postgres_setup [1/4] Build & start containers..."

echo "docker compose build --no-cache"
docker compose build --no-cache

echo "docker compose up -d --build"
docker compose up -d --build

until docker compose exec -T app bash -lc "
php -r '
try {
    new PDO(\"pgsql:host=postgres;port=5432;dbname=laravel\", \"postgres\", \"secret\");
    echo \"OK\";
} catch (Exception \$e) {
    exit(1);
}
'
"; do
    echo "Waiting for PostgreSQL..."
    sleep 1
done

echo "laravel_postgres_setup [2/4] Create Laravel project..."

COMMAND_CREATE_LARAVEL_PROJECT="
  cd $WORKDIR &&
  mkdir -p $WORKDIR/laravel-projects &&
  rm -rf $WORKDIR/laravel-projects/$APP_NAME &&
  echo 'laravel_postgres_setup -> php --version:' &&
  php --version &&
  echo 'laravel_postgres_setup -> composer --version:' &&
  composer --version &&
  git config --global --add safe.directory $WORKDIR &&
  composer config --global process-timeout 600 &&
  composer create-project --prefer-dist laravel/laravel:13.7.0 $WORKDIR/laravel-projects/$APP_NAME
"
echo "$COMMAND_CREATE_LARAVEL_PROJECT"

docker compose exec app bash -lc "$COMMAND_CREATE_LARAVEL_PROJECT"

echo "laravel_postgres_setup [3/4] Install dependencies..."

COMMAND_INSTALL_DEPS="
  cd $WORKDIR/laravel-projects/$APP_NAME &&
  echo 'laravel_postgres_setup -> php artisan --version:' &&
  php artisan --version &&
  npm install -g npm@11.15.0 --no-fund --no-audit &&
  echo 'laravel_postgres_setup -> npm --version:' &&
  npm --version &&
  npm install --no-fund --no-audit
"
# && npm run build
echo "$COMMAND_INSTALL_DEPS"

docker compose exec app bash -lc "$COMMAND_INSTALL_DEPS"

echo "laravel_postgres_setup [4/4] Migrate database..."

COMMAND_MIGRATE_DATABASE="
  cd $WORKDIR/laravel-projects/$APP_NAME &&
  php artisan migrate
"
echo "$COMMAND_MIGRATE_DATABASE"

docker compose exec app bash -lc "$COMMAND_MIGRATE_DATABASE"

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
sudo rm -rf laravel-projects/$APP_NAME
docker stop $POSTGRES_CONTAINER_ID || true
docker rm $POSTGRES_CONTAINER_ID || true
docker stop $APP_CONTAINER_ID || true
docker rm $APP_CONTAINER_ID || true
docker rmi laravel-postgres-$APP_NAME:configured || true
docker rmi postgres:18.4 || true
or just: ./reset.sh $APP_NAME
"

echo "laravel_postgres_setup DONE"
echo "laravel_postgres_setup Run:"
echo "sudo chown -R \$USER:\$USER laravel-projects/$APP_NAME && docker compose exec app bash -lc \"cd $WORKDIR/laravel-projects/$APP_NAME && php artisan serve --host=0.0.0.0 --port=8000\""