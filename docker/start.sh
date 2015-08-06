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

merge_vars() {
    local var_name1=$1
    local var_name2=$2
    local default=$3
    eval "$var_name1=${!var_name1:-\"\"}"
    if [ ! -z ${!var_name2} ]; then
        if [ -z ${!var_name1} ]; then
            eval "$var_name1=\"${!var_name2}\""
        else
            eval "$var_name1=\"${!var_name1},${!var_name2}\""
        fi
    fi
    eval "$var_name1=${!var_name1:-\"$default\"}"
}

mkdir -p /volume/log
mkdir -p /volume/run
mkdir -p /volume/recovery
touch /volume/log/zabbix_server.log

chown -R zabbix:zabbix /volume/*

merge_vars ERR_QUEUE_ADDR SPARK_ERROR_QUEUE_PORT
merge_vars ROUTER_QUEUE_ADDR SPARK_QUEUE_PORT

CONF=/opt/zabbix/zabbix_server.conf

update_file $CONF MYSQL_PORT_3306_TCP_ADDR
update_file $CONF MYSQL_ENV_MYSQL_ROOT_PASSWORD
update_file $CONF ROUTER_QUEUE_ADDR
update_file $CONF ERR_QUEUE_ADDR
update_file $CONF ALERTSCRIPTS
update_file $CONF EXTERNALSCRIPTS
update_file $CONF LOG_DIR

MYSQL_PORT_3306_TCP_PORT=${MYSQL_PORT_3306_TCP_PORT:-3306}

echo "Trying to create zabbix db schema..."
mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" < /opt/zabbix/zabbix_schema.sql

echo "Starting zabbix server"
exec /opt/zabbix/zabbix_server --nodaemon -c $CONF
