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

# Maintenace Mode On
docker exec --user www-data nextcloud php occ maintenance:mode --on

# Pull restore file
aws s3 cp s3://backups.ivcode.org/nextcloud.zip nextcloud.zip || exit 1

# Unzip restore file
unzip nextcloud.zip || exit 1

# Restore database
mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD --database=nextcloud < database.bak

# Copy config and update privileges
docker exec nextcloud rm -rf /var/www/html/data/config || exit 1
docker cp files/config/ nextcloud:/var/www/html/ || exit 1
docker exec nextcloud chgrp -R root /var/www/html/config || exit 1
docker exec nextcloud chown -R www-data /var/www/html/config || exit 1

# Replace data and update privileges
docker exec nextcloud rm -rf /var/www/html/data || exit 1
docker cp files/data/ nextcloud:/var/www/html/ || exit 1
docker exec nextcloud chgrp -R root /var/www/html/data || exit 1
docker exec nextcloud chown -R www-data /var/www/html/data || exit 1

# Replace themes and update privileges
docker exec nextcloud rm -rf /var/www/html/themes || exit 1
docker cp files/themes/ nextcloud:/var/www/html/ || exit 1
docker exec nextcloud chgrp -R root /var/www/html/themes || exit 1
docker exec nextcloud chown -R www-data /var/www/html/themes || exit 1


# Cleanup
rm database.bak
rm -rf files
rm nextcloud.zip

# Maintenace Mode OFF
docker exec --user www-data nextcloud php occ maintenance:mode --off
