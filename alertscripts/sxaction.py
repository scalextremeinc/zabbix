#!/usr/bin/env python
import logging
import os
import sys 
import httplib, urllib

def sxaction(monitor_host, monitor_user, monitor_pass, action_payload):
    logging.info('Action, payload: %.120s ...', action_payload)
    params = urllib.urlencode({
        'username': monitor_user,
        'password': monitor_pass,
        'data': action_payload
    })
    headers = {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "text/plain"}
    url_path = "/monitor/api/action.php"

    logging.debug('Request POST, url: https://%s%s, headers: %s, body: %s',
            monitor_host, url_path, headers, params)
    
    conn = httplib.HTTPSConnection(monitor_host)
    conn.request("POST", url_path, params, headers)
    response = conn.getresponse()
    body = response.read()
    logging.debug('Response, code: %s %s, headers: %s, body: %s',
           response.status, response.reason, response.getheaders(), body)

if __name__ == '__main__':
    log_dir = os.environ.get('LOG_DIR', '/var/log')
    log_file = os.path.join(log_dir, 'sxaction.log')
    log_level = os.environ.get('LOG_LEVEL', 'INFO').upper()
    logging.basicConfig(filename=log_file, level=logging.getLevelName(log_level),
            format='%(levelname)s - %(asctime)s - %(name)s - %(message)s')

    monitor_host = os.environ.get('MONITORIP', 'MONITORIP_ENV_MISSING')
    monitor_user = os.environ.get('MONITORUSER', 'MONITORUSER_ENV_MISSING')
    monitor_pass = os.environ.get('MONITORPASS', 'MONITORPASS_ENV_MISSING')
    action_payload = sys.argv[3]
    
    sxaction(monitor_host, monitor_user, monitor_pass, action_payload)
