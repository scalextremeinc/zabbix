#include <string.h>
#include <errno.h>
#include <zmq.h>

#include "queue.h"
#include "log.h"


void* queue_create_context() {
    void* context = zmq_ctx_new();
    if (context == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error initializing zmq context: %s", strerror(errno));
    }
    return context;
}

void* queue_create_socket(void* context_zmq, const char* queue_addr) {
    void* queue_socket = zmq_socket(context_zmq, ZMQ_PUSH);
    if (queue_socket == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error creating zmq socket: %s", strerror(errno));
    } else if (zmq_connect(queue_socket, queue_addr) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error connecting to zmq socket: %s, error: %s",
            queue_addr, strerror(errno));
    }
    return queue_socket;
}

void queue_send_msg(void* queue_socket_zmq, const char* msg) {
    size_t len = strlen(msg);
    // send json data to queue
    zmq_msg_t request;
    if (zmq_msg_init_size(&request, len) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error allocating zmq message: %s", strerror(errno));
    }
    memcpy(zmq_msg_data(&request), msg, len);
    // ZMQ_DONTWAIT specifies that the operation should be performed in non-blocking mode.
    // If the message cannot be queued on the socket, the zmq_msg_send()
    // function shall fail with errno set to EAGAIN
    if (zmq_msg_send(&request, queue_socket_zmq, ZMQ_DONTWAIT) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error sending to queue: %s", strerror(errno));
    }
    zmq_msg_close(&request);
}
