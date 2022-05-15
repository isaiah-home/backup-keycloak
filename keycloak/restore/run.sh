#/bin/sh

# Useage:
#  ./run <S3-Backup-File-Name>
#
# Example:
#  ./run 'keycloak-2022-05-15T10:46:48-0700.zip'
#

# Stop Keycloak
docker stop keycloak

# Restore
docker run \
    --rm \
    --network home_network \
    -e MYSQL_HOST=mysql \
    -e MYSQL_PORT=3306 \
    -e MYSQL_USERNAME=root \
    -e MYSQL_PASSWORD \
    -e AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY \
    -e AWS_DEFAULT_REGION \
    isaiah-home/keycloak-restore $1

# Start Keycloak
docker start keycloak
