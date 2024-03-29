
# Database backup script documentation 

Bash script is to backup MySQL database with compressed version.The script allows you to compress files in 4 ways (gzip,bzip2,xz,lzma).Find out which type of compression suits you best and use that option.Script would also free up storage space by removing backups older then 30 days.
Based on your choice our script allows to synchronize your database backup folder from local server to AWS S3 bucket .
You can also remove old files and objects from the specified AWS S3 bucket (Selected files older than your provided date will be deleted).

### To start compressing and backup the database you must specify a few information shown below after running script

+ MYSQL_HOST - (Example - "localhost") 
+ MYSQL_USER (Example - "james" ) 
+ MYSQL_PASSWORD (Example - "mysqlpass" ) 
+ DB_BACKUP_PATH - database backup folder where you want to save compressed files (Example - "/home/james/databasebackups/" )
+ DATABASE_NAME - the name of the database you want to backup (Example database name - "Users" )
+ COMPRESSION_TYPE - (Example - "gzip" )

### To synchronize data between backup folder in local server and AWS S3 you must specify a few information shown below 

+ AWS_S3_BUCKET_NAME - (Example - "database.backups.aws.s3" )
+ AWS_USERNAME - (Example - "admin999" )
+ AWS Access Key ID
+ AWS Secret Access Key  
+ AWS Region - (Example - "eu-central-1")
+ BACKUP_DELDATE_FROM_AWS - (Example - "7" )

> Keep in mind that you must have the necessary acceses in
> + mysql server.
> + local server folder where you want to create your database backup files.
> + already created AWS user and S3 bucket (also you need AWS CLI v2).
