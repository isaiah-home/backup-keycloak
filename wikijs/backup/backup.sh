#!/bin/sh

if [ -z ${MYSQL_HOST+x} ]; then echo "MYSQL_HOST not set"; exit 1; fi
if [ -z ${MYSQL_PORT+x} ]; then echo "MYSQL_PORT not set"; exit 1; fi
if [ -z ${MYSQL_USERNAME+x} ]; then echo "MYSQL_USERNAME not set"; exit 1; fi
if [ -z ${MYSQL_PASSWORD+x} ]; then echo "MYSQL_PASSWORD not set"; exit 1; fi

if [ -z ${AWS_ACCESS_KEY_ID+x} ]; then echo "AWS_ACCESS_KEY_ID not set"; exit 1; fi
if [ -z ${AWS_SECRET_ACCESS_KEY+x} ]; then echo "AWS_SECRET_ACCESS_KEY not set"; exit 1; fi
if [ -z ${AWS_DEFAULT_REGION+x} ]; then echo "AWS_DEFAULT_REGION not set"; exit 1; fi

export BACKUP_NAME=wikijs
export BACKUP_BAK=$BACKUP_NAME.bak
export BACKUP_ZIP=$BACKUP_NAME-$(date +'%Y-%m-%dT%H:%M:%S%z').zip

# Dump database to file
(mysqldump --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD wikijs || exit 1) > $BACKUP_BAK

# Zip file
zip $BACKUP_ZIP $BACKUP_BAK || exit 1

# Save zip to s3
aws s3 cp $BACKUP_ZIP s3://backups.ivcode.org/wikijs/$BACKUP_ZIP || exit 1

# Cleanup
rm $BACKUP_BAK
rm $BACKUP_ZIP
