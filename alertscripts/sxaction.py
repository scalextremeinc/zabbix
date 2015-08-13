#!/usr/bin/env python
import logging
import os
import sys 
import urllib
import urllib2

LOG = logging.getLogger(__name__)

REQUEST_HEADERS = {
    "Content-Type": "application/x-www-form-urlencoded",
    "Accept": "text/plain"}

def sxaction(url, user, passwd, action_payload):
    if not LOG.isEnabledFor(logging.DEBUG):
        LOG.info('Action, payload: %.120s ...', action_payload)

    data = urllib.urlencode({
        'username': user,
        'password': passwd,
        'data': action_payload
    })

    LOG.debug('Request, url: %s, data: %s', url, data)

    request = urllib2.Request(url, data, REQUEST_HEADERS)
    response = urllib2.urlopen(request)

    if LOG.isEnabledFor(logging.DEBUG):
        LOG.debug('Response, code: %s, data: %s',
                response.getcode(), response.read())

if __name__ == '__main__':
    log_dir = os.environ.get('LOG_DIR', '/var/log')
    log_file = os.path.join(log_dir, 'sxaction.log')
    log_level = os.environ.get('ACTION_LOG_LEVEL', 'INFO').upper()
    logging.basicConfig(filename=log_file, level=logging.getLevelName(log_level),
            format='%(levelname)s - %(asctime)s - %(name)s - %(message)s')

    sx_action_url = os.environ.get('SX_ACTION_URL', 'SX_ACTION_URL_ENV_MISSING')
    sx_user = os.environ.get('SX_USER', 'SX_USER_ENV_MISSING')
    sx_pass = os.environ.get('SX_PASS', 'SX_PASS_ENV_MISSING')
    action_payload = sys.argv[3]
    
    sxaction(sx_action_url, sx_user, sx_pass, action_payload)
