#!/bin/bash -xe
# Script to cleanup tmp and cache between updates (rebuilds)

echo "Cleaning up OpenHab temporary files"

rm -rf {{ pillar.openhab.data_dir }}/userdata/cache/*
rm -rf {{ pillar.openhab.data_dir }}/userdata/tmp/*
