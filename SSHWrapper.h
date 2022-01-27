//
//  SSHWrapper.h
//  libssh2-for-iOS
//
//  Created by Felix Schulze on 01.02.11.
//  Copyright 2010 Felix Schulze. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "stdafx.h"
/*
#include "libssh2.h"
#include "libssh2_config.h"
#include "libssh2_sftp.h"
#include <sys/socket.h>
#include <arpa/inet.h>
#include <openssl/opensslv.h>
#include "libssh2.h"
#include "gcrypt.h"
*/
@interface SSHWrapper : JWSlideMenuViewController {

}
@property (retain, nonatomic) UITextView *ShellView;
- (NSString *)connectToHost:(NSString *)host port:(int)port user:(NSString *)user password:(NSString *)password error:(NSError **)error;
- (void)closeConnection;
- (NSString *)executeCommand:(NSString *)command;
-(NSString *)sshPtyRrecive:(NSString *)command;
- (void)closePtySession;
- (NSString *)scpDownload:(NSString *)FileName;
- (NSString *)scpFileStat:(NSString *)FileName;
- (NSString *)scpUpload:(NSString *)LocalFileName SCP_FileName:(NSString *)SCP_FileName;
- (BOOL)portForward:(NSString *)server local_host:(NSString *)local_host local_listenport:(int)local_listenport remote_host:(NSString *)remote_host remote_destport:(int)remote_destport aport:(int)aport;
@end
