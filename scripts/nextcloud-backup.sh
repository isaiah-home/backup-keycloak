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


# Maintenace Mode On
docker exec --user www-data organize-me-nextcloud php occ maintenance:mode --on || exit 1

export DATABASE_NAME=nextcloud
export BACKUP_ZIP=$DATABASE_NAME.zip

# Dump database to file
mysqldump --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD $DATABASE_NAME > database.bak
if [ $? -ne 0 ]; then exit 1; fi

# Copy data files from container
mkdir files
docker cp organize-me-nextcloud:/var/www/html/config/ files/config/ || exit 1
docker cp organize-me-nextcloud:/var/www/html/data/ files/data/ || exit 1
docker cp organize-me-nextcloud:/var/www/html/themes/ files/themes/ || exit 1

# Zip file
zip -r $BACKUP_ZIP database.bak files || exit 1

# Save zip to s3
aws s3 cp $BACKUP_ZIP s3://backups.$DOMAIN/$BACKUP_ZIP || exit 1

# Cleanup
rm database.bak
rm $BACKUP_ZIP
rm -rf files

# Maintenace Mode On
docker exec --user www-data organize-me-nextcloud php occ maintenance:mode --off
