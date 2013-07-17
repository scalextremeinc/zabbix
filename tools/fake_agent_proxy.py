#!/usr/bin/env python
import sys
import json
import time
import urllib2
from datetime import datetime

def zabbix_proxy_send(data, url='https://localhost/agents/data'):
    """ Sends data to spark proxy.
        POST /agents/data
    """
    sxhost = data['data'][0]['host']
    req = urllib2.Request(url, json.dumps(data), headers={'sxhost': sxhost})
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

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print "Usage: fake_agent_proxy.py /path/to/data.json https://localhost/agents/data 60 A8572C40194"
        exit(1)
    
    file = sys.argv[1]
    url = sys.argv[2]

    interval = 60
    if len(sys.argv) >= 4:
        interval = int(sys.argv[3])
    
    hostname = None
    if len(sys.argv) >= 5:
        hostname = sys.argv[4]
    
    data = open(file).read()
    data = json.loads(data)
    
    if hostname:
        update_hostname(data, hostname)
    
    while True:
        print "* Response %s: %s" % (datetime.now(), zabbix_proxy_send(update_time(data), url))
        time.sleep(interval)
