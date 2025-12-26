#!/bin/bash -xe

VERSION=$(date +"%Y-%m-%d")

# docker build \
#     -t petrows/saltstack:php-fpm-7.4 \
#     -t petrows/saltstack:php-fpm-7.4-$VERSION \
#     --build-arg version=7.4 -f php.dockerfile .
# docker build \
#     -t petrows/saltstack:php-fpm-8.1 \
#     -t petrows/saltstack:php-fpm-8.1-$VERSION \
#     --build-arg version=8.1 -f php.dockerfile .
docker build \
    --progress=plain \
    -t petrows/saltstack:php-fpm-8.5 \
    -t petrows/saltstack:php-fpm-8.5-$VERSION \
    --build-arg version=8.5 -f php.dockerfile .


# docker push petrows/saltstack:php-fpm-7.4
# docker push petrows/saltstack:php-fpm-7.4-$VERSION
# docker push petrows/saltstack:php-fpm-8.1
# docker push petrows/saltstack:php-fpm-8.1-$VERSION
docker push petrows/saltstack:php-fpm-8.5
docker push petrows/saltstack:php-fpm-8.5-$VERSION
