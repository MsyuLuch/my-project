# Выпускная работа
## Проект включает:
- web-сервер (front-end - Nginx, back-end - Apache)
- cервер баз данных - MySQL (настройка репликации, настройка резервного копирования)
- CMS - WORDPRESS
- мониторинг - Prometheus + Grafana
- логирование - ELK Stack: Elasticsearch, Logstash, Kibana
____
Предварительно:
- запуск скриптов только от пользователя root
- установлен wget
- SELINUX=disabled (настройка SELINUX в скриптах не предусмотрена)
- в скриптах необходимо вручную отредактировать 
  + $HOME_DIR (директория, в которую скачан проект my-project) 
  + $IP_MASTER (ip адрес сервера с ролью MASTER) 
  + $IP_REPL (ip адрес сервера с ролью SLAVE)
- в файле /mysql/.my.cnf прописан пароль пользователя root для mysql (необходимо ввести при установке mysql)
- для настройки geoip фильтра в $HOME_DIR должна быть база данных GeoLite2-City.mmdb (скачать можно по ссылке https://dev.maxmind.com/geoip/geoip2/geolite2/#Download_Access)
 
my-project/scripts:
- step-1.sh - установка Nginx, Apache, MySql-Server (Master), CMS Wordpress
- step-2.sh - установка MySql-Server (Slave)
- step-3.sh - установка Prometheus, Node-exporter, Grafana
- step-4.sh - установка ELK Stack: Elasticsearch, Logstash, Kibana
___________
Установка:
- выполняем скрипт step-1.sh на сервере с ролью Master (начальные параметры, должны быть отредектированы вручную $HOME_DIR, $IP_REPL)
- выполняем скрипт step-2.sh (начальные параметры, должны быть отредектированы вручную: $HOME_DIR, $IP_MASTER, $BIN_LOG - bin-log, $POS_LOG - номер позиции, данные, выведенные на экран на последнем шаге выполнения step-1.sh). Файл дампа базы mysql, автоматически сформированный на предыдущем шаге необходимо перенести в $HOME_DIR на сервер с ролью Slave.
- выполняем скрипт step-3.sh (начальные параметры, должны быть отредектированы вручную: $HOME_DIR).
- выполняем скрипт step-4.sh (начальные параметры, должны быть отредектированы вручную: $HOME_DIR).

CMS доступна по ссылке http://IP_MASTER
Prometheus - http://IP_MASTER:9090
Grafana - http://IP_MASTER:3000
Kibana - http://IP_MASTER:5601
