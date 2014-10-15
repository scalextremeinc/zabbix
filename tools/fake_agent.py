#!/usr/bin/env python
import sys
import socket
import struct
import json
import time
import datetime
import argparse

def zabbix_send(data, host='localhost', port=8443):
    """ Sends data directly to zabbix server """
    sock = socket.socket()
    sock.connect((host, int(port)))
    try:
        data_str = json.dumps(data)
        data_len = struct.pack('<Q', len(data_str))        
        msg = 'ZBXD\x01{data_len}{data}'.format(data_len=data_len, data=data_str)
        print "request:\n%s\n" % msg
        sock.send(msg)        
        response = sock.makefile().read()
    finally:
        sock.close()
    
    return response

def proxy_send(data, url='https://localhost/agents/data'):
    """ Sends data to spark proxy.
        POST /agents/data
    """
    sxhost = data['data'][0]['host']
    req = urllib2.Request(url, json.dumps(data), headers={'sxhost': sxhost, 
        'Content-Type': 'application/json'})
    rsp = urllib2.urlopen(req)
    return rsp.read()

def update_time(data):
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
    return data

def update_hostname(data, hostname):
    for d in data['data']:
        d['host'] = hostname
    return data

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('file', nargs='?')
    parser.add_argument('-u', '--url', help='https://localhost/agents/data')
    parser.add_argument('-s', '--sock', help='localhost:8443')
    parser.add_argument('-i', '--interval', type=int, default=60)
    parser.add_argument('-a', '--agent', help='eg: A123C123')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()

    if args.file is not None:
        fileobj = open(args.file, 'rU')
    else:
        fileobj = sys.stdin
    
    data = json.load(fileobj)
    
    if args.agent is not None:
        update_hostname(data, args.agent)
    
    while True:
        try:
            if args.url is not None:
                response = proxy_send(update_time(data), args.url)
                print "* Proxy response %s: %s" % (datetime.datetime.now(), response)
            if args.sock is not None:
                zbx_host, zbx_port = args.sock.split(':')
                response = zabbix_send(update_time(data), host=zbx_host, port=zbx_port)
                print "* Zabbix response %s: %s" % (datetime.datetime.now(), response)
        except Exception, e:
            print "Error sending: %s" % e
            time.sleep(1)
        time.sleep(args.interval)

