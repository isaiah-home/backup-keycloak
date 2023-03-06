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

export DATABASE_NAME=vaultwarden
export BACKUP_ZIP=$DATABASE_NAME.zip

#stop the container
docker stop organize-me-vaultwarden

# Dump database to file
mysqldump --host=$MYSQL_HOST --port=$MYSQL_PORT --user=$MYSQL_USERNAME --password=$MYSQL_PASSWORD $DATABASE_NAME > database.bak
if [ $? -ne 0 ]; then exit 1; fi

# Copy data files
docker cp organize-me-vaultwarden:/data/ ./ || exit 1

# Zip file
zip -r $BACKUP_ZIP database.bak data || exit 1

# Save zip to s3
aws s3 cp $BACKUP_ZIP s3://organize-me.$DOMAIN.backups/$BACKUP_ZIP || exit 1

# Cleanup
rm database.bak
rm $BACKUP_ZIP
rm -rf data

#start the container
docker start organize-me-vaultwarden
