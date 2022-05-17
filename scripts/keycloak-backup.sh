#!/bin/sh

if [ -z ${MYSQL_HOST+x} ]; then
    export MYSQL_HOST=127.0.01;
fi
if [ -z ${MYSQL_PORT+x} ]; then
    export MYSQL_PORT=3306;
fi
if [ -z ${MYSQL_USERNAME+x} ]; then
    export MYSQL_USERNAME=root;
fi
if [ -z ${MYSQL_PASSWORD+x} ]; then
    export MYSQL_PASSWORD=$(aws ssm get-parameter --with-decryption --name isaiah-home.mysql_password | jq -r ".Parameter.Value");
fi


if [ -z ${AWS_ACCESS_KEY_ID+x} ]; then
    echo "AWS_ACCESS_KEY_ID not set";
    exit 1;
fi
if [ -z ${AWS_SECRET_ACCESS_KEY+x} ]; then
    echo "AWS_SECRET_ACCESS_KEY not set";
    exit 1;
fi
if [ -z ${AWS_DEFAULT_REGION+x} ]; then
    echo "AWS_DEFAULT_REGION not set";
    exit 1;
fi


export BACKUP_NAME=keycloak
export BACKUP_BAK=database.bak
export BACKUP_ZIP=$BACKUP_NAME.zip

# Dump database to file
(mysqldump --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD keycloak || exit 1) > $BACKUP_BAK

# Zip file
zip $BACKUP_ZIP $BACKUP_BAK || exit 1

# Save zip to s3
aws s3 cp $BACKUP_ZIP s3://backups.ivcode.org/$BACKUP_ZIP || exit 1

# Cleanup
rm $BACKUP_BAK
rm $BACKUP_ZIP
