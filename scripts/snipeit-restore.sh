#!/bin/sh

aws s3 cp s3://backups.$DOMAIN/snipeit.zip ./snipeit.zip

docker cp ./snipeit.zip organize-me-snipeit:/var/www/html/storage/app/backups/snipeit.zip || exit 1

# Add missing directories
docker exec organize-me-snipeit mkdir -p /var/www/html/public/uploads/assets

docker exec organize-me-snipeit php artisan snipeit:restore /var/www/html/storage/app/backups/snipeit.zip --force || exit 1

docker exec organize-me-snipeit rm /var/www/html/storage/app/backups/snipeit.zip || exit 1
rm ./snipeit.zip

