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

############## ELK ###########################

# Копируем публичный ключ репозитория:
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

#Подключаем репозиторий Elasticsearch:

cp -vi $HOME_DIR/my-project/repos/* /etc/yum.repos.d/

yum install --enablerepo=elasticsearch elasticsearch

systemctl daemon-reload && systemctl enable elasticsearch.service && systemctl start elasticsearch.service && systemctl status elasticsearch.service

sayWait

curl 127.0.0.1:9200

# Копируем публичный ключ репозитория:
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

yum install kibana

systemctl daemon-reload && systemctl enable kibana.service && systemctl start kibana.service && systemctl status kibana.service

sayWait

yum install logstash

cp -vi $HOME_DIR/my-project/logstash/ /etc/logstash/

systemctl enable logstash.service && systemctl start logstash.service && systemctl status logstash.service

sayWait

yum install filebeat

cp -vi $HOME_DIR/my-project/filebeat/* /etc/filebeat

systemctl start filebeat && systemctl enable filebeat && systemctl status filebeat

sayWait