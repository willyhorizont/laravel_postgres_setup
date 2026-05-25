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

bash ./print-specification.sh

echo "git config --global --add safe.directory \"$WORKDIR\""

git config --global --add safe.directory "$WORKDIR"

echo "laravel_postgres_setup [1/3] Build & start containers..."

echo "docker compose build --no-cache"
docker compose build --no-cache

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

echo "laravel_postgres_setup [2/3] Create Laravel project..."

COMMAND_LARAVEL_CREATE_PROJECT_OPTION_A="
cd $WORKDIR/laravel-postgres-projects && \
composer create-project --prefer-dist \"laravel/laravel:13.7.0\" $APP_NAME && \
"
COMMAND_LARAVEL_CREATE_PROJECT_OPTION_B="
composer global require laravel/installer && \
export PATH=\"\$(composer global config bin-dir --absolute):\$PATH\" && \
cd $WORKDIR/laravel-postgres-projects && \
laravel --database pgsql new $APP_NAME && \
"

COMMAND_CREATE_LARAVEL_PROJECT="
cd $WORKDIR && \
mkdir -p $WORKDIR/laravel-postgres-projects && \
rm -rf $WORKDIR/laravel-postgres-projects/$APP_NAME && \
echo \"laravel_postgres_setup -> php --version:\" && \
php --version && \
echo \"laravel_postgres_setup -> composer --version:\" && \
composer --version && \
git config --global --add safe.directory $WORKDIR && \
composer config --global process-timeout 600 && \

cd $WORKDIR/laravel-postgres-projects && \
composer create-project --prefer-dist \"laravel/laravel:13.7.0\" $APP_NAME && \

cd $WORKDIR/laravel-postgres-projects/$APP_NAME && \
echo \"laravel_postgres_setup -> php artisan --version:\" && \
php artisan --version
"
echo "$COMMAND_CREATE_LARAVEL_PROJECT"

docker compose exec app bash -lc "$COMMAND_CREATE_LARAVEL_PROJECT"

# echo "laravel_postgres_setup [3/4] Install dependencies..."

# COMMAND_INSTALL_DEPS="
#   cd $WORKDIR/laravel-postgres-projects/$APP_NAME &&
#   echo 'laravel_postgres_setup -> php artisan --version:' &&
#   php artisan --version
# "
# # &&
# # npm install -g npm@11.15.0 --no-fund --no-audit &&
# # echo 'laravel_postgres_setup -> npm --version:' &&
# # npm --version &&
# npm install --no-fund --no-audit
# # && npm run build
# echo "$COMMAND_INSTALL_DEPS"

# docker compose exec app bash -lc "$COMMAND_INSTALL_DEPS"

echo "laravel_postgres_setup [3/3] Post installation..."


COMMAND_POST_INSTALLATION="
cd $WORKDIR/laravel-postgres-projects/$APP_NAME && \
php artisan make:model Post -mcr && \
cat $WORKDIR/post-installation/database/migrations/create_posts_table.php > \"\$(find $WORKDIR/laravel-postgres-projects/$APP_NAME/database/migrations -name \"*create_posts_table.php\" | head -n 1)\" && \
php artisan migrate && \

cat $WORKDIR/post-installation/app/Models/Post.php > $WORKDIR/laravel-postgres-projects/$APP_NAME/app/Models/Post.php && \
cat $WORKDIR/post-installation/app/Http/Controllers/PostController.php > $WORKDIR/laravel-postgres-projects/$APP_NAME/app/Http/Controllers/PostController.php && \
cat $WORKDIR/post-installation/routes/web.php > $WORKDIR/laravel-postgres-projects/$APP_NAME/routes/web.php && \

mkdir -p $WORKDIR/laravel-postgres-projects/$APP_NAME/resources/views/posts && \
cat $WORKDIR/post-installation/resources/views/layout.blade.php > $WORKDIR/laravel-postgres-projects/$APP_NAME/resources/views/layout.blade.php && \
cat $WORKDIR/post-installation/resources/views/index.blade.php > $WORKDIR/laravel-postgres-projects/$APP_NAME/resources/views/index.blade.php && \

cat $WORKDIR/post-installation/resources/views/posts/index.blade.php > $WORKDIR/laravel-postgres-projects/$APP_NAME/resources/views/posts/index.blade.php && \
cat $WORKDIR/post-installation/resources/views/posts/create.blade.php > $WORKDIR/laravel-postgres-projects/$APP_NAME/resources/views/posts/create.blade.php && \
cat $WORKDIR/post-installation/resources/views/posts/edit.blade.php > $WORKDIR/laravel-postgres-projects/$APP_NAME/resources/views/posts/edit.blade.php && \
cat $WORKDIR/post-installation/resources/views/posts/show.blade.php > $WORKDIR/laravel-postgres-projects/$APP_NAME/resources/views/posts/show.blade.php
"
echo "$COMMAND_POST_INSTALLATION"

docker compose exec app bash -lc "$COMMAND_POST_INSTALLATION"

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

echo "laravel_postgres_setup DONE"
echo "laravel_postgres_setup Run:"
echo "sudo chown -R \$USER:\$USER laravel-postgres-projects/* && docker compose exec app bash -lc \"cd $WORKDIR/laravel-postgres-projects/$APP_NAME && php artisan serve --host=0.0.0.0 --port=8000\""