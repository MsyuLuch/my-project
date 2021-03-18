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

mysql -e "create database wordpress;"
mysql -e "show databases;"
sayWait

mysqldump --all-databases --no-create-info > dump-data.sql
mysql -e "SHOW MASTER STATUS;"
sayWait



