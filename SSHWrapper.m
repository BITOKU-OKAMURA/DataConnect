//
// SSHWrapper.m
// libssh2-for-iOS
//
// Created by Felix Schulze on 01.02.11.
// Copyright 2010 Felix Schulze. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// @see: http://www.libssh2.org/examples/ssh2_exec.html

#import "SSHWrapper.h"

#include "libssh2.h"
#include "libssh2_config.h"
#include "libssh2_sftp.h"
#include <sys/socket.h>
#include <arpa/inet.h>


#ifdef WIN32
#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#else
#include <netinet/in.h>
#include <sys/time.h>
#endif

#include <fcntl.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <netdb.h>
#include <netinet/in.h>

#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif

#ifndef INADDR_NONE
#define INADDR_NONE (in_addr_t)-1
#endif
#import "Reachability.h"

static int waitsocket(int socket_fd, LIBSSH2_SESSION *session)
{
    struct timeval timeout;
    int rc;
    fd_set fd;
    fd_set *writefd = NULL;
    fd_set *readfd = NULL;
    int dir;
    
    timeout.tv_sec = 10;
    timeout.tv_usec = 0;
    
    FD_ZERO(&fd);
    
    FD_SET(socket_fd, &fd);
    
    /* now make sure we wait in the correct direction */
    dir = libssh2_session_block_directions(session);
    
    if(dir & LIBSSH2_SESSION_BLOCK_INBOUND)
        readfd = &fd;
    
    if(dir & LIBSSH2_SESSION_BLOCK_OUTBOUND)
        writefd = &fd;
    
    rc = select(socket_fd + 1, readfd, writefd, NULL, &timeout);
    
    return rc;
}

@implementation SSHWrapper {
    int sock;
    LIBSSH2_SESSION *session;
    //LIBSSH2_CHANNEL *channel;
    LIBSSH2_CHANNEL *pty_channel;
    LIBSSH2_CHANNEL *dl_channel;
    LIBSSH2_CHANNEL *scp_channel;
    LIBSSH2_CHANNEL *stat_channel;
    int rc;
}

- (void)dealloc {
    [self closeConnection];
    session = nil;
    //channel = nil;
}

- (NSString *)scpFileStat:(NSString *)FileName {
    const char *scppath=[FileName cStringUsingEncoding:NSUTF8StringEncoding];
    struct stat fileinfo;
    NSString *result;

    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        return @"NetWork Error.";

    while( (stat_channel = libssh2_scp_recv(session, scppath, &fileinfo)) == NULL &&
          libssh2_session_last_error(session,NULL,NULL,0) == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket(sock, session);
    }
    if (!stat_channel) {
        return @"File Status Error.";
    }
    result = [NSString stringWithFormat:@"%@ %@Byte", 
                [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:fileinfo.st_mtime]],
                [self KMByteStrings:(long)fileinfo.st_size]
            ];

    while( (rc = libssh2_channel_close(stat_channel)) == LIBSSH2_ERROR_EAGAIN )
        waitsocket(sock, session);
    libssh2_channel_free(stat_channel);
    stat_channel = NULL;
    return !result ? @"" : result;
}

- (NSString *)scpDownload:(NSString *)FileName {
    NSString *LocalFileName = [NSString stringWithFormat: @"%@/%@/%@",self.DocumentPath,[[NSUserDefaults standardUserDefaults] stringForKey:@"ConnectServer"],FileName];
    NSString *folder = [LocalFileName stringByReplacingOccurrencesOfString:LocalFileName.lastPathComponent withString:@""];
    const char *scppath=[FileName cStringUsingEncoding:NSUTF8StringEncoding];
    const char* file = [LocalFileName cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *result;
    [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    FILE *fp = fopen(file,"w");
    struct stat fileinfo;
    off_t got=0;

    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        return @"NetWork Error.";

    /* Exec non-blocking on the remove host */
    while( (dl_channel = libssh2_scp_recv(session, scppath, &fileinfo)) == NULL &&
          libssh2_session_last_error(session,NULL,NULL,0) == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket(sock, session);
    }
    if (!dl_channel) {
        return @"Unable to open a session";
    }
    while(got < fileinfo.st_size) {
        char mem[1024];
        int amount=sizeof(mem);
        if((fileinfo.st_size -got) < amount) {
            amount = (int)fileinfo.st_size - (int)got;
        }

        while ((rc = libssh2_channel_read(dl_channel, mem, amount)) == LIBSSH2_ERROR_EAGAIN)
            waitsocket(sock, session);

        if(rc > 0) {
            fwrite(mem, rc , 1 , fp);
        }
        else if(rc < 0) {
            result = [NSString stringWithFormat: @"libssh2_channel_read() failed: %d",rc];
            break;
        }
        got += rc;
    }
    fclose(fp);
    while( (rc = libssh2_channel_close(dl_channel)) == LIBSSH2_ERROR_EAGAIN )
        waitsocket(sock, session);
    libssh2_channel_free(dl_channel);
    dl_channel = NULL;
    return !result ? @"" : result;
}

- (NSString *)scpUpload:(NSString *)LocalFileName SCP_FileName:(NSString *)SCP_FileName {
    const char *loclfile=[LocalFileName cStringUsingEncoding:NSUTF8StringEncoding];
    const char *scppath=[SCP_FileName cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *result;
    struct stat fileinfo;
    stat(loclfile, &fileinfo);
    size_t nread;
    char mem[8192];
    char *ptr;
    FILE *local;
    local = fopen(loclfile, "rb");
    if (!local) 
        return [NSString stringWithFormat: @"Can't open local file %s", loclfile];

    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        return @"NetWork Error.";

    /* Exec non-blocking on the remove host */
    while( (dl_channel = libssh2_scp_send(session, scppath, fileinfo.st_mode & 0777,
                               (unsigned long)fileinfo.st_size)) == NULL &&
          libssh2_session_last_error(session,NULL,NULL,0) == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket(sock, session);
    }
    if (!dl_channel) {
        return @"Unable to open a session";
    }

    do {
        nread = fread(mem, 1, sizeof(mem), local);
        if (nread <= 0) {
            /* end of file */
            break;
        }
        ptr = mem;

        do {
            /* write the same data over and over, until error or completion */
            rc = libssh2_channel_write(dl_channel, ptr, nread);
            if (rc < 0) {
                result = [NSString stringWithFormat: @"ERROR %d",rc];
                break;
            }
            else {
                /* rc indicates how many bytes were written this time */
                ptr += rc;
                nread -= rc;
            }
        } while (nread);
    } while (1);

    while( (rc = libssh2_channel_close(dl_channel)) == LIBSSH2_ERROR_EAGAIN )
        waitsocket(sock, session);
    libssh2_channel_free(dl_channel);
    dl_channel = NULL;
    return !result ? @"" : result;
    
}


- (NSString *)connectToHost:(NSString *)host port:(int)port user:(NSString *)user password:(NSString *)password error:(NSError **)error {
    if (host.length == 0) {
        return @"No Host";
    }
    
    if(session != NULL)
        return @"Already Connected";

    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        return @"NetWork Error.";

    NSFileManager *FileManager = [[NSFileManager alloc] init];
    NSString *NSFile2 = [NSString stringWithFormat: @"%@/%@/.ssh/id_rsa",self.DocumentPath,host];
    NSString *NSFile1 = [NSString stringWithFormat: @"%@/%@/.ssh/id_rsa.pub",self.DocumentPath,host];

    const char* hostChar     = [host cStringUsingEncoding:NSUTF8StringEncoding];
    const char* userChar     = [user cStringUsingEncoding:NSUTF8StringEncoding];
    const char* passwordChar = [password cStringUsingEncoding:NSUTF8StringEncoding];
    struct sockaddr_in sock_serv_addr;
    struct hostent *host2ip = gethostbyname(hostChar);
    unsigned long hostaddr = (host2ip != NULL) ? *(unsigned int *)(host2ip->h_addr_list[0]) : inet_addr(hostChar);
    
    sock                           = socket(AF_INET, SOCK_STREAM, 0);
    sock_serv_addr.sin_family      = AF_INET;
    sock_serv_addr.sin_port        = htons(port);
    sock_serv_addr.sin_addr.s_addr = (int)hostaddr;
    if (connect(sock, (struct sockaddr *) (&sock_serv_addr), sizeof(sock_serv_addr)) != 0)
        return @"Failed to connect\n";
    
    /* Create a session instance */
    session = libssh2_session_init();
    if (!session)
        return @"Create session failed";
    
    /* tell libssh2 we want it all done non-blocking */
    libssh2_session_set_blocking(session, 0);
    
    /* ... start it up. This will trade welcome banners, exchange keys,
     * and setup crypto, compression, and MAC layers
     */
    while ((rc = libssh2_session_startup(session, sock)) ==
           LIBSSH2_ERROR_EAGAIN)
        waitsocket(sock, session);
    if (rc){
        [self closeConnection];
        return @"Failure establishing SSH session";
    }
    
    //if([FileManager fileExistsAtPath:NSFile1] && [FileManager fileExistsAtPath:NSFile2]){
    if([FileManager fileExistsAtPath:NSFile2]){
        // while ((rc = libssh2_userauth_publickey_fromfile(session, userChar,[NSFile1 cStringUsingEncoding:NSUTF8StringEncoding],[NSFile2 cStringUsingEncoding:NSUTF8StringEncoding],passwordChar)) == LIBSSH2_ERROR_EAGAIN)
        while ((rc = libssh2_userauth_publickey_fromfile(session, userChar,[FileManager fileExistsAtPath:NSFile1] ? [NSFile1 cStringUsingEncoding:NSUTF8StringEncoding] : NULL,[NSFile2 cStringUsingEncoding:NSUTF8StringEncoding],passwordChar)) == LIBSSH2_ERROR_EAGAIN)
            waitsocket(sock, session);
        if (rc){
            [self closeConnection];
            return @"Authenticating with key failed.";
        }
    } else {
        if ( strlen(passwordChar) != 0 ) {
            
            while ((rc = libssh2_userauth_password(session, userChar, passwordChar)) == LIBSSH2_ERROR_EAGAIN)
                waitsocket(sock, session);
            if (rc){
                [self closeConnection];
                return @"Authentication by password failed.";
            }
        }
    }
    if(session == NULL)
        return @"No Makeing Session.";
    return @"";
}

- (NSString *)executeCommand:(NSString *)command {
    const char* commandChar = [command cStringUsingEncoding:NSUTF8StringEncoding];
    NSString *result;

    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        return @"";

    /* Exec non-blocking on the remove host */
    while( (scp_channel = libssh2_channel_open_session(session)) == NULL &&
          libssh2_session_last_error(session,NULL,NULL,0) == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket(sock, session);
    }
    if( scp_channel == NULL )
    {
        //*error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:501 userInfo:@{NSLocalizedDescriptionKey : @"No channel found."}];
        NSLog(@"No channel found.\n");
        return @"";
    }
    while( (rc = libssh2_channel_exec(scp_channel, commandChar)) == LIBSSH2_ERROR_EAGAIN )
    {
        waitsocket(sock, session);
    }
    if( rc != 0 )
    {
        //*error = [NSError errorWithDomain:@"de.felixschulze.sshwrapper" code:502 userInfo:@{NSLocalizedDescriptionKey : @"Error while exec command."}];
        NSLog(@"Error while exec command.\n");
        return @"";
    }
    for( ;; )
    {
        /* loop until we block */
        int rc1;
        do
        {
            char buffer[0x2000];
            memset(buffer,'\0',sizeof(buffer));
            ;
            
            while( (rc1 = (int)libssh2_channel_read( scp_channel, buffer, sizeof(buffer)-1 )) == LIBSSH2_ERROR_EAGAIN )
                waitsocket(sock, session);
            
            if( rc1 > 0 )
            {
                result = @(buffer);
            }
        }
        while( rc1 > 0 );
        
        /* this is due to blocking that would occur otherwise so we loop on
         this condition */
        if( rc1 == LIBSSH2_ERROR_EAGAIN )
        {
            waitsocket(sock, session);
        }
        else
            break;
    }
    while( (rc = libssh2_channel_close(scp_channel)) == LIBSSH2_ERROR_EAGAIN )
        waitsocket(sock, session);
    
    while( (rc = libssh2_channel_close(scp_channel)) == LIBSSH2_ERROR_EAGAIN )
        waitsocket(sock, session);
    libssh2_channel_free(scp_channel);
    scp_channel = NULL;
    
    return !result ? @"" : result;
    
}

-(NSString *)sshPtyRrecive:(NSString *)command{
    NSMutableString *result = [[NSMutableString alloc] init];
    char buffer[0xC000];
    char ctrlC[5];
    ctrlC[0] = '\x03';
    ctrlC[1] = '\x20';
    ctrlC[2] = '\n';
    //ctrlC[3] = '\n';
    ctrlC[3] = '\0';
    const char* cs_command     = ([command isEqualToString:@"_vannira"]) ? ctrlC : [command cStringUsingEncoding:NSUTF8StringEncoding];
//closePtySession
    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        return @"NetWork Error.";
/*
    if([command isEqualToString:@"_vannira"]){
        libssh2_channel_flush(pty_channel);
        rc = libssh2_channel_write_ex(pty_channel,0,ctrlC, strlen(ctrlC));
        while( (libssh2_channel_read( pty_channel, buffer, sizeof(buffer)-1 )) == LIBSSH2_ERROR_EAGAIN )
            waitsocket(sock, session);
    }
*/
    if( pty_channel == NULL ){
        while( (pty_channel = libssh2_channel_open_session(session)) == NULL && libssh2_session_last_error(session,NULL,NULL,0) == LIBSSH2_ERROR_EAGAIN )
            waitsocket(sock, session);
        if( pty_channel == NULL )
            return @"No pty_channel found.";
        while ((rc=libssh2_channel_request_pty(pty_channel, "vanilla") == LIBSSH2_ERROR_EAGAIN))
            waitsocket(sock, session);
        if (rc)
            return [NSString stringWithFormat: @"Failed requesting pty rc=%d",rc];
        while ((rc = libssh2_channel_shell(pty_channel)) == LIBSSH2_ERROR_EAGAIN)
            waitsocket(sock, session);
        if (rc)
            return [NSString stringWithFormat: @"Unable to request shell on allocated pty=%d",rc];
    }

    if(cs_command && strlen(cs_command) > 1){
        libssh2_channel_flush(pty_channel);
        rc = libssh2_channel_write_ex(pty_channel,0,cs_command, strlen(cs_command));
    }
    int rc37Count =0;
    while ([result length] < 1 || [[result substringWithRange:NSMakeRange([result length]-1, 1)] isEqualToString:@"\n"]) {
        memset(buffer,'\0',sizeof(buffer));
        rc = (int)libssh2_channel_read( pty_channel, buffer, sizeof(buffer)-1 );
        if( rc > 0 ){
            [result appendString:@(buffer)];
            rc37Count =0;
        }
        else
            rc37Count++;
        if(rc37Count >0xC000){
            break;
        }
    }

    if([command isEqualToString:@"_vannira"] || rc37Count >0xC000){
        [self closePtySession];
        [self sshPtyRrecive:@"\n"];
    }

    return result;
}

- (void)closeConnection {

    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        return;

    if(scp_channel){
        while( (rc = libssh2_channel_close(scp_channel)) == LIBSSH2_ERROR_EAGAIN )
            waitsocket(sock, session);
        libssh2_channel_free(scp_channel);
        scp_channel = NULL;
    }
    if(dl_channel){
        while( (rc = libssh2_channel_close(dl_channel)) == LIBSSH2_ERROR_EAGAIN )
            waitsocket(sock, session);
        libssh2_channel_free(dl_channel);
        dl_channel = NULL;
    }
    if(pty_channel){
        while( (rc = libssh2_channel_close(pty_channel)) == LIBSSH2_ERROR_EAGAIN )
            waitsocket(sock, session);
        libssh2_channel_free(pty_channel);
        pty_channel = NULL;
    }
    
    if(stat_channel){
        while( (rc = libssh2_channel_close(stat_channel)) == LIBSSH2_ERROR_EAGAIN )
            waitsocket(sock, session);
        libssh2_channel_free(stat_channel);
        stat_channel = NULL;
    }
    if (session) {
        libssh2_session_disconnect(session, "Normal Shutdown, Thank you for playing");
        libssh2_session_free(session);
        session = nil;
    }
    close(sock);
}

- (void)closePtySession {

    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        return;

    if(pty_channel){
        while( (rc = libssh2_channel_close(pty_channel)) == LIBSSH2_ERROR_EAGAIN )
            waitsocket(sock, session);
        libssh2_channel_free(pty_channel);
        pty_channel = NULL;
    }
}


/**
 * tcpip-forward.c の移植
 *
 *
 * @param
 * @return
 * @exception
 * @see
 * @since
 * @deprecated
 */
- (BOOL)portForward:(NSString *)server local_host:(NSString *)local_host local_listenport:(int)local_listenport remote_host:(NSString *)remote_host remote_destport:(int)remote_destport aport:(int)aport{
    //----------------------------------------------------------
    // 前提条件の確認
    //----------------------------------------------------------
    BOOL Ret = NO;
    if(session == NULL)
        return Ret;

    if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
        return Ret;

    //----------------------------------------------------------
    // 引数の変換
    //----------------------------------------------------------
    const char* local_listenip  = [local_host cStringUsingEncoding:NSUTF8StringEncoding];
    const char *remote_desthost = [remote_host cStringUsingEncoding:NSUTF8StringEncoding];
    const char *server_ip       = [server cStringUsingEncoding:NSUTF8StringEncoding];
    
    //----------------------------------------------------------
    // 変数定義定義
    //----------------------------------------------------------
    enum {
        AUTH_NONE = 0,
        AUTH_PASSWORD,
        AUTH_PUBLICKEY
    };
    
    int listensock = -1, forwardsock = -1, i;
    struct sockaddr_in sin;
    socklen_t sinlen;
    LIBSSH2_CHANNEL *channel = NULL;
    
    const char *shost;
    unsigned int sport;
    fd_set fds;
    int sockopt;
    struct hostent *host2ip = gethostbyname(server_ip);
    
    while(1){
        sock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        sin.sin_family = AF_INET;
        if (INADDR_NONE == (sin.sin_addr.s_addr = (host2ip != NULL) ? *(unsigned int *)(host2ip->h_addr_list[0]) : inet_addr(server_ip))) {
            perror("inet_addr");
            return Ret;
        }
        sin.sin_port = htons(22);
        if (connect(sock, (struct sockaddr*)(&sin),
                    sizeof(struct sockaddr_in)) != 0) {
            fprintf(stderr, "failed to connect!\n");
            return Ret;
        }
        
        listensock = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        sin.sin_family = AF_INET;
        sin.sin_port = htons(local_listenport);
        if (INADDR_NONE == (sin.sin_addr.s_addr = inet_addr(local_listenip))) {
            perror("inet_addr");
            return Ret;
        }
        sockopt = 1;
        setsockopt(listensock, SOL_SOCKET, SO_REUSEADDR, &sockopt, sizeof(sockopt));
        sinlen = sizeof(sin);
        
        if (-1 == bind(listensock, (struct sockaddr *)&sin, sinlen)) {
            perror("bind");
            //return Ret;
        }
        if (-1 == listen(listensock, 5)) {
            perror("listen");
            return Ret;
        }
    Again2:
        fprintf(stderr, "Waiting for TCP connection on %s:%d...\n",
                inet_ntoa(sin.sin_addr), ntohs(sin.sin_port));
        
        forwardsock = accept(listensock, (struct sockaddr *)&sin, &sinlen);
        if (-1 == forwardsock) {
            perror("accept");
            return Ret;
        }
        
        shost = inet_ntoa(sin.sin_addr);
        sport = ntohs(sin.sin_port);
        
        //fprintf(stderr, "Forwarding connection from %s:%d here to remote %s:%d\n",
        // shost, sport, remote_desthost, remote_destport);
        while( (channel = libssh2_channel_direct_tcpip_ex(session, remote_desthost,
                                                          remote_destport, shost, sport)) == NULL &&
              libssh2_session_last_error(session,NULL,NULL,0) == LIBSSH2_ERROR_EAGAIN )
        {
            waitsocket(sock, session);
        }

        
        if (!channel) {
            fprintf(stderr, "Could not open the direct-tcpip channel!\n"
                    "(Note that this can be a problem at the server!"
                    " Please review the server logs.) error=%d\n",libssh2_session_last_error(session,NULL,NULL,0));
            return Ret;
        }
        
        /* Must use non-blocking IO hereafter due to the current libssh2 API */
        libssh2_session_set_blocking(session, 0);
        struct timeval tv;
        ssize_t len = 0, wr;
        char buf[16384];
        while (1) {
            memset(buf,'\0',sizeof(buf));
            FD_ZERO(&fds);
            FD_SET(forwardsock, &fds);
            tv.tv_sec  = 0;
            tv.tv_usec = 100000;
            rc = select(forwardsock + 1, &fds, NULL, NULL, &tv);
            if (-1 == rc) {
                perror("select");
                return Ret;
            }
            if (rc && FD_ISSET(forwardsock, &fds)) {
                len = recv(forwardsock, buf, sizeof(buf)-1, 0);
                if (len < 0) {
                    perror("read");
                    return Ret;
                } else if (0 == len) {
                    fprintf(stderr, "The client at %s:%d disconnected!\n", shost,
                            sport);
                    goto shutdown;
                }
                wr = 0;
                do {
                    i = libssh2_channel_write(channel, buf, len);
                    if (i < 0) {
                        fprintf(stderr, "libssh2_channel_write: %d\n", i);
                        goto shutdown;
                    }
                    wr += i;
                } while(i > 0 && wr < len);
            }
            memset(buf,'\0',sizeof(buf));
            if(rc>0 && len >0){
                while( ( len = libssh2_channel_read(channel, buf, sizeof(buf)) ) == LIBSSH2_ERROR_EAGAIN )
                {
                    waitsocket(sock, session);
                }
                
            } else
                len = libssh2_channel_read(channel, buf, sizeof(buf));
            
            if (LIBSSH2_ERROR_EAGAIN == len){
                printf("Resiv LIBSSH2_ERROR_EAGAIN rc=%d\n",rc);
                if(aport==0){
                    close(forwardsock);
                    while( (rc = libssh2_channel_close(channel)) == LIBSSH2_ERROR_EAGAIN )
                        waitsocket(sock, session);
                    //libssh2_channel_free(channel);
                    goto Again2;
                }
                else
                    goto shutdown;
            }
            else if (len < 0) {
                fprintf(stderr, "libssh2_channel_read: %d", (int)len);
                goto shutdown;
            }
            wr = 0;
            while (wr < len) {
                i = send(forwardsock, buf + wr, len - wr, 0);
                if (i <= 0) {
                    perror("write");
                    return Ret;
                }
                wr += i;
            }
            if (libssh2_channel_eof(channel)) {
                fprintf(stderr, "The server at %s:%d disconnected!\n",
                        remote_desthost, remote_destport);
                goto shutdown;
            }
        }
    shutdown:
        close(forwardsock);
        close(listensock);
        close(sock);
        while( (rc = libssh2_channel_close(channel)) == LIBSSH2_ERROR_EAGAIN )
            waitsocket(sock, session);
        libssh2_channel_free(channel);
        channel = NULL;
    }
}


@end
