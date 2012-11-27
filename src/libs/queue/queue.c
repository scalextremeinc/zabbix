#include <string.h>
#include <errno.h>
#include <zmq.h>

#include "log.h"
#include "queue.h"


void queue_ctx_init(struct queue_ctx* ctx) {
    ctx->zmq_sock_msg = NULL;
    ctx->zmq_sock_err = NULL;
    ctx->prev_status = 0;
    ctx->zmq_ctx = zmq_ctx_new();
    if (ctx->zmq_ctx == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error initializing zmq context: %s", strerror(errno));
    }
}

void queue_ctx_destroy(struct queue_ctx* ctx) {
    zmq_close(ctx->zmq_sock_msg);
    if (ctx->zmq_sock_err != NULL)
        zmq_close(ctx->zmq_sock_err);
    zmq_ctx_destroy(ctx->zmq_ctx);
}

void queue_sock_connect_msg(struct queue_ctx* ctx, const char* queue_addr_msg) {
    ctx->zmq_sock_msg = zmq_socket(ctx->zmq_ctx, ZMQ_PUSH);
    if (ctx->zmq_sock_msg == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error creating zmq socket: %s", strerror(errno));
    } else if (zmq_connect(ctx->zmq_sock_msg, queue_addr_msg) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error connecting to zmq socket: %s, error: %s",
            queue_addr_msg, strerror(errno));
    }
}

void queue_sock_connect_err(struct queue_ctx* ctx, const char* queue_addr_err) {
    ctx->zmq_sock_err = zmq_socket(ctx->zmq_ctx, ZMQ_PUSH);
    if (ctx->zmq_sock_err == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error creating zmq socket: %s", strerror(errno));
    } else if (zmq_connect(ctx->zmq_sock_err, queue_addr_err) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error connecting to zmq socket: %s, error: %s",
            queue_addr_err, strerror(errno));
    }
}

void queue_msg(struct queue_ctx* ctx, const char* msg) {
    if (queue_msg_send(ctx->zmq_sock_msg, msg) == -1) {
        queue_msg_send_error(ctx, msg);
        ctx->prev_status = -1;
    } else {
        ctx->prev_status = 0;
    }
}

int queue_msg_send(void* zmq_sock, const char* msg) {
    size_t len = strlen(msg);
    // send json data to queue
    zmq_msg_t request;
    if (zmq_msg_init_size(&request, len) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error allocating zmq message: %s", strerror(errno));
        return -1;
    }
    memcpy(zmq_msg_data(&request), msg, len);
    // ZMQ_DONTWAIT specifies that the operation should be performed in non-blocking mode.
    // If the message cannot be queued on the socket, the zmq_msg_send()
    // function shall fail with errno set to EAGAIN
    if (zmq_msg_send(&request, zmq_sock, ZMQ_DONTWAIT) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error sending to queue: %s", strerror(errno));
        zmq_msg_close(&request);
        return -1;
    }
    zmq_msg_close(&request);
    return 0;
}

void queue_msg_send_error(struct queue_ctx* ctx, const char* msg) {
    // TODO
}
