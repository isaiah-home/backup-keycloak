# Backups
This defines the backup/restore processes.

# Notes
 * Backups are saved off-site in an AWS S3 bucket
 * It's assumed all scripts are in the user's bin folder: ```~/bin/```

# Cron Setup
Cron jobs are setup for nightly backups.

Edit the crontab file
```
crontab -e
```

Add the following jobs
```
00 2 * * * . bin/env.sh; bin/keycloak-backup.sh >> logs/keycloak.log 2>&1
10 2 * * * . bin/env.sh; bin/wikijs-backup.sh >> logs/wikijs.log 2>&1
20 2 * * * . bin/env.sh; bin/nextcloud-backup.sh >> logs/nextcloud.log 2>&1
30 2 * * * . bin/env.sh; bin/snipeit-backup.sh >> logs/snipeit.log 2>&1
```

# Restores
Restoring is a simple as calling the restore script for the target service.
