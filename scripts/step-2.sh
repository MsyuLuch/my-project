#! /bin/bash

sayWait()
{
   local AMSURE
   [ -n "$1" ] && echo "$@" 1>&2
   read -n 1 -p "(нажмите любую клавишу для продолжения)" AMSURE
   echo "" 1>&2
}

HOME_DIR="/root/exp"

# Only root can execute this script
USER_ID="$(id -u)"
if [[ ${USER_ID} -ne 0 ]]; then
    echo  "Only root can execute this script."
    exit 1
fi

############## GIT ###########################
echo "устанавливаем git:"

yum install git

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

mysql -e "CHANGE MASTER TO MASTER_HOST='185.177.93.9', MASTER_USER='repl', MASTER_PASSWORD='oTUSlave#2020', MASTER_LOG_FILE='binlog.000004', MASTER_LOG_POS=714;"
mysql -e "START SLAVE;"
mysql -e "show slave status\G"