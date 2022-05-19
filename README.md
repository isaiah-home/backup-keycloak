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
00 2 * * * BASH_ENV=bin/env.sh bin/keycloak-backup.sh
10 2 * * * BASH_ENV=bin/env.sh bin/wikijs-backup.sh
20 2 * * * BASH_ENV=bin/env.sh bin/nextcloud-backup.sh
```

# Restores
Restoring is a simple as calling the restore script for the target service.
