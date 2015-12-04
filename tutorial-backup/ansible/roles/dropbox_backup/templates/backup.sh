#!/bin/bash

hostname=`hostname | awk -F. '{print $1}'`
date=$(date +"%d-%m-%Y")
database="{{datasource.dbname}}"
uncompressed_backup_db_file="{{dropbox_backup.directory}}/${database}.sql"
backup_db="/tmp/${hostname}-${date}.sql.tar.gz"
backup_dirs="{{dropbox_backup.directory}}"
backup_filename="/tmp/${hostname}-${date}.tar.gz"
dropbox_uploader="{{dropbox_backup.uploader_script_folder}}/dropbox_uploader.sh -f "{{dropbox_backup.configuration_folder}}"/.dropbox_uploader"

echo "[$(date +"%d-%m-%Y-%T")] Database dump..."
sudo -u postgres pg_dump $database > $uncompressed_backup_db_file

echo "\n[$(date +"%d-%m-%Y-%T")] Compress data..."
tar -czvf $backup_filename $backup_dirs

# Send to Dropbox
echo "\n[$(date +"%d-%m-%Y-%T")] Upload to dropbox..."
$dropbox_uploader upload $backup_filename /

# Delete local backup
sudo rm $uncompressed_backup_db_file
sudo rm -rf $backup_filename
sudo rm -rf $backup_db

# Delete old remote backups
echo "\n[$(date +"%d-%m-%Y-%T")] Delete old remote backups..."
delete_date=`date --date="-{{dropbox_backup.days_to_keep}} day" +%d-%m-%Y`
$dropbox_uploader delete "${hostname}-${delete_date}.tar.gz"
