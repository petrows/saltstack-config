ARG version
FROM php:$version-fpm

RUN apt-get update && apt-get install --no-install-recommends -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libicu-dev \
        git \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip intl mysqli exif pdo pdo_mysql

RUN apt-get update && apt-get install --no-install-recommends -y \
        libmagickwand-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# Video management
RUN apt-get update && apt-get install --no-install-recommends -y \
        ffmpeg

# Compat with some scripts
RUN ln -s /usr/local/bin/php /usr/bin/php
