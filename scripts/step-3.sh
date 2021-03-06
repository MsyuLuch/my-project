#! /bin/bash

sayWait()
{
   local AMSURE
   [ -n "$1" ] && echo "$@" 1>&2
   read -n 1 -p "(нажмите любую клавишу для продолжения)" AMSURE
   echo "" 1>&2
}

HOME_DIR="/root"

# Only root can execute this script
USER_ID="$(id -u)"
if [[ ${USER_ID} -ne 0 ]]; then
    echo  "Only root can execute this script."
    exit 1
fi

############## PROMETHEUS ###########################

#создаем пользователя без домашней директории, без возможности логина
useradd --no-create-home --shell /sbin/nologin prometheus && useradd --no-create-home --shell /sbin/false node_exporter

# проверяем наличие пользователей
awk -F":" '{print $1}' /etc/passwd

sayWait

# директории для работы
mkdir /etc/prometheus && mkdir /var/lib/prometheus

# устанавливаем права на директории
chown -R prometheus: /etc/prometheus && chown -R prometheus: /var/lib/prometheus

# проверяем установились ли права
ls -ld /etc/prometheus
ls -ld /var/lib/prometheus

sayWait

# создаем директорию для распаковки архивов
cd $HOME_DIR

# скачиваем prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.25.0/prometheus-2.25.0.linux-amd64.tar.gz

# распаковываем архив
tar xvfz prometheus-*.t*gz

sayWait

------------------------------------------------------------------
#NODE-EXPORTER

cd $HOME_DIR

# скачиваем node-exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz

# распаковываем архив
tar xvfz node_exporter*.t*gz

sayWait

# копируем файлы в папки, где будут хранится утилиты установленные пользователями
#и система будет их видеть
cp $HOME_DIR/node_exporter-*/node_exporter /usr/local/bin

# устанавливаем права на папку для пользователя node_exporter
chown -v node_exporter /usr/local/bin/node_exporter

# создаем unit для systemd, который позволит запуститить утилиту, просматривать статус
#выполнения и позволит добавить утилиту в автозагрузку

#создаем файл сервиса node_exporter
cp $HOME_DIR/my-project/service/* /etc/systemd/system/

# даем systemd команду перечитать файлы конфигурации
systemctl daemon-reload

# запускаем сервис и проверяем его состояние
systemctl start node_exporter.service && systemctl status node_exporter.service

sayWait

-------------------------------------------------------------
#PROMETHEUS

cd $HOME_DIR

# копируем файлы все в /etc/prometheus
cp -rvi prometheus-*/{console{_libraries,s},prometheus.yml} /etc/prometheus/

# устанавливаем права на папку для пользователя prometheus
chown -Rv prometheus: /etc/prometheus/

# настроить prometheus.yml
cp $HOME_DIR/my-project/prometheus/* /etc/prometheus/prometheus.yml

# копируем файлы в папки, где будут хранится утилиты установленные пользователями
#и система будет их видеть
cp -vi $HOME_DIR/prometheus-*/prom{etheus,tool} /usr/local/bin

# устанавливаем права на папку для пользователя node_exporter
chown -v prometheus /usr/local/bin/prom{etheus,tool}

# запускаем сервис и проверяем его состояние
systemctl start prometheus.service && systemctl status prometheus.service

# прописываем сервисы в автозагрузку
systemctl enable prometheus.service && systemctl enable node_exporter.service

sayWait
-----------------------------------------------------------------------
#GRAFANA

# скачиваем grafana
wget https://dl.grafana.com/oss/release/grafana-7.4.3-1.x86_64.rpm

# устанавливаем
sudo yum install grafana-7.4.3-1.x86_64.rpm

systemctl daemon-reload && systemctl start grafana-server && systemctl enable grafana-server && systemctl status grafana-server

