#ifndef ZABBIX_QUEUE_H
#define ZABBIX_QUEUE_H

#include "common.h"
#include "zbxjson.h"

struct queue_ctx {
    void* zmq_ctx;
    void* zmq_sock_msg;
    void* zmq_sock_err;
    // ZMQ_DELAY_ATTACH_ON_CONNECT
    int zmq_daoc;
    short prev_status;
    char* node_name;
    char* worker_name;
    char* recovery_dir;
    char* recovery_file;
    int recovery_fd;
    int pid;
};

void queue_ctx_init(struct queue_ctx* ctx, const char* recovery_dir, int zmq_daoc);

void queue_ctx_destroy(struct queue_ctx* ctx);

void queue_sock_connect_msg(struct queue_ctx* ctx, const char* queue_addr_msg);

void queue_sock_connect_err(struct queue_ctx* ctx, const char* queue_addr_err);

void queue_msg(struct queue_ctx* ctx, struct zbx_json_parse *jp_msg,
        zbx_timespec_t *timediff, char* target);

int queue_msg_send(void* zmq_sock, const char* msg, char* target);

void queue_msg_send_error(struct queue_ctx* ctx, const char* msg);

#endif /* ZABBIX_QUEUE_H */
