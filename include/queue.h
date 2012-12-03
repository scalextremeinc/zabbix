#ifndef ZABBIX_QUEUE_H
#define ZABBIX_QUEUE_H

struct queue_ctx {
    void* zmq_ctx;
    void* zmq_sock_msg;
    void* zmq_sock_err;
    short prev_status;
    char* node_name;
    char* worker_name;
    char* recovery_dir;
    char* recovery_file;
    int recovery_fd;
};

void queue_ctx_init(struct queue_ctx* ctx, const char* recovery_dir);

void queue_ctx_destroy(struct queue_ctx* ctx);

void queue_sock_connect_msg(struct queue_ctx* ctx, const char* queue_addr_msg);

void queue_sock_connect_err(struct queue_ctx* ctx, const char* queue_addr_err);

void queue_msg(struct queue_ctx* ctx, const char* msg);

int queue_msg_send(void* zmq_sock, const char* msg);

void queue_msg_send_error(struct queue_ctx* ctx, const char* msg);

#endif /* ZABBIX_QUEUE_H */
