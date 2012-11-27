

void* queue_create_context();

void* queue_create_socket(void* context_zmq, const char* queue_addr);

void queue_send_msg(void* queue_socket_zmq, const char* msg);
