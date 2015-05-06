#!/bin/bash

update_file() {
    local file=$1
    local var_name=$2
    local default=$3
    if [ -z "$default" -a -z "${!var_name}" ]; then
        echo "$var_name is unset"
        exit 1
    fi
    sed -i "s|$var_name|${!var_name:-$default}|" $file
}

mkdir -p /volume/log
mkdir -p /volume/run
mkdir -p /volume/recovery
touch /volume/log/zabbix_server.log

chown -R zabbix:zabbix /volume/*

CONF=/opt/zabbix/zabbix_server.conf

update_file $CONF MYSQL_PORT_3306_TCP_ADDR
update_file $CONF MYSQL_ENV_MYSQL_ROOT_PASSWORD
update_file $CONF ROUTER_QUEUE_ADDR
update_file $CONF ERROR_QUEUE_ADDR

mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" < /opt/zabbix/zabbix_schema.sql

/opt/zabbix/zabbix_server -c $CONF && tail -F /volume/log/zabbix_server.log
