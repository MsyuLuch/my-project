#! /bin/bash

sayWait()
{
   local AMSURE
   [ -n "$1" ] && echo "$@" 1>&2
   read -n 1 -p "(нажмите любую клавишу для продолжения)" AMSURE
   echo "" 1>&2
}

HOME_DIR="/root"
BACKUP_DIR="/var/backup/mysql"
IP_MASTER="185.177.92.60"
BIN_LOG="binlog.000002"
POS_LOG="915"

# Only root can execute this script
USER_ID="$(id -u)"
if [[ ${USER_ID} -ne 0 ]]; then
    echo  "Only root can execute this script."
    exit 1
fi

############## MYSQL ###########################
echo "установливаем mysql"
yum install mysql-server

systemctl start mysqld && systemctl status mysqld && systemctl enable mysqld

mysql_secure_installation

cp  $HOME_DIR/my-project/mysql/repl/* /etc/my.cnf.d/
cp  $HOME_DIR/my-project/mysql/.my.cnf /root/

service mysqld restart && systemctl status mysqld
sayWait

mysql --force < $HOME_DIR/my-project/dump-data.sql
mysql -e "show databases;"
sayWait

mysql -e "CHANGE MASTER TO MASTER_HOST='$IP_MASTER', MASTER_USER='repl', MASTER_PASSWORD='oTUSlave#2020', MASTER_LOG_FILE='$BIN_LOG', MASTER_LOG_POS=$POS_LOG", GET_MASTER_PUBLIC_KEY = 1
mysql -e "START SLAVE;"
mysql -e "show slave status\G"

sayWait
echo "копируем скрипт backup.sh (/opt/scripts/)"

mkdir -p /opt/scripts
cp  $HOME_DIR/my-project/mysql/backup.sh /opt/scripts
chmod 700 /opt/scripts/backup.sh

mkdir -p $BACKUP_DIR

echo "выполняем backup всех БД (потаблично)"
/opt/scripts/backup.sh

ls -l $BACKUP_DIR

sayWait
