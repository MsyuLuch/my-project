#! /bin/bash

sayWait()
{
   local AMSURE
   [ -n "$1" ] && echo "$@" 1>&2
   read -n 1 -p "(нажмите любую клавишу для продолжения)" AMSURE
   echo "" 1>&2
}

HOME_DIR="/root/exp"
BACKUP_DIR="/var/backup/mysql"
IP_MASTER="185.177.93.9"
BIN_LOG="binlog.000005"
POS_LOG="688350"

# Only root can execute this script
USER_ID="$(id -u)"
if [[ ${USER_ID} -ne 0 ]]; then
    echo  "Only root can execute this script."
    exit 1
fi

############## GIT ###########################

cd $HOME_DIR
git clone https://github.com/MsyuLuch/my-project.git

sayWait

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

mysql -e "CHANGE MASTER TO MASTER_HOST='$IP_MASTER', MASTER_USER='repl', MASTER_PASSWORD='oTUSlave#2020', MASTER_LOG_FILE='$BIN_LOG', MASTER_LOG_POS=$POS_LOG"
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
