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
    export MYSQL_PASSWORD=$(aws ssm get-parameter --with-decryption --name organize-me.mysql_password | jq -r ".Parameter.Value");
    if [ -z "$MYSQL_PASSWORD" ]; then exit 1; fi
fi


export BACKUP_NAME=wikijs
export BACKUP_BAK=database.bak
export BACKUP_ZIP=$BACKUP_NAME.zip

# Dump database to file
mysqldump --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD wikijs > $BACKUP_BAK
if [ $? -ne 0 ]; then exit 1; fi

# Zip file
zip $BACKUP_ZIP $BACKUP_BAK || exit 1

# Save zip to s3
aws s3 cp $BACKUP_ZIP s3://backups.$DOMAIN/$BACKUP_ZIP || exit 1

# Cleanup
rm $BACKUP_BAK
rm $BACKUP_ZIP
