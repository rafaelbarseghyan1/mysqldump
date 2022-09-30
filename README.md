Bash script to backup MySQL database to local drive with compressed version.
Script would also free up storage space by removing backups older then 30 days.
The script allows you to compress files in 4 ways (gzip,bzip2,xz,lzma).
Find out which type of compression suits you best and use that option.

To start compressing and backup the databases you need, you must specify a few information shown below after running script`

MYSQL_HOST - (Example - localhost)
MYSQL_USER   (Example - james)
MYSQL_PASSWORD (Example - mysqlpass)

DB_BACKUP_PATH - database backup folder where you want to save compressed files (Example - /home/james/databasebackups/)
DATABASE_NAME - the name of the database you want to compress (Example database name - Users)


*keep in mind that you must have the necessary access to both the mysql server and the folder where you want to create your database backup files.
