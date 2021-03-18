#! /bin/bash

sayWait()
{
   local AMSURE
   [ -n "$1" ] && echo "$@" 1>&2
   read -n 1 -p "(нажмите любую клавишу для продолжения)" AMSURE
   echo "" 1>&2
}

HOME_DIR="/root"
IP_REPL="185.177.93.227"

# Only root can execute this script
USER_ID="$(id -u)"
if [[ ${USER_ID} -ne 0 ]]; then
    echo  "Only root can execute this script."
    exit 1
fi

############## APACHE & PHP ###########################
echo "устанавливаем apache, php"
yum install httpd && dnf install php php-cli php-mysqlnd php-json php-gd php-ldap php-odbc php-pdo php-opcache php-pear php-xml php-xmlrpc php-mbstring php-snmp php-soap php-zip
sayWait
############## NGINX ###########################
echo "устанавливаем nginx"
yum install nginx
sayWait
############## WORDPRESS ###########################
cp -R $HOME_DIR/my-project/nginx/* /etc/nginx && cp -R $HOME_DIR/my-project/httpd/* /etc/httpd

cd $HOME_DIR && wget https://ru.wordpress.org/latest-ru_RU.tar.gz && tar xzvf latest-ru_RU.tar.gz

mkdir /var/www/site.ru && cp -R $HOME_DIR/wordpress/* /var/www/site.ru && chown -R apache. /var/www/site.ru
sayWait
############## MYSQL ###########################
echo "установливаем mysql"
yum install mysql-server

systemctl start mysqld && systemctl status mysqld && systemctl enable mysqld

mysql_secure_installation

cp  $HOME_DIR/my-project/mysql/my.cnf.d/* /etc/my.cnf.d/
cp  $HOME_DIR/my-project/mysql/.my.cnf /root/

service mysqld restart && systemctl status mysqld
sayWait

mysql -e "create user repl@"$IP_REPL" IDENTIFIED WITH caching_sha2_password BY 'oTUSlave#2020'"
mysql -e "GRANT REPLICATION SLAVE ON *.* TO repl@"$IP_REPL
mysql -e "SELECT User, Host FROM mysql.user"
mysql -e "SHOW MASTER STATUS"
sayWait

mysql -e "create database wordpress"
mysql -e "show databases"
sayWait

cd $HOME_DIR/my-project
mysqldump --all-databases --no-create-info > dump-data.sql
mysql -e "SHOW MASTER STATUS"
sayWait