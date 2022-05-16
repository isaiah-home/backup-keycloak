#!/bin/sh

if [ -z ${1+x} ]; then echo "s3 restore file not defined"; exit 1; fi

if [ -z ${MYSQL_HOST+x} ]; then echo "MYSQL_HOST not set"; exit 1; fi
if [ -z ${MYSQL_PORT+x} ]; then echo "MYSQL_PORT not set"; exit 1; fi
if [ -z ${MYSQL_USERNAME+x} ]; then echo "MYSQL_USERNAME not set"; exit 1; fi
if [ -z ${MYSQL_PASSWORD+x} ]; then echo "MYSQL_PASSWORD not set"; exit 1; fi

if [ -z ${AWS_ACCESS_KEY_ID+x} ]; then echo "AWS_ACCESS_KEY_ID not set"; exit 1; fi
if [ -z ${AWS_SECRET_ACCESS_KEY+x} ]; then echo "AWS_SECRET_ACCESS_KEY not set"; exit 1; fi
if [ -z ${AWS_DEFAULT_REGION+x} ]; then echo "AWS_DEFAULT_REGION not set"; exit 1; fi

# Pull restore file
aws s3 cp s3://backups.ivcode.org/wikijs/$1 $1 || exit 1

# Unzip restore file
unzip $1 || exit 1

# Restore database
mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD --database=wikijs < wikijs.bak

#Cleanup
rm wikijs.bak
rm $1
