#!/bin/bash   

#set -eux

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y"`

################## Update below values ########################

echo "Please enter your database backup path"
read DB_BACKUP_PATH
#example DB_BACKUP_PATH='/home/rafael/scriptformysql'

echo "Please enter your MYSQL_HOST"
read MYSQL_HOST
#example MYSQL_HOST='localhost'

echo "Please enter your MYSQL_PORT"
read MYSQL_PORT
#MYSQL_PORT='3306'

echo "Please enter your MYSQL_USER"
read MYSQL_USER
#MYSQL_USER='mysqldump'

echo "Please enter your MYSQL_PASSWORD"
read -s MYSQL_PASSWORD
#MYSQL_PASSWORD='admin'

echo "Please enter your DATABASE_NAME"
read DATABASE_NAME
#DATABASE_NAME='test'
 
BACKUP_RETAIN_DAYS=30 ## Number of days to keep local backup copy

#################################################################

mkdir -p ${DB_BACKUP_PATH}/${TODAY}
echo "Backup started for database - ${DATABASE_NAME}"

mysqldump -h ${MYSQL_HOST} \
-P ${MYSQL_PORT} \
-u ${MYSQL_USER} \
-p${MYSQL_PASSWORD} \
${DATABASE_NAME} > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY} 

gzip ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}

if [ $? -eq 0 ]; then
echo "Database backup successfully completed"
else
echo "Error found during backup"
exit 1
fi

##### Remove backups older than {BACKUP_RETAIN_DAYS} days #####

#DBDELDATE=`date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`

#if [ ! -z ${DB_BACKUP_PATH} ]; then
#cd ${DB_BACKUP_PATH}
#if [ ! -z ${DBDELDATE} ] &amp;&amp; [ -d ${DBDELDATE} ]; then
#rm -rf ${DBDELDATE}
#fi
#fi

### End of script ####
