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

# merge with docker --link variables
if [ ! -z $ERR_QUEUE_PORT_8801_TCP_PORT ]; then
    ERR_QUEUE_LINK="tcp://err_queue:$ERR_QUEUE_PORT_8801_TCP_PORT"
fi
merge_vars ERR_QUEUE_ADDR ERR_QUEUE_LINK

# merge with docker --link variables (assuming 2 queue processes per queue container)
if [ ! -z $QUEUE_PORT_6601_TCP_PORT ]; then
    QUEUE1_LINK="tcp://queue:$QUEUE_PORT_6601_TCP_PORT"
fi
if [ ! -z $QUEUE_PORT_6603_TCP_PORT ]; then
    QUEUE2_LINK="tcp://queue:$QUEUE_PORT_6603_TCP_PORT"
fi
merge_vars ROUTER_QUEUE_ADDR QUEUE1_LINK
merge_vars ROUTER_QUEUE_ADDR QUEUE2_LINK

CONF=/opt/zabbix/zabbix_server.conf

update_file $CONF MYSQL_PORT_3306_TCP_ADDR
update_file $CONF MYSQL_ENV_MYSQL_ROOT_PASSWORD
update_file $CONF ROUTER_QUEUE_ADDR
update_file $CONF ERR_QUEUE_ADDR
update_file $CONF ALERTSCRIPTS
update_file $CONF EXTERNALSCRIPTS
update_file $CONF LOG_DIR

MYSQL_PORT_3306_TCP_PORT=${MYSQL_PORT_3306_TCP_PORT:-3306}

mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" < /opt/zabbix/zabbix_schema.sql

/opt/zabbix/zabbix_server -c $CONF && tail -F /volume/log/zabbix_server.log
