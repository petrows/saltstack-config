ARG version
FROM php:$version-fpm

RUN apt-get update && apt-get install --no-install-recommends -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libzip-dev \
        libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd zip intl mysqli exif

RUN apt-get update && apt-get install --no-install-recommends -y \
        libmagickwand-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick
