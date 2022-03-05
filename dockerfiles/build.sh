#!/bin/bash

docker build -t petrows/saltstack:php-fpm-7.4 --build-arg version=7.4 -f php.dockerfile .


docker push petrows/saltstack:php-fpm-7.4
