# backups
Keycloak Backup Process


# Cron Jobs
Cron jobs are setup for nightly backups.

Edit the crontab file
```
crontab –e
```

Add the following jobs
```
00 2 * * * bin/keycloak-backup.sh
10 2 * * * bin/wikijs-backup.sh
20 2 * * * bin/wikijs-backup.sh
20 2 * * * nextcloud-backup.sh
```
