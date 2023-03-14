#!/bin/bash

# Clone Shopware local to live
# description Shopware 6 sync from MacOS local to live Linux server env

## Clone Shopware ####################################################################################

# Define your local and remote directories

SRC='/Users/mac/Sites/foo.com/'
DST='user@foo.com:/home/www/shopware6/'

# use rsync (note: RSYNC on mac may is not same like on debian i.e. -exclude option)
# Use with -n or --dry-run option to simulate

rsync -azh -r --delete \
     --progress \
     --exclude var/log/ \
	   --exclude var/cache/ \
	   --exclude .htaccess \
	   --exclude .robots.txt \
	   --exclude .php.ini \
	   --exclude .env \
	   --exclude *.DS_Store \
	 $SRC $DST
   
## Dump local MySQL ##################################################################################

# Important
# Check .sql dump for DEFINER=`user`@`localhost`. It MUST be eligable user at your target platfrom.
# Else you'll may see ERROR 1227 (42000) at line 988: Access denied; you need (at least one of) the SUPER privilege(s) for this operation


DB_HOST=localhost
DB_USER=shopwareUser
DB_PASSWORD=''

mysqldump -h $DB_HOST -u$DB_USER -p$DB_PASSWORD --no-tablespaces shopware6| gzip > ../shopware6.sql.gz

# Some MacOS local enviroments may require full path. Example
/Applications/MAMP/Library/bin/mysqldump --user=$DB_USER --password=$DB_PASSWORD shopware6 | gzip > /Users/mac/Sites/shopware6.sql.gz

## Import local MySQL to Server  ######################################################################

# replace db_shopware6 with your target db on live enviroment

# sql with gzip compression
gunzip -c shopware6.sql.gz | -h $DB_HOST -u$DB_USER -p$DB_PASSWORD db_shopware6

# sql no compression
mysql -h $DB_HOST -u$DB_USER -p$DB_PASSWORD db_shopware6 < shopware6.sql

## Config .htaccess ###################################################################################

#  Some hosting requiring disabling -MultiViews, else Error 404
# Enter your root path and copy paste to command line
DIR_ROOT=/home/www/shopware6/
find $DIR_ROOT -type f -name .htaccess

## Config .env ########################################################################################

# shopware .env file with server enviroment credentials
DIR_ROOT=/home/www/shopware6/
nano $DIR_ROOT.env

## Update Shopware 6 Domains ##########################################################################

# Even you can do it with Symfony / Shopware 6 bin/console command. Sometime you can enter direct to db table.
mysql -u$DB_USER -p$DB_PASSWORD;
USE shopware6
UPDATE sales_channel_domain SET url='http://foo.com.local' WHERE url='http://foo.com';
UPDATE sales_channel_domain SET url='https://foo.com.local' WHERE url='https://foo.com';

## Clear Shopware Caches ##############################################################################

cd $DIR_ROOT
bin/console cache:clear

