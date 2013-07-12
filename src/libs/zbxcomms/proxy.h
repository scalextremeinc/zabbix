#ifndef INCLUDE_PROXY_H
#define INCLUDE_PROXY_H

//
// Proxy support for SSL connections.
// gyunaev@scalextreme.com
//
// Current restrictions:
// - Only the HTTP proxy with Netscape SSL extension (i.e. CONNECT) is supported;
// - Only basic proxy authentication is supported, no NTLM.
//

//
// Proxy status values
//

// No SSL proxy was set, so none was used
#define PROXY_STATUS_NOT_USED		(0)

// Successfully connected via SSL proxy
#define PROXY_STATUS_CONNECTED		(1)

// Proxy is set but the parameters are invalid (i.e. invalid domain/port)
#define PROXY_STATUS_INVALID		(2)

// Proxy is not reachable/erroneous (failed to connect to proxy, proxy sent the empty or invalid responce).
#define PROXY_STATUS_FAILED			(3)

// Proxy authentication failed / unsupported authentication method
#define PROXY_STATUS_AUTH_FAILED	(4)

// Proxy refused connect to a specific ip:port (most likely the port was not 443, or prevented by the policy)
#define PROXY_STATUS_REFUSED		(5)


// This function creates a TCP AF_INET socket and connects it to a specific IP/domain and port using the HTTPS proxy.
// It returns the socket.
//
// If no HTTPS proxy is set in settings, this function sets status to PROXY_STATUS_NOT_USED, and tries to connect
// using the regular connect() function.
//
// If the HTTPS proxy is set, tries to connect through the proxy, using the authentication if possible. If connect fails,
// tries to connect directly (connect through the HTTPS proxy to a port other than 443 is most likely to fail).
//
// Return the socket descriptor and sets the status to PROXY_STATUS_* value above.
int proxy_connect( struct sockaddr * saddr, unsigned int saddr_size, int * status );


#endif // INCLUDE_PROXY_H
