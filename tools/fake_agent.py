#!/usr/bin/env python
import sys
import socket
import struct
import json
import time

def zabbix_send(data, host='localhost', port=8443):
    sock = socket.socket()
    sock.connect((host, int(port)))
    try:
        data_len = struct.pack('<Q', len(data))        
        msg = 'ZBXD\x01{data_len}{data}'.format(data_len=data_len, data=data)
        print "request:\n%s\n" % msg
        sock.send(msg)        
        response = sock.makefile().read()
    finally:
        sock.close()
    
    return response

def update_time(data):
    data = json.loads(data)
    t = time.time()
    clock = int(t)
    ns = int((t - clock) * 1000000000)
    data['clock'] = clock
    data['ns'] = ns
    i = 0
    for d in data['data']:
        d['timestamp'] = clock - 502
        d['clock'] = clock
        d['ns'] = ns + i
        i += 1
    return json.dumps(data)

if __name__ == "__main__":
    # python fake_agent.py localhost 10051  ./fake_agent.json
    host = sys.argv[1]
    port = sys.argv[2]
    data = open(sys.argv[3]).read()
    data = update_time(data)
    print "* Response:\n%s\n" % zabbix_send(data, host, port)
