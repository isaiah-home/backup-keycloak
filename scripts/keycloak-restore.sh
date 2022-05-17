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

docker stop keycloak

# Pull restore file
aws s3 cp s3://backups.ivcode.org/keycloak.zip keycloak.zip || exit 1

# Unzip restore file
unzip keycloak.zip || exit 1

# Restore database
mysql --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD --database=keycloak < database.bak

#Cleanup
rm database.bak
rm keycloak.zip

docker start keycloak
