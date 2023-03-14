#!/bin/bash

## check enviorment

# PHP for Magento 1, Magento 2, Shopware 5, Shopware 6, Drupal 8

which php
php -v
php -m # installierte module
php -m | grep ".*cache.*"
php -r "echo ini_get('memory_limit').PHP_EOL;"

# find the logs may 

# search from system root
cd /
find /  -type f -iregex '.*\.log'

# show log folder from list
ls -alht | grep ".*log.*"

# find logs changed last day
find / -type f -mtime -1 -path '*.log' -or -path '*_log'

# modified last 12hr
find / -type f -mmin -720 -path '*.log' -or -path '*_log'

# HTTP Server log by time variable
# check if format is correct
echo $(date +"%Y%m%d-access.log")
# monitor server log of current day
tail -f  /log/$(date +"%Y%m%d-access.log")

# Shopware 6
# Monitor API Access
tail -f  /log/$(date +"%Y%m%d-access.log") | grep -i ".*/api/search/order.*"
tail -f  /log/$(date +"%Y%m%d-access.log") | grep -i ".*/api/.*"

# Error 500
# check htaccess files
DIR_APP=/home/www/shopware6
find $DIR_APP -type f -name .htaccess

# Server space
# some errors occure because low memory and server disk space
DIR_APP=/home/www/magento2
du -c -h -d 0 $DIR_APP
