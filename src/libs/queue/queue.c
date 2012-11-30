#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdint.h>
#include <errno.h>
#include <zmq.h>

#include "log.h"
#include "queue.h"
#include "common.h"
#include "zbxjson.h"


void queue_ctx_init(struct queue_ctx* ctx, const char* recovery_dir) {
    ctx->zmq_sock_msg = NULL;
    ctx->zmq_sock_err = NULL;
    ctx->prev_status = 0;
    ctx->recovery_fd = -1;
    ctx->zmq_ctx = zmq_ctx_new();
   
    if (ctx->zmq_ctx == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error initializing zmq context: %s", strerror(errno));
    }
    
    // create recovery file name
    size_t len = strlen(recovery_dir);
    char* name = (char*) malloc(300 * sizeof(char));
    char* recovery_file = (char*) malloc((311 + len) * sizeof(char));
    memcpy(recovery_file, recovery_dir, len);
    char hostname[250];
    gethostname(hostname, 250);
    zbx_snprintf(name, 300, "zabbix-%s-%d", hostname, (int) getpid());
    zbx_snprintf(recovery_file + len, 311, "/%s.recovery", name);
    ctx->name = name;
    ctx->recovery_file = recovery_file;
}

void queue_ctx_destroy(struct queue_ctx* ctx) {
    zmq_close(ctx->zmq_sock_msg);
    if (ctx->zmq_sock_err != NULL)
        zmq_close(ctx->zmq_sock_err);
    zmq_ctx_destroy(ctx->zmq_ctx);
    free(ctx->recovery_file);
}

void queue_sock_connect_msg(struct queue_ctx* ctx, const char* queue_addr_msg) {
    ctx->zmq_sock_msg = zmq_socket(ctx->zmq_ctx, ZMQ_PUSH);
    if (ctx->zmq_sock_msg == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error creating zmq socket: %s", strerror(errno));
        return;
    }
    if (zmq_connect(ctx->zmq_sock_msg, queue_addr_msg) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error connecting to zmq socket: %s, error: %s",
            queue_addr_msg, strerror(errno));
    }
}

void queue_sock_connect_err(struct queue_ctx* ctx, const char* queue_addr_err) {
    ctx->zmq_sock_err = zmq_socket(ctx->zmq_ctx, ZMQ_PUSH);
    if (ctx->zmq_sock_err == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error creating zmq socket: %s", strerror(errno));
        return;
    }
    int hwm = 0;
    if (zmq_setsockopt(ctx->zmq_sock_err, ZMQ_SNDHWM, &hwm, sizeof(hwm)) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error setting zmq high watter mark on err sock: %s",
        strerror(errno));
    }
    if (zmq_connect(ctx->zmq_sock_err, queue_addr_err) == -1) {
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

void __build_error_msg(struct queue_ctx* ctx, struct zbx_json *j) {
    zbx_json_init(j, 256);
    zbx_json_addstring(j, "error", "Zabbix: unable to send to zmq queue", ZBX_JSON_TYPE_STRING);
    zbx_json_addstring(j, "source", ctx->name, ZBX_JSON_TYPE_STRING);
    zbx_json_addstring(j, "recovery", ctx->recovery_file, ZBX_JSON_TYPE_STRING);
}

ssize_t __write_all(int fd, const void* buf, size_t count) {
  size_t left = count;
  while (left > 0) {
    size_t n = write(fd, buf, count);
    if (n == -1)
      return -1;
    else
      left -= n;
  }
  return count;
}

ssize_t __read_all(int fd, void* buf, size_t count) {
    size_t left = count;
    while (left > 0) {
        size_t n = read(fd, buf, count);    
        if (n == -1)
            return -1;
        else
            left -= n;
    }
    return count;
}

void __update_recovery_entry(struct queue_ctx* ctx, long ts, int new_gap) {
    int ts1, ts2;
    uint32_t net;
    struct flock fl;
    fl.l_type = F_WRLCK;    // F_RDLCK, F_WRLCK, F_UNLCK
    fl.l_whence = SEEK_SET; // SEEK_SET, SEEK_CUR, SEEK_END
    fl.l_start = 0;         // Offset from l_whence
    fl.l_len = 0;           // length, 0 = to EOF
    fl.l_pid = getpid();
    
    // obtain file lock, block until the lock has cleared
    fcntl(ctx->recovery_fd, F_SETLKW, &fl);
    
    size_t size = lseek(ctx->recovery_fd, 0, SEEK_END);
    if (new_gap || size == 0) {
        // beggining of new gap
        zabbix_log(LOG_LEVEL_DEBUG, "Beginning of new gap");
        net = htonl((uint32_t) ts);
        __write_all(ctx->recovery_fd, &net, 4);
        __write_all(ctx->recovery_fd, &net, 4);
    } else {
        // current gap extends
        zabbix_log(LOG_LEVEL_DEBUG, "Current gap extends");
        lseek(ctx->recovery_fd, -8, SEEK_END);
        __read_all(ctx->recovery_fd, &net, 4);
        ts1 = ntohl(net);
        __read_all(ctx->recovery_fd, &net, 4);
        ts2 = ntohl(net);
        zabbix_log(LOG_LEVEL_DEBUG, "Current gap extends, ts1: %d, ts2: %d", ts1, ts2);
        if (ts > ts2) {
            net = htonl((uint32_t) ts);    
            lseek(ctx->recovery_fd, -4, SEEK_END);
            __write_all(ctx->recovery_fd, &net, 4);
        } else if (ts < ts1) {
            net = htonl((uint32_t) ts);
            lseek(ctx->recovery_fd, -8, SEEK_END);
            __write_all(ctx->recovery_fd, &net, 4);
        }
        zabbix_log(LOG_LEVEL_DEBUG, "Current gap extended, ts1: %d, ts2: %d", ts1, ts2);
    }
    
    // release file lock
    fl.l_type = F_UNLCK;
    fcntl(ctx->recovery_fd, F_SETLK, &fl);
}

void __update_recovery(struct queue_ctx* ctx, const char* msg) {
    struct zbx_json_parse jp, jp_data, jp_row;
    const char *p;
    int	ret = FAIL;
    long ts = 0;
    char *tmp = NULL;
	size_t tmp_alloc = 0;
    int new_gap = 0;
    
    // parse json msg
    if (SUCCEED != zbx_json_open(msg, &jp)) {
        zabbix_log(LOG_LEVEL_ERR, "Error parsing json: %s", msg);
        return;
    }
    
    if (NULL == (p = zbx_json_pair_by_name(&jp, ZBX_PROTO_TAG_DATA)))
		zabbix_log(LOG_LEVEL_ERR, "cannot find \"data\" pair");
	else if (FAIL == zbx_json_brackets_open(p, &jp_data))
		zabbix_log(LOG_LEVEL_ERR, "cannot process json request: %s", zbx_json_strerror());
	else
		ret = SUCCEED;
        
    if (ctx->prev_status == 0)
        new_gap = 1;
    
    p = NULL;
    // iterate the item key entries
	while (SUCCEED == ret && NULL != (p = zbx_json_next(&jp_data, p)))	{
        if (FAIL == (ret = zbx_json_brackets_open(p, &jp_row)))
			break;
        if (SUCCEED == zbx_json_value_by_name_dyn(&jp_row, ZBX_PROTO_TAG_CLOCK, &tmp, &tmp_alloc)) {
            ts = atoi(tmp);
            zabbix_log(LOG_LEVEL_DEBUG, "Update recovery entry, ts: %d", ts);
            __update_recovery_entry(ctx, ts, new_gap);
            new_gap = 0;
        }
    }
    zbx_free(tmp);
}

void queue_msg_send_error(struct queue_ctx* ctx, const char* msg) {
    struct zbx_json j;
    
    if (ctx->zmq_sock_err != NULL) {
        __build_error_msg(ctx, &j);
        if (queue_msg_send(ctx->zmq_sock_err, j.buffer) == -1) {
            zabbix_log(LOG_LEVEL_ERR, "Error sending to error queue: %s", strerror(errno));
        }
        zbx_json_free(&j);
    } else {
        zabbix_log(LOG_LEVEL_WARNING, "Skipping error notification, error queue not connected");
    }
    
    if (ctx->recovery_fd == -1) {
        ctx->recovery_fd = open(ctx->recovery_file, O_CREAT | O_RDWR,
            S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
    }
    if (ctx->recovery_fd == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error opening recovery file: %s", ctx->recovery_file);
        return;
    }
    
    __update_recovery(ctx, msg);
}
