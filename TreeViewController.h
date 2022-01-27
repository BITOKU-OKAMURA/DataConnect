//
//  TreeViewController.h
//  kxsmb project
//  https://github.com/kolyvan/kxsmb/
//
//  Created by Kolyvan on 27.03.13.
//

/*
 Copyright (c) 2013 Konstantin Bukreev All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


#import "stdafx.h"
@interface TreeViewController : JWSlideMenuViewController <UIAlertViewDelegate,UITableViewDataSource, UITableViewDelegate , KxSMBProviderDelegate, SmbAuthViewControllerDelegate>{
    BOOL        _isHeadVC;
    NSArray     *_items;
    BOOL        _loading,EditModeFlag;
    BOOL        _needNewPath,NgForPasswd,PushDone;
    UIBarButtonItem *menuButton;
    //NSMutableDictionary *_cachedAuths;
    SmbAuthViewController *_smbAuthViewController;
    //NSString *path;
}
- (id)initAsHeadViewController;
- (void) reloadPath;
- (void)LayoutCheck;
-(void)PushDeleteBtn :(UIButton *)btn;
-(void)UseEventDelete;
-(void)UseEventUpLoad;
@property (readwrite, nonatomic, strong) NSString *path;
@property (readwrite, nonatomic, strong) UITableView *tableView;
@property (readwrite, nonatomic, strong) UIRefreshControl *refreshControl;
@property (readwrite, nonatomic, strong) NSMutableDictionary *_cachedAuths;
@property (retain, nonatomic) NSTimer *ADTimer;
@property BOOL BackBottomFLG;
@end
