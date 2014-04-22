Packub
======

packub - bash script for incremental backing up websites and databases

This is a wrapper for rdiff-backup and mysqldump. Useful for backing up multiple sites which located on server with directory structure as:
/var/www/site1.com/web; /var/www/site2.com/web; etc. 
For example - ISPConfig3 default directory structure.

Also backing up mysql databases dump for each site.

Implemented simple logging functions.

Requirements
============
- rdiff-backup
- bash version 4+

Usage
=====

- Edit variables in the start of file.
- Add `aa['example.com]='example_database'` string for each site you want to backup.
- I recommend to run it with superuser rights and using mysql root user password.
- Run `packub.sh`

For more information about backups: `man rdiff-backup`
