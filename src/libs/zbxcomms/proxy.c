#ifdef WIN32
//    #include <windows.h>
    #include <winhttp.h>
#pragma warning(disable: 4995)
#else
    #include <stdlib.h>
    #include <stdio.h>
    #include <string.h>
    #include <unistd.h>
    #include <sys/types.h>
    #include <sys/socket.h>
    #include <arpa/inet.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    #include <netdb.h>
    #include <errno.h>

    #define closesocket(A) close(A)
#endif
#define nil NULL
#define fprint zabbix_log
#define STDERR LOG_LEVEL_DEBUG
#undef strcpy
#undef sprintf

#include "proxy.h"

#ifndef STDERR
#define STDERR 2
#endif

static const char base64_digits[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static const unsigned char base64_values[] =
{
    255, 255, 255, 255, 255, 255, 255, 255, /* 0x00 - 0x08 */
    255, 255, 255, 255, 255, 255, 255, 255, /* 0x09 - 0x0F */
    255, 255, 255, 255, 255, 255, 255, 255, /* 0x10 - 0x18 */
    255, 255, 255, 255, 255, 255, 255, 255, /* 0x19 - 0x1F */
    255, 255, 255, 255, 255, 255, 255, 255, /* 0x20 - 0x28 */
    255, 255, 255,  62, 255, 255, 255,  63, /* 0x29 - 0x2F */
     52,  53,  54,  55,  56,  57,  58,  59, /* 0x30 - 0x38 */
     60,  61, 255, 255, 255, 255, 255, 255, /* 0x39 - 0x3F */
    255,   0,   1,   2,   3,   4,   5,   6, /* 0x40 - 0x48 */
      7,   8,   9,  10,  11,  12,  13,  14, /* 0x49 - 0x4F */
     15,  16,  17,  18,  19,  20,  21,  22, /* 0x50 - 0x58 */
     23,  24,  25, 255, 255, 255, 255, 255, /* 0x59 - 0x5F */
    255,  26,  27,  28,  29,  30,  31,  32, /* 0x60 - 0x68 */
     33,  34,  35,  36,  37,  38,  39,  40, /* 0x69 - 0x6F */
     41,  42,  43,  44,  45,  46,  47,  48, /* 0x70 - 0x78 */
     49,  50,  51, 255, 255, 255, 255, 255  /* 0x79 - 0x7F */
};

static void base64_encode( const char * string, char * encoded, unsigned int encodedsize )
{
    int buflen = 0, c1, c2, c3;
    int datasize = strlen( string );
    encodedsize--;

    while ( datasize )
    {
        c1 = (unsigned char) *string++;
        encoded[buflen++] = base64_digits [c1>>2];

        if ( buflen == encodedsize )
            break;

        if ( --datasize == 0 )
            c2 = 0;
        else
            c2 = (unsigned char) *string++;

        encoded[buflen++] = base64_digits [((c1 & 0x3)<< 4) | ((c2 & 0xF0) >> 4)];

        if ( buflen == encodedsize )
            break;

        if ( datasize == 0 )
        {
            encoded[buflen++] = '=';
            encoded[buflen++] = '=';
            break;
        }

        if ( --datasize == 0 )
            c3 = 0;
        else
            c3 = (unsigned char) *string++;

        encoded[buflen++] = base64_digits [((c2 & 0xF) << 2) | ((c3 & 0xC0) >>6)];

        if ( buflen == encodedsize )
            break;

        if ( datasize == 0 )
        {
            encoded[buflen++] = '=';
            break;
        }

        --datasize;
        encoded[buflen++] = base64_digits [c3 & 0x3F];

        if ( buflen == encodedsize )
            break;
    }

    encoded[buflen] = '\0';
}

// Returns one of the following
#define PROXY_INFO_NONE     0
#define PROXY_INFO_INVALID  1
#define PROXY_INFO_VALID    2

static int get_proxy_info( struct sockaddr_in * proxyaddr, char * username, char * password, unsigned int userpasssize )
{
    char proxynameport[2048];
    char proxybuf[2048];
    char *pu=nil, *pp=nil;
    int portnum;
    const char * proxydata = NULL;

#if defined (WINDOWS)
    WINHTTP_CURRENT_USER_IE_PROXY_CONFIG ieProxyConfig;

    // ***
    WINHTTP_PROXY_INFO proxyInfo;

    if ( !WinHttpGetIEProxyConfigForCurrentUser( &ieProxyConfig ) ) {
        // will fails on Win2008
        fprint(STDERR, ">>Monitord: Unable to get IE Proxy Setting.\n");
        goto GET_PROXY_REGISTRY;
        // return PROXY_INFO_NONE; // no proxy
    } else {
        if ( ieProxyConfig.lpszProxy == NULL ) {
            fprint(STDERR, ">>Monitord: IE Proxy information is NULL.\n");
            goto GET_PROXY_REGISTRY;
        } else {
            WideCharToMultiByte( CP_ACP, 0, ieProxyConfig.lpszProxy, -1, proxynameport, sizeof(proxynameport), 0, 0 );
            fprint(STDERR,">>Monitord: IE Proxy Config info: %s\n", proxynameport);
            goto GET_UN_PW;
        }
    }

GET_PROXY_REGISTRY:
    // Retrieve the default proxy configuration.
    if ( ! WinHttpGetDefaultProxyConfiguration( &proxyInfo ) ) {
        fprint(STDERR, ">>Monitord: Unable tp get Default Proxy Configuration\n");
        goto GET_PROXY_ADDR;
    } else {
        // Since we are not using this information,
        // check the bypass list and free memory
        // allocated to this string.
        if (proxyInfo.lpszProxyBypass != NULL)
        {
            GlobalFree( proxyInfo.lpszProxyBypass );
        } else {
            fprint(STDERR,">>Monitord: Default Proxy bypass is NULL\n");
        }

        // Extract the proxy servers and free memory
        // allocated to this string.
        if (proxyInfo.lpszProxy != NULL)
        {
            WideCharToMultiByte( CP_ACP, 0, proxyInfo.lpszProxy, -1, proxynameport, sizeof(proxynameport), 0, 0 );
            fprint(STDERR,">>Monitord: Default Proxy Configuration: %s\n", proxynameport);
            GlobalFree( proxyInfo.lpszProxy );
            goto GET_UN_PW;
        } else {
            fprint(STDERR,">>Monitord: Default Proxy Configuration is NULL\n");
            goto GET_PROXY_ADDR;
        }

    }

GET_PROXY_ADDR:
    // check environmental variable
    proxydata = getenv( "https_proxy" );

    //fprint(STDERR, "https_proxy=%s\n", proxydata);

    if ( !proxydata )
        proxydata = getenv( "HTTPS_PROXY" );

    if ( !proxydata ) {
        fprint(STDERR, ">>Monitord: HTTPS_PROXY is not set.\n");
        return PROXY_INFO_NONE; // no proxy
    } else {
        // Minimum length should be at least 9 bytes (1.1.1.1:1)
        if ( strlen( proxydata ) < 9 || strlen( proxydata ) > sizeof(proxybuf) - 2 ) {
            return PROXY_INFO_INVALID;
        }
        // Strip the https:// prefix if it has one
        if (strncmp(proxydata, "http://", 7) == 0)
            strcpy( proxynameport, proxydata + 7 );
        if (strncmp(proxydata, "https://", 8) == 0)
            strcpy( proxynameport, proxydata + 8 );
        else
            strcpy( proxynameport, proxydata);
    }

GET_UN_PW:
    pu = getenv( "https_proxy_username" );

    if ( !pu )
        pu = getenv( "HTTPS_PROXY_USERNAME" );

    pp = getenv( "https_proxy_password" );

    if ( !pp )
        pp = getenv( "HTTPS_PROXY_PASSWORD" );

    if ( pu && pp )
    {
        // Sanitize the username/password
        if ( strlen( pu ) > userpasssize || strlen( pp ) > userpasssize )
            return PROXY_INFO_INVALID;
        memset(username, 0, sizeof username);
        memset(password, 0, sizeof password);
        // Copy the relevant fields
        strcpy( username, pu );
        strcpy( password, pp );
    }
#else
    proxydata = getenv( "https_proxy" );

    if ( !proxydata )
        proxydata = getenv( "HTTPS_PROXY" );

    if ( !proxydata ) {
        fprint(STDERR, ">>Monitord: bad proxy env variable\n");
        return PROXY_INFO_NONE; // no proxy
    }

    // Minimum length should be at least 9 bytes (1.1.1.1:1)
    if ( strlen( proxydata ) < 9 || strlen( proxydata ) > sizeof(proxybuf) - 2 ) {
        fprint(STDERR, ">>Monitord: bad proxy length 9\n");
        return PROXY_INFO_INVALID;
    }

    // Reset the credentials
    username[0] = '\0';
    password[0] = '\0';

    // Strip the https:// prefix if it has one
    if (strncmp(proxydata, "http://", 7) == 0)
        strcpy( proxybuf, proxydata + 7 );
    if (strncmp(proxydata, "https://", 8) == 0)
        strcpy( proxybuf, proxydata + 8 );
    else
        strcpy( proxybuf, proxydata);

    // Does the string have the username/password part?
    pu = strchr( proxybuf, '@' );
    pp = strchr( proxybuf, ':' );

    // A colon must be before @ as we always have a : separating the ip:port
    if ( pu && pp && pp < pu )
    {
        // Null-terminate the username
        *pp++ = '\0';

        // Null-terminate the password
        *pu++ = '\0';

        // proxybuf now points to the username
        // pp now points to the password part
        // pu now points to the domain name

        // Sanitize the username/password
        if ( strlen( proxybuf ) > userpasssize || strlen( pp ) > userpasssize ) {
            fprint(STDERR, ">>Monitord: proxy: bad user/password length\n");
            return PROXY_INFO_INVALID;
        }

        // Copy the relevant fields
        strcpy( username, proxybuf );
        strcpy( password, pp );

        // And move the rest of the string back, including the trailing \0
        memmove( proxybuf, pu, strlen(pu) + 1 );
    }
    else
    {
        // There is one more way to define credentials as specified in Crypt::SSLeay
        pu = getenv( "https_proxy_username" );

        if ( !pu )
            pu = getenv( "HTTPS_PROXY_USERNAME" );

        pp = getenv( "https_proxy_password" );

        if ( !pp )
            pp = getenv( "HTTPS_PROXY_PASSWORD" );

        if ( pu && pp )
        {
            // Sanitize the username/password
            if ( strlen( pu ) > userpasssize || strlen( pp ) > userpasssize ) {
                fprint(STDERR, ">>Monitord: proxy: bad user/password length\n");
                return PROXY_INFO_INVALID;
            }

            // Copy the relevant fields
            strcpy( username, pu );
            strcpy( password, pp );
        }
    }

    // Copy the data
    strcpy( proxynameport, proxybuf );
#endif

    // Now parse the proxy addr:port
    pp = strchr( proxynameport, ':' );

    if ( !pp )
        return PROXY_INFO_INVALID;

    // Null-terminate the domain/ip; pp points to the port number
    *pp++ = '\0';

    // Validate the port
    portnum = atoi( pp );

    fprint(STDERR, ">>Monitord: proxynameport=%s portnum=%d\n", proxynameport, portnum);

    if ( portnum < 1 || portnum > 65535 )
        return PROXY_INFO_INVALID;

    // Validate the domain or IP
    proxyaddr->sin_addr.s_addr = inet_addr( proxynameport );

    if ( proxyaddr->sin_addr.s_addr == INADDR_NONE )
    {
        struct hostent * host_ent = gethostbyname( proxynameport );

        if ( !host_ent )
            return PROXY_STATUS_INVALID;

        proxyaddr->sin_addr.s_addr = ((struct in_addr *)(host_ent->h_addr))->s_addr;
    }

    // Fill up the rest of the structure
    proxyaddr->sin_family = AF_INET;
    proxyaddr->sin_port = htons( portnum );

    return PROXY_INFO_VALID;
}

// Returns proxy status; if not 'connected', should connect via regular means
static int proxy_try_connect( struct sockaddr_in * saddr, unsigned int saddr_size, int * status )
{
    struct sockaddr_in proxyaddr;
    char username[512];
    char password[512];
    char buf[4096];
    int length, sock, ofst;
    char *p;
    int querystatus;

    memset( &proxyaddr, 0, sizeof(proxyaddr) );
    memset(username, 0, sizeof username);
    memset(password, 0, sizeof password);

    // Do we need to use the proxy?
    querystatus = get_proxy_info( &proxyaddr, username, password, sizeof(username) );

    if ( querystatus == PROXY_INFO_NONE )
    {
        *status = PROXY_STATUS_NOT_USED;
        return -1;
    }

    if ( querystatus == PROXY_INFO_INVALID )
    {
        *status = PROXY_STATUS_INVALID;
        return -1;
    }
    memset(buf, 0, sizeof buf);

    sprintf( buf, "CONNECT %s:%d HTTP/1.1\015\012", inet_ntoa( saddr->sin_addr ), ntohs( saddr->sin_port ) );
    sprintf(buf+strlen(buf), "HOST: %s:%d\015\012", inet_ntoa(saddr->sin_addr), ntohs(saddr->sin_port));
    if ( username[0] != '\0' )
    {
        char passtpl[128], passencoded[512];
        memset(passtpl, 0, sizeof passtpl);
        memset(passencoded, 0, sizeof passencoded);
        sprintf (passtpl, "%s:%s", username, password );

        base64_encode( passtpl, passencoded, sizeof(passencoded) );
        sprintf( buf + strlen(buf), "Proxy-Authorization: Basic %s\015\012", passencoded );
    }

    strcat( buf, "Proxy-Connection: Keep-Alive\015\012");
    strcat( buf, "User-Agent: Mitos\015\012" );
    strcat( buf, "\015\012" );
    length = strlen(buf);

    fprint (STDERR, "\n\nbuf=%s\n\n", buf);

    // Create a socket
    sock = socket( AF_INET, SOCK_STREAM, 0 );

    if ( sock == -1 ) {
        fprint(STDERR, ">>Monitord: Fail tp create socket\n");
        goto failed;
    }

    // We got a valid proxy. Try to connect to it first.
    if ( connect( sock, (struct sockaddr *) &proxyaddr, sizeof(proxyaddr) ) != 0 )
    {
        closesocket( sock );
        *status = PROXY_STATUS_REFUSED;
        return -1;
    }

    fprint(STDERR, "\n\nSend Data=%s\n\n", buf);

    // Send it
    if ( send( sock, buf, length, 0) != length )
        goto failed;

    // Receive the proxy response.
    // Since we do not know the length of response, and the rest of it is not ours,
    // we need to do it byte-by-byte
    ofst = 0;

    while ( 1 )
    {
        int amount;
        if ( ofst >= sizeof(buf) )
            goto failed;

        amount = recv( sock, buf + ofst, 1, 0 );

        if ( amount <= 0 )
            goto failed;

        ofst += amount;
        buf[ofst] = '\0';

        if ( strstr(buf, "\015\012\015\012") )
            break;
    }

    fprint(STDERR, "\n\nbuf=%s\n\n", buf);
    // Parse the response; must start with HTTP/
    p = strchr( buf, ' ' );

    if ( !p || buf[0] != 'H' || buf[1] != 'T' || buf[2] != 'T' || buf[3] != 'P' || buf[4] != '/' )
        goto failed;

    // Find the status code
    while ( *p == ' ' )
        p++;

    // Verify the status code
    if ( p[0] == '2' && p[1] == '0' && p[2] == '0' )
    {
        *status = PROXY_STATUS_CONNECTED;
        return sock;
    }

    if ( p[0] == '4' && p[1] == '0' && p[2] == '7' )
    {
        closesocket( sock );
        *status = PROXY_STATUS_AUTH_FAILED;
        return -1;
    }

failed:
    closesocket( sock );
    *status = PROXY_STATUS_FAILED;
    return -1;
}

int proxy_connect( struct sockaddr * saddr, unsigned int saddr_size, int * status )
{
    // Try to connect via proxy first
    int sock = proxy_try_connect( (struct sockaddr_in *) saddr, saddr_size, status );

    // Set the status (either no proxy or invalid)
    if ( *status == PROXY_STATUS_CONNECTED ) {
        fprint(STDERR, ">>Monitord: Successfully connect to proxy.\n" );
        return sock;
    } else {
        fprint(STDERR, ">>Monitord: Cannot connect to proxy. Status=%d\n", *status );
    }

    fprint(STDERR, ">>Monitord: Attempt to connect directly.\n" );

    // Proxy connection failed; create another socket, and connect it
    sock = socket( AF_INET, SOCK_STREAM, 0 );
    if ( sock < 0 ) {
        fprint(STDERR, ">>Monitord: Fail to create socket. sock=%d\n", sock );
        return -1;
    }

    if ( connect( sock, saddr, saddr_size ) == 0 ) {
         return sock;
    } else
        fprint(STDERR, ">>Monitord: Fail to connect. sock=%d\n", sock);

    closesocket( sock );
    return -1;
}
