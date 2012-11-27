
struct queue_ctx {
    void* zmq_ctx;
    void* zmq_sock_msg;
    void* zmq_sock_err;
    short prev_status;
};

void queue_ctx_init(struct queue_ctx* ctx);

void queue_ctx_destroy(struct queue_ctx* ctx);

void queue_sock_connect_msg(struct queue_ctx* ctx, const char* queue_addr_msg);

void queue_sock_connect_err(struct queue_ctx* ctx, const char* queue_addr_err);

void queue_msg(struct queue_ctx* ctx, const char* msg);

int queue_msg_send(void* zmq_sock, const char* msg);

void queue_msg_send_error(struct queue_ctx* ctx, const char* msg);
