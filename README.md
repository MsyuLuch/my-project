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
- для настройки geoip фильтра в $HOME_DIR должна быть база данных GeoLite2-City.mmdb (скачать можно по ссылке https://dev.maxmind.com/geoip/geoip2/geolite2/#Download_Access)
- в скриптах необходимо вручную отредактировать 
  + $HOME_DIR (директория, в которую скачан проект my-project) 
  + $IP_MASTER (ip адрес сервера с ролью MASTER) 
  + $IP_REPL (ip адрес сервера с ролью SLAVE)
 
my-project/scripts:
- step-1.sh - установка Nginx, Apache, MySql-Server (Master), CMS Wordpress
- step-2.sh - установка MySql-Server (Slave)
- step-3.sh - установка Prometheus, Node-exporter, Grafana
- step-4.sh - установка ELK Stack: Elasticsearch, Logstash, Kibana
