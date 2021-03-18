#! /bin/bash

# Only root can execute this script
USER_ID="$(id -u)"
if [[ ${USER_ID} -ne 0 ]]; then
    echo  "Only root can execute this script."
    exit 1
fi

mysql -e "FLUSH TABLES WITH READ LOCK; SET GLOBAL read_only = ON;"

for database in `mysql -e'show databases;' | grep -v information_schema | grep -v Database`;
    do
        for table in `mysql ${database} -e'show tables;' | grep -v Tables_*`;
        do
        /usr/bin/mysqldump -x --opt ${database} ${table} | /usr/bin/gzip -c > /var/backup/mysql/`date +%Y%m%d-%H%M`-$database-$table.sql.gz;
        echo "[$(date +"%Y/%m/%d %H:%M:%S %Z")] INFO: dump $database:$table" >> /var/log/mysql/backup-`date +%Y%m%d`.log;
        done
done

mysql -e "SET GLOBAL read_only = OFF; UNLOCK TABLES;"
