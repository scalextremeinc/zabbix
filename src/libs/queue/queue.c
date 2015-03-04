#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdint.h>
#include <fcntl.h>
#include <errno.h>
#include <zmq.h>

#include "log.h"
#include "queue.h"


void queue_ctx_init(struct queue_ctx* ctx, const char* recovery_dir, int zmq_daoc) {
    ctx->zmq_sock_msg = NULL;
    ctx->zmq_sock_err = NULL;
    ctx->zmq_daoc = zmq_daoc;
    ctx->prev_status = 0;
    ctx->recovery_fd = -1;
    ctx->zmq_ctx = zmq_ctx_new();
   
    if (ctx->zmq_ctx == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error initializing zmq context: %s", strerror(errno));
    }
    
    // create recovery file name
    ctx->pid = (int) getpid();
    size_t len = strlen(recovery_dir);
    char* node_name = (char*) malloc(250 * sizeof(char));
    char* worker_name = (char*) malloc(300 * sizeof(char));
    char* recovery_file = (char*) malloc((310 + len) * sizeof(char));
    memcpy(recovery_file, recovery_dir, len);
    char hostname[250];
    gethostname(hostname, 250);
    zbx_snprintf(node_name, 250, "zabbix-%s", hostname);
    zbx_snprintf(worker_name, 300, "%s-%d", node_name, ctx->pid);
    zbx_snprintf(recovery_file + len, 310, "/%s.zbx.rec", worker_name);
    ctx->node_name = node_name;
    ctx->worker_name = worker_name;
    ctx->recovery_dir = recovery_dir;
    ctx->recovery_file = recovery_file;
}

void queue_ctx_destroy(struct queue_ctx* ctx) {
    zmq_close(ctx->zmq_sock_msg);
    if (ctx->zmq_sock_err != NULL)
        zmq_close(ctx->zmq_sock_err);
    zmq_ctx_destroy(ctx->zmq_ctx);
    free(ctx->node_name);
    free(ctx->worker_name);
    free(ctx->recovery_file);
    if (ctx->recovery_fd != -1)
        close(ctx->recovery_fd);
}

void __zmq_multi_connect(void* zmq_sock, const char* addr) {
    // connect to all sockets specified as comma separated list
    int i, j = 0;
    char buf[128];
    for (i = 0; i < strlen(addr); i++) {
        if (addr[i + 1] == ',' || addr[i + 1] == '\0') {
            memcpy(buf, addr + j, i + 1 - j);
            buf[i + 1 - j] = '\0';
            if (zmq_connect(zmq_sock, buf) == -1) {
                zabbix_log(LOG_LEVEL_ERR, "Error connecting to zmq socket: %s, error: %s",
                    buf, strerror(errno));
            } else {
                zabbix_log(LOG_LEVEL_INFORMATION, "Connected zmq socket: %s", buf);
            }
            j = i + 2;
        }
    }
}

void queue_sock_connect_msg(struct queue_ctx* ctx, const char* queue_addr_msg) {
    ctx->zmq_sock_msg = zmq_socket(ctx->zmq_ctx, ZMQ_PUSH);
    if (ctx->zmq_sock_msg == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error creating zmq socket: %s", strerror(errno));
        return;
    }
    if (ctx->zmq_daoc) {
        int daoc = 1;
        if (zmq_setsockopt(ctx->zmq_sock_msg, ZMQ_DELAY_ATTACH_ON_CONNECT,
                &daoc, sizeof(daoc)) == -1) {
            zabbix_log(LOG_LEVEL_ERR, "Error setting ZMQ_DELAY_ATTACH_ON_CONNECT: %s",
                strerror(errno));
        }
    }
    __zmq_multi_connect(ctx->zmq_sock_msg, queue_addr_msg);
}

void queue_sock_connect_err(struct queue_ctx* ctx, const char* queue_addr_err) {
    ctx->zmq_sock_err = zmq_socket(ctx->zmq_ctx, ZMQ_PUSH);
    if (ctx->zmq_sock_err == NULL) {
        zabbix_log(LOG_LEVEL_ERR, "Error creating zmq socket: %s", strerror(errno));
        return;
    }
    int hwm = 100;
    if (zmq_setsockopt(ctx->zmq_sock_err, ZMQ_SNDHWM, &hwm, sizeof(hwm)) == -1) {
        zabbix_log(LOG_LEVEL_ERR, "Error setting zmq high watter mark on err sock: %s",
        strerror(errno));
    }
    if (ctx->zmq_daoc) {
        int daoc = 1;
        if (zmq_setsockopt(ctx->zmq_sock_err, ZMQ_DELAY_ATTACH_ON_CONNECT,
                &daoc, sizeof(daoc)) == -1) {
            zabbix_log(LOG_LEVEL_ERR, "Error setting ZMQ_DELAY_ATTACH_ON_CONNECT: %s",
                strerror(errno));
        }
    }
    __zmq_multi_connect(ctx->zmq_sock_err, queue_addr_err);
}

int __fix_time(struct zbx_json_parse *jp_msg, struct zbx_json *jp_msg_fixed,
        zbx_timespec_t *timediff) {
    struct zbx_json_parse jp_data, jp_row;
    const char	*p;
    int ret = -1, sec, ns;
    char *tmp = NULL;
	size_t tmp_alloc = 0;
    const size_t BUF_SIZE = 32;
    char buf[BUF_SIZE];
    
    zbx_json_init(jp_msg_fixed, 512);
    zbx_json_addarray(jp_msg_fixed, ZBX_PROTO_TAG_DATA);
    
    //zbx_json_value_by_name_dyn(jp_msg, ZBX_PROTO_TAG_CLOCK, &tmp, &tmp_alloc);
    //zbx_json_value_by_name_dyn(jp_msg, ZBX_PROTO_TAG_NS, &tmp, &tmp_alloc);
    
    /* "data" tag lists the item keys */
	if (NULL == (p = zbx_json_pair_by_name(jp_msg, ZBX_PROTO_TAG_DATA)))
		zabbix_log(LOG_LEVEL_WARNING, "cannot find \"data\" pair");
	else if (-1 == zbx_json_brackets_open(p, &jp_data))
		zabbix_log(LOG_LEVEL_WARNING, "cannot process json request: %s", zbx_json_strerror());
	else
		ret = 0;
   
    p = NULL;
    while (0 == ret && NULL != (p = zbx_json_next(&jp_data, p))) {
        if (-1 == (ret = zbx_json_brackets_open(p, &jp_row)))
			break;
        
        if (0 == zbx_json_value_by_name_dyn(&jp_row, ZBX_PROTO_TAG_CLOCK, &tmp, &tmp_alloc)) {
            sec = atoi(tmp) + timediff->sec;
			if (0 == zbx_json_value_by_name_dyn(&jp_row, ZBX_PROTO_TAG_NS, &tmp, &tmp_alloc)) {
				ns = atoi(tmp) + timediff->ns;
				if (ns > 999999999)
					sec++;
			}
		} else
			sec = zbx_time();
        
        zbx_json_addobject(jp_msg_fixed, NULL);
        
        zbx_snprintf(buf, BUF_SIZE, "%d", sec);
        zbx_json_addstring(jp_msg_fixed, ZBX_PROTO_TAG_CLOCK, buf, ZBX_JSON_TYPE_INT);
        
        if (0 == zbx_json_value_by_name_dyn(&jp_row, ZBX_PROTO_TAG_HOST, &tmp, &tmp_alloc)) {
            zbx_json_addstring(jp_msg_fixed, ZBX_PROTO_TAG_HOST, tmp, ZBX_JSON_TYPE_STRING);
        }
        
		if (0 == zbx_json_value_by_name_dyn(&jp_row, ZBX_PROTO_TAG_KEY, &tmp, &tmp_alloc)) {
            zbx_json_addstring(jp_msg_fixed, ZBX_PROTO_TAG_KEY, tmp, ZBX_JSON_TYPE_STRING);
        }

		if (0 == zbx_json_value_by_name_dyn(&jp_row, ZBX_PROTO_TAG_VALUE, &tmp, &tmp_alloc)) {
            zbx_json_addstring(jp_msg_fixed, ZBX_PROTO_TAG_VALUE, tmp, ZBX_JSON_TYPE_STRING);
        }
        
        zbx_json_close(jp_msg_fixed);
    }
    
    zbx_free(tmp);
    
    return ret;
}

void queue_msg(struct queue_ctx* ctx, struct zbx_json_parse *jp_msg,
        zbx_timespec_t *timediff, char* target) {

    struct zbx_json jp_msg_fixed;
    char *msg = jp_msg->start;

    if (NULL != zbx_json_pair_by_name(jp_msg, "mark_do_not_queue_tsdb")) {
        //zabbix_log(LOG_LEVEL_INFORMATION, "Skip queue becaue of mark_do_not_queue_tsdb. msg:%s ", msg);
        return;
    }

    if (NULL != timediff) {
        //zabbix_log(LOG_LEVEL_ERR, "timediff sec: %d, ns: %d", timediff->sec, timediff->ns);
        if (-1 == __fix_time(jp_msg, &jp_msg_fixed, timediff))
            zabbix_log(LOG_LEVEL_ERR, "Error fixing timestamps for queue");
        else
            msg = jp_msg_fixed.buffer;
    }
    
    if (queue_msg_send(ctx->zmq_sock_msg, msg, target) == -1) {
        queue_msg_send_error(ctx, msg);
        ctx->prev_status = -1;
    } else {
        ctx->prev_status = 0;
    }
    
    if (NULL != timediff) {
        zbx_json_free(&jp_msg_fixed);
    }
}

int queue_msg_send(void* zmq_sock, const char* msg, char* target) {
    size_t len;
    zmq_msg_t request;

    if (target != NULL) {
        len = strlen(target);
        if (zmq_msg_init_size(&request, len) == -1) {
            zabbix_log(LOG_LEVEL_ERR, "Error allocating zmq message: %s", strerror(errno));
            return -1;
        }
        memcpy(zmq_msg_data(&request), target, len);
        if (zmq_msg_send(&request, zmq_sock, ZMQ_SNDMORE) == -1) {
            zabbix_log(LOG_LEVEL_ERR, "Error sending to queue: %s", strerror(errno));
            zmq_msg_close(&request);
            return -1;
        }
        zmq_msg_close(&request);
    }
    
    len = strlen(msg);
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
    zbx_json_addstring(j, "error", "Zabbix unable to send to zmq queue", ZBX_JSON_TYPE_STRING);
    zbx_json_addstring(j, "node", ctx->node_name, ZBX_JSON_TYPE_STRING);
    zbx_json_addstring(j, "worker", ctx->worker_name, ZBX_JSON_TYPE_STRING);
    zbx_json_addstring(j, "recovery", ctx->recovery_dir, ZBX_JSON_TYPE_STRING);
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

int __update_recovery_entry(struct queue_ctx* ctx, long ts, int new_gap) {
    int ts1, ts2;
    uint32_t net;
    struct flock fl;
    fl.l_type = F_WRLCK;    // F_RDLCK, F_WRLCK, F_UNLCK
    fl.l_whence = SEEK_SET; // SEEK_SET, SEEK_CUR, SEEK_END
    fl.l_start = 0;         // Offset from l_whence
    fl.l_len = 0;           // length, 0 = to EOF
    fl.l_pid = ctx->pid;
    
    // obtain file lock, block until the lock has cleared
    if (fcntl(ctx->recovery_fd, F_SETLKW, &fl) == -1) {
        goto error_lock;
    }
    
    off_t size = lseek(ctx->recovery_fd, 0, SEEK_END);
    if (size == -1) {
        goto error_seek;
    }
    if (new_gap || size == 0) {
        // beggining of new gap
        //zabbix_log(LOG_LEVEL_DEBUG, "Beginning of new gap");
        net = htonl((uint32_t) ts);
        if (__write_all(ctx->recovery_fd, &net, 4) == -1) {
            goto error_write;
        }
        if (__write_all(ctx->recovery_fd, &net, 4) == -1) {
            goto error_write;
        }
    } else {
        // current gap extends
        //zabbix_log(LOG_LEVEL_DEBUG, "Current gap extends");
        if (lseek(ctx->recovery_fd, -8, SEEK_END) == -1) {
            goto error_seek;
        }
        if (__read_all(ctx->recovery_fd, &net, 4) == -1) {
            goto error_read;
        }
        ts1 = ntohl(net);
        if (__read_all(ctx->recovery_fd, &net, 4) == -1) {
            goto error_read;
        }
        ts2 = ntohl(net);
        //zabbix_log(LOG_LEVEL_DEBUG, "Current gap extends, ts1: %d, ts2: %d", ts1, ts2);
        if (ts > ts2) {
            net = htonl((uint32_t) ts);    
            if (lseek(ctx->recovery_fd, -4, SEEK_END) == -1) {
                goto error_seek;
            }
            if (__write_all(ctx->recovery_fd, &net, 4) == -1) {
                goto error_write;
            }
        } else if (ts < ts1) {
            net = htonl((uint32_t) ts);
            if (lseek(ctx->recovery_fd, -8, SEEK_END) == -1) {
                goto error_seek;
            }
            if (__write_all(ctx->recovery_fd, &net, 4) == -1) {
                goto error_write;
            }
        }
        //zabbix_log(LOG_LEVEL_DEBUG, "Current gap extended, ts1: %d, ts2: %d", ts1, ts2);
    }
    
    // release file lock
    fl.l_type = F_UNLCK;
    if (fcntl(ctx->recovery_fd, F_SETLK, &fl) == -1) {
        goto error_lock;
    }
    
    return 0;

error_read:
    zabbix_log(LOG_LEVEL_ERR, "Error reading recovery, file: %s, error: %s",
        ctx->recovery_file, strerror(errno));
    return -1;
error_write:
    zabbix_log(LOG_LEVEL_ERR, "Error writing to recovery, file: %s, error: %s",
        ctx->recovery_file, strerror(errno));
    return -1;
error_seek:
    zabbix_log(LOG_LEVEL_ERR, "Error seek recovery, file: %s, error: %s",
        ctx->recovery_file, strerror(errno));
    return -1;
error_lock:
    zabbix_log(LOG_LEVEL_ERR, "Error locking/unlocking recovery, file: %s, error: %s",
        ctx->recovery_file, strerror(errno));
    return -1;
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
        if (queue_msg_send(ctx->zmq_sock_err, j.buffer, NULL) == -1) {
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
        zabbix_log(LOG_LEVEL_ERR, "Error opening recovery, file: %s, error: %s",
            ctx->recovery_file, strerror(errno));
        return;
    }
    
    __update_recovery(ctx, msg);
}
