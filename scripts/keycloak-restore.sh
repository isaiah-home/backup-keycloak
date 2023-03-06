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

docker stop organize-me-keycloak || exit 1

# Pull restore file
aws s3 cp s3://organize-me.$DOMAIN.backups/keycloak.zip keycloak.zip || exit 1

# Unzip restore file
unzip keycloak.zip || exit 1

# Restore database
mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD --database=keycloak < database.bak
if [ $? -ne 0 ]; then exit 1; fi

#Cleanup
rm database.bak
rm keycloak.zip

docker start organize-me-keycloak
