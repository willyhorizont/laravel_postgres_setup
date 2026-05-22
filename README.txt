php:8.5.6-cli
composer/composer:2.9.8-bin
postgres:18.4
laravel/framework:13.11.2==laravel/laravel:13.7.0
node:26.1.0
npm:11.13.0

reset:
clear &&
docker images &&
docker container ls -a &&
docker compose down &&
sudo rm -rf new-app

# docker stop [postgres:18.4 container id]
# docker rm [postgres:18.4 container id]
# docker rmi postgres:18.4
# docker stop [php-composer-postgres-node-laravel:configured container id]
# docker rm [php-composer-postgres-node-laravel:configured container id]
# docker rmi php-composer-postgres-node-laravel:configured

build:
git config --global --add safe.directory /workspace
docker compose build --no-cache

run:
docker compose up -d --build

stop:
docker compose down

enter container:
docker compose exec app bash

check version:
php --version
composer --version

add PATH:
export PATH="$PATH:$(composer global config bin-dir --absolute)"

create new laravel app and install laravel:
git config --global --add safe.directory /workspace
composer create-project "laravel/laravel:13.7.0" new-app

run laravel app:
cd new-app
php artisan --version
npm --version
npm install && npm run build

php artisan serve --host=0.0.0.0 --port=8000

sudo chown -R $USER:$USER new-app