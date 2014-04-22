#!/bin/bash
#
# packub - bash script for backing up websites and databases
# Author: Stanislav Fateev, 2014
# Email: fateevstas@yandex.ru
# WWW: svfat.ru
#
# requires bash version>=4 and rdiff-backup to run
# strongly recommended to run with superuser rights


#mysql user credentials
DBLOGIN="root"
DBPASSWORD="******************"

#directories (don't forget about slashes)
BACKUP_TO="/home/user/backup/"
DIR_PREFIX="/var/www/"
DIR_POSTFIX="/web/"

#declaring bash associative array as key:value pairs 'site':'database'
declare -A aa

#edit this
aa['yandex.ru']='yandex_database'
aa['google.com']='db_google'
# end of declaration

# test enviroment
if [ ! ${BASH_VERSION%%[^0-9]*} -ge 4 ];
then
         echo >&2 "I require bash version>=4  but it's not installed.  Aborting."
         exit 1
fi

command -v rdiff-backup >/dev/null 2>&1 || { echo >&2 "I require rdiff-backup but it's not installed.  Aborting."; exit 1; }


#check if backup directory is exists
if [ ! -d "$BACKUP_TO" ]; then
    mkdir $BACKUP_TO
        echo "Created directory $BACKUP_TO" 
fi


for site in "${!aa[@]}"
do
OUTPUT_DIR=$BACKUP_TO$site
INPUT_DIR=$DIR_PREFIX$site$DIR_POSTFIX
LOGFILE=$OUTPUT_DIR/$site.log
# check if directory we want to backup is exists
if [ -d "$INPUT_DIR" ]; then
    # check if output directory is exists - if not, create it
    if [ ! -d "$OUTPUT_DIR" ]; then
        mkdir $OUTPUT_DIR
        echo "Created directory $OUTPUT_DIR" | tee -a $LOGFILE
    fi
    
    #make incremental backup and log
    echo $'\n\n' >> $LOGFILE
    echo "Starting backup for $site. Wait please." | tee -a $LOGFILE
    database=${aa[$site]}
    databasefile=$INPUT_DIR$database.sql
    echo "Dumping database in $databasefile" | tee -a $LOGFILE
    mysqldump -u$DBLOGIN -p$DBPASSWORD $database -v --single-transaction 2>&1 1>$databasefile | tee -a $LOGFILE
    rdiff-backup --print-statistics $INPUT_DIR $OUTPUT_DIR$DIR_POSTFIX 2>&1 | tee -a $LOGFILE
else
# no input directory
    echo "Directory $INPUT_DIR not found. Skipping." 
fi
done
