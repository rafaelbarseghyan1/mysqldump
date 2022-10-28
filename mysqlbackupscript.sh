#!/bin/bash

#set -eux

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=`date +"%d%b%Y"` 
MYSQL_PORT='3306'


Red='\033[0;31m'          # Red Color
Green='\033[0;32m'        # Green Color
NC='\033[0m'              # No Color

#################################################################################
######################      MYSQL AUTENTIFICATION      ##########################
#################################################################################

read -p "Please enter your MYSQL_HOST: " MYSQL_HOST
read -p "Please enter your MYSQL_USER: " MYSQL_USER
read -s -p "Please enter your MYSQL_PASSWORD: " MYSQL_PASSWORD

mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "show databases" &> /dev/null

if [ $? -eq 0 ]; then 
printf "\n${Green}MYSQL login is successful${NC}\n"
else 
printf "\n${Red}MySQL authentication faild${NC}\n"
exit 1 
fi

#################################################################################
##################     DATABASE INDENTIFICATION     #############################
#################################################################################

read -p "Please enter your DATABASE_NAME: " DATABASE_NAME

if [ ! -z ${DATABASE_NAME} ]; then
mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD} -e "use ${DATABASE_NAME}" &> /dev/null
else
printf "${Red}Specified database not found${NC}\n"
exit 1
fi

if [ $? -eq 0 ]; then 
printf "${Green}Database successfully found${NC}\n"
else 
printf "${Red}Specified database not found${NC}\n"
exit 1 
fi


#################################################################################
#############     CHOICE OF BACKUP FOLDER IN LOCAL SERVER     ###################
#################################################################################

read -p "Please enter your database backup folder: " DB_BACKUP_PATH
mkdir -p ${DB_BACKUP_PATH}/${TODAY}  &> /dev/null

if [ $? -eq 0 ]; then
echo "mkdirdone" > /dev/null 
else
printf "${Red}Syntax error when entering path or you don't have permission create directory at the specified location${NC}\n"
exit 1
fi

#################################################################################
####################     CHOICE OF METHOD COMPRESSION     #######################
#################################################################################

read -p "Enter your preferred compression type. Possible options ( gzip | bzip2 | xz | lzma ):  " COMPRESSION_TYPE

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


#################################################################################
#################     DATABASE BACKUP IN LOCAL SERVER     #######################
#################################################################################

mysqldump -h ${MYSQL_HOST} \
-P ${MYSQL_PORT} \
-u ${MYSQL_USER} \
-p${MYSQL_PASSWORD} \
${DATABASE_NAME} > ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.sql 2> /dev/null

${COMPRESSION_TYPE} ${DB_BACKUP_PATH}/${TODAY}/${DATABASE_NAME}-${TODAY}.sql

if [ $? -eq 0 ]; then
printf "${Green}Database backup successfully completed${NC}\n"
else 
printf "${Red}Error found during backup${NC}\n"
exit 1
fi

############## Remove backups older than {BACKUP_RETAIN_DAYS} days #############

#find ${DB_BACKUP_PATH}/* -mtime +30 -delete

BACKUP_RETAIN_DAYS=30 ## Number of days to keep local backup copy
DBDELDATE=`date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago"`
rm -rf ${DB_BACKUP_PATH}/${DBDELDATE}

#################################################################################
####################     DATABASE BACKUP IN AWS S3     ##########################
#################################################################################

while true
do
      read -r -p "Do you want to store your database backup in an AWS s3 bucket? [Y/n] " input

      case $input in
            [yY][eE][sS]|[yY])
            #      echo "Yes"
                  break
                  ;;
            [nN][oO]|[nN])
                  echo "Bye :)"
                  exit 1
                  break
                  ;;
            *)
                  echo "Invalid input..."
                  ;;
      esac
done

echo "Please enter your AWS S3 bucket name"
read BUCKET_NAME

echo "Please enter your AWS Profile username"
read PROFILE_NAME


aws configure --profile ${PROFILE_NAME}
aws s3 sync ${DB_BACKUP_PATH} s3://${BUCKET_NAME}


if [ $? -eq 0 ]; then
printf "${Green}Database backup successfully synch with AWS S3${NC}\n"
else
printf "${Red}Error found during synch backup in AWS S3${NC}\n"
exit 1
fi

################################################################################
################     DELETING OLD OBJECTS FROM AWS S3     ######################
################################################################################

echo "How many days of old age files to delete from AWS S3?"
read OBJECT_DEL

aws s3 ls ${BUCKET_NAME} --recursive | while read -r line;  do

createDate=`echo $line|awk {'print $1" "$2'}`
createDate=`date -d"$createDate" +%s`
olderThan=`date -d"-$OBJECT_DEL days" +%s`
if [[ $createDate -lt $olderThan ]]
  then
    fileName=`echo $line|awk {'print $4'}`
    echo $fileName
    if [[ $fileName != "" ]]
      then
        aws s3 rm "s3://${BUCKET_NAME}/$fileName"
    fi
fi
done;

################################################################################
########################     END OF SCRIPT     #################################
################################################################################
