FROM php:8.5.6-cli

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    libzip-dev \
    libpq-dev

RUN docker-php-ext-install \
    zip \
    pdo_pgsql \
    pgsql

COPY --from=composer/composer:2.9.8-bin /composer /usr/bin/composer

COPY --from=node:26.1.0 /usr/local/bin /usr/local/bin
COPY --from=node:26.1.0 /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/bin/npm
RUN ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/bin/npx

WORKDIR /workspace

CMD ["bash"]