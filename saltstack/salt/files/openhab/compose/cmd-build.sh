#!/bin/bash -xe
# Script to cleanup tmp and cache between updates (rebuilds)

echo "Cleaning up OpenHab temporary files"

rm -rf {{ pillar.openhab.data_dir }}/userdata/cache/*
rm -rf {{ pillar.openhab.data_dir }}/userdata/tmp/*

echo "Cleaning up OpenHab backups"
find {{ pillar.openhab.data_dir }}/userdata/backup -type f -mtime +30 -delete
