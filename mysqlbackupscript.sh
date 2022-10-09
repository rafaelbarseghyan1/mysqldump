#!/bin/bash

#set -eux

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y"` 
BACKUP_RETAIN_DAYS=30 ## Number of days to keep local backup copy

Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
NC='\033[0m'              # No Color

################## MYSQL autentification sector ########################

echo "Please enter your MYSQL_HOST"
read MYSQL_HOST
#MYSQL_HOST='localhost'

#echo "Please enter your MYSQL_PORT"
#read  MYSQL_PORT
MYSQL_PORT='3306'

echo "Please enter your MYSQL_USER"
read MYSQL_USER
#MYSQL_USER='mysqldump'

echo "Please enter your MYSQL_PASSWORD"
read -s MYSQL_PASSWORD
#MYSQL_PASSWORD='admin'

mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "show databases" &> /dev/null
if [ $? -eq 0 ]; then 
printf "${Green}MYSQL login is successful${NC}\n"
else 
printf "${Red}MySQL authentication faild${NC}\n"
exit 1 
fi

################## database found or not #################################

echo "Please enter your DATABASE_NAME"
read DATABASE_NAME
#DATABASE_NAME='test'

if [ ! -z ${DATABASE_NAME} ]; then
mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "use ${DATABASE_NAME}" &> /dev/null
elif [ $? -eq 0 ]; then 
printf "${Green}Database successfully found${NC}\n"
else 
printf "${Red}Specified database not found${NC}\n"
exit 1 
fi

########################################################################

echo "Please enter your database backup folder"
read DB_BACKUP_PATH
#example DB_BACKUP_PATH='/home/rafael/scriptformysql'

mkdir -p ${DB_BACKUP_PATH}/${TODAY} &> /dev/null

if [ $? -eq 0 ]; then
echo sarqvav > /dev/null 
else
printf "${Red}Syntax error when entering path or you don't have permission create directory at the specified location${NC}\n"
exit 1
fi

########################################################################

echo "Enter your preferred compression type. Possible options | gzip | bzip2 | xz | lzma |"
read COMPRESSION_TYPE
#COMPRESSION_TYPE='gzip'

if [ $COMPRESSION_TYPE == "gzip" ] || [ $COMPRESSION_TYPE == "bzip2" ] 
then
printf "${Green}Backup started for database${NC}\n"
elif [ $COMPRESSION_TYPE == "xz" ] || [ $COMPRESSION_TYPE == "lzma" ] 
then 
printf "${Green}Backup started for database${NC}\n"
else
echo "${Red}There is an error when entering compression type{NC}\n"
exit 1
fi

################################################################

mysqldump -h ${MYSQL_HOST} \
-P ${MYSQL_PORT} \
-u ${MYSQL_USER} \
-p${MYSQL_PASSWORD} \
${DATABASE_NAME} > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY} 2> /dev/null

${COMPRESSION_TYPE} ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}

if [ $? -eq 0 ]; then
printf "${Green}Database backup successfully completed${NC}\n"
else 
printf "${Red}Error found during backup${NC}\n"
exit 1
fi

##### Remove backups older than {BACKUP_RETAIN_DAYS} days #####

DBDELDATE=`date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`

rm -rf ${DB_BACKUP_PATH}/${DBDELDATE}

### End of script ####
