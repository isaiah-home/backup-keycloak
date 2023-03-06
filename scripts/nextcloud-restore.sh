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
export BACKUP_ZIP=$DATABASE_NAME.v25.zip

# Pull restore file
aws s3 cp s3://organize-me.$DOMAIN.backups/$BACKUP_ZIP $BACKUP_ZIP || exit 1

# Unzip restore file
unzip $BACKUP_ZIP || exit 1

# Restore database
mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD --database=$DATABASE_NAME < database.bak
if [ $? -ne 0 ]; then exit 1; fi

# Copy config and update privileges
docker exec organize-me-nextcloud rm -rf /var/www/html/data/config || exit 1
docker cp files/config/ organize-me-nextcloud:/var/www/html/ || exit 1
docker exec organize-me-nextcloud chgrp -R root /var/www/html/config || exit 1
docker exec organize-me-nextcloud chown -R www-data /var/www/html/config || exit 1

# Replace data and update privileges
docker exec organize-me-nextcloud rm -rf /var/www/html/data || exit 1
docker cp files/data/ organize-me-nextcloud:/var/www/html/ || exit 1
docker exec organize-me-nextcloud chgrp -R root /var/www/html/data || exit 1
docker exec organize-me-nextcloud chown -R www-data /var/www/html/data || exit 1

# Replace themes and update privileges
docker exec organize-me-nextcloud rm -rf /var/www/html/themes || exit 1
docker cp files/themes/ organize-me-nextcloud:/var/www/html/ || exit 1
docker exec organize-me-nextcloud chgrp -R root /var/www/html/themes || exit 1
docker exec organize-me-nextcloud chown -R www-data /var/www/html/themes || exit 1


# Cleanup
rm database.bak
rm -rf files
rm $BACKUP_ZIP

# Maintenace Mode OFF
docker exec --user www-data organize-me-nextcloud php occ maintenance:mode --off
