#!/bin/bash -xe

docker build -t petrows/saltstack:php-fpm-7.4 --build-arg version=7.4 -f php.dockerfile .
docker build -t petrows/saltstack:php-fpm-8.1 --build-arg version=8.1 -f php.dockerfile .


docker push petrows/saltstack:php-fpm-7.4
docker push petrows/saltstack:php-fpm-8.1
