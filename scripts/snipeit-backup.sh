#!/bin/sh

docker exec organize-me-snipeit php artisan snipeit:backup || exit 1
docker cp organize-me-snipeit:/var/www/html/storage/app/backups/ . || exit 1

export BACKUP_ZIP=$(ls -t backups/snipe-it*.zip | head -1 | sed 's#^backups/##')

aws s3 cp ./backups/$BACKUP_ZIP s3://backups.$DOMAIN/snipeit.zip || exit 1

docker exec organize-me-snipeit rm /var/www/html/storage/app/backups/$BACKUP_ZIP || exit 1
rm -rf ./backups
