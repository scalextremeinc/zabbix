#!/bin/bash

mkdir -p /volume/log
mkdir -p /volume/run
mkdir -p /volume/recovery
touch /volume/log/zabbix_server.log

chown -R zabbix:zabbix /volume/*

if [ -z "$MYSQL_PORT_3306_TCP_ADDR" ]; then
    echo "MYSQL_PORT_3306_TCP_ADDR is unset"
    exit 1
fi
sed -i "s/MYSQL_PORT_3306_TCP_ADDR/$MYSQL_PORT_3306_TCP_ADDR/" /opt/zabbix/zabbix_server.conf


if [ -z "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ]; then
    echo "MYSQL_ENV_MYSQL_ROOT_PASSWORD is unset"
    exit 1
fi
sed -i "s/MYSQL_ENV_MYSQL_ROOT_PASSWORD/$MYSQL_ENV_MYSQL_ROOT_PASSWORD/" /opt/zabbix/zabbix_server.conf

if [ -z "$ROUTER_QUEUE_ADDR" ]; then
    echo "ROUTER_QUEUE_ADDR is unset"
    exit 1
fi
sed -i "s|ROUTER_QUEUE_ADDR|$ROUTER_QUEUE_ADDR|" /opt/zabbix/zabbix_server.conf

if [ -z "$ERROR_QUEUE_ADDR" ]; then
    echo "ERROR_QUEUE_ADDR is unset"
    exit 1
fi
sed -i "s|ERROR_QUEUE_ADDR|$ERROR_QUEUE_ADDR|" /opt/zabbix/zabbix_server.conf

mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" < /opt/zabbix/zabbix_schema.sql

/opt/zabbix/zabbix_server -c /opt/zabbix/zabbix_server.conf && tail -F /volume/log/zabbix_server.log
