//
//  TreeViewController.m
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

#import "TreeViewController.h"
@implementation TreeViewController
@synthesize tableView,refreshControl,_cachedAuths,ADTimer,BackBottomFLG;
- (void) setPath:(NSString *)path
{
    _path = path;
    [self reloadPath];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"";
        _needNewPath = NO;
        NgForPasswd = NO;
        PushDone = NO;
        _isHeadVC = YES;
    }
    return self;
}

- (id)initAsHeadViewController {
    if((self = [self init])) {
        _isHeadVC = YES;
    }
    return self;
}

- (void)loadView
{

    [super loadView];
    if(NSClassFromString(@"UIRefreshControl")) {
        UIRefreshControl *refreshControl1 = [[UIRefreshControl alloc] init];
        [refreshControl1 addTarget:self action:@selector(reloadPath) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl1;
    }
/*
    self.navigationItem.rightBarButtonItems =
    _isHeadVC ?
    @[
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                    target:self
                                                    action:@selector(actionMkDir:)],
      
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                    target:self
                                                    action:@selector(reloadPath)],
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                    target:self
                                                    action:@selector(requestNewPath)],
      ] :
    
    @[
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                    target:self
                                                    action:@selector(actionMkDir:)],
      
      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                    target:self
                                                    action:@selector(reloadPath)],
      ];
*/

    //----------------------------------------------------------
    // この画面の右ボタンはサーチとデリート
    //----------------------------------------------------------
    EditModeFlag = NO;

    //----------------------------------------------------------
    // デリゲート
    //----------------------------------------------------------
    _cachedAuths = !_cachedAuths ? [NSMutableDictionary dictionary] : _cachedAuths;
    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
    provider.delegate = self;
    
    //----------------------------------------------------------
    // TableViewの定義(親UIViewはself.view)
    //----------------------------------------------------------
    //tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height)];
    tableView = [[UITableView alloc] init];
    tableView.autoresizingMask = ( UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth );
    tableView.separatorColor= [self objcHexStr:@"#EFEFEF" : 1];
    tableView.backgroundView = nil;
    tableView.backgroundColor=[UIColor whiteColor];
    tableView.dataSource = self;
    tableView.delegate = self;

    //----------------------------------------------------------
    // 区切り線の幅を調整
    //----------------------------------------------------------
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    [self.view addSubview:tableView];
    menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list_bullets.png"] style:UIBarButtonItemStyleBordered target:self.slideMenuController action:@selector(toggleMenu)];
    self.navigationItem.titleView = [self TitleLabel:@"SMB/共有" : [self objcHexStr:@"#FAFAFA" : 1]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


//-----------------------------------------------------------------------------
//自動画面回転時の配置替え
//-----------------------------------------------------------------------------
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)FromInterfaceOrientation {
    [self PreLayoutCyousei];
}

-(void)UseEventUpLoad {
    if([[[NSUserDefaults standardUserDefaults] stringForKey:@"SaveAdress"] isEqualToString:@""] || ![[NSUserDefaults standardUserDefaults] stringForKey:@"SaveAdress"])
        return;


    NSString *LocalFile = [[NSUserDefaults standardUserDefaults] stringForKey:@"SaveAdress"].lastPathComponent;
    NSString *path = [NSString stringWithFormat: @"%@/%@",self.path,LocalFile];
    
    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
    [provider createFileAtPath:path overwrite:YES block:^(id result) {
        
        if ([result isKindOfClass:[KxSMBItemFile class]]) {
            
            NSData *data = [[NSData alloc] initWithContentsOfFile:[[NSUserDefaults standardUserDefaults] stringForKey:@"SaveAdress"]];
            
            KxSMBItemFile *itemFile = result;
            [itemFile writeData:data block:^(id result) {
                
                NSLog(@"completed:%@", result);
                if (![result isKindOfClass:[NSError class]]) {
                    [self reloadPath];
                    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"SaveAdress"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    //----------------------------------------------------------
                     // この画面の右ボタンはサーチとデリート
                    //----------------------------------------------------------
                    self.navigationItem.rightBarButtonItems =
                    @[
                    [[[NSUserDefaults standardUserDefaults] stringForKey:@"SaveAdress"] isEqualToString:@""] || ![[NSUserDefaults standardUserDefaults] stringForKey:@"SaveAdress"] ?
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                    target:self
                                                    action:@selector(UseEventDelete)] :
                    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_save.png"]
                                                    style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(UseEventUpLoad)],
                    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_magnifier.png"]
                                                    style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(requestNewPath)]
                    ];
                    [self showAlert:LocalFile :@"アップロード完了"];
                }
            }];
            
        } else {
            
            NSLog(@"%@", result);
        }
    }];


    
    
    //[self reloadPath];
    [SVProgressHUD dismiss];
}
- (void)viewDidAppear:(BOOL)animated {

    //----------------------------------------------------------
    // この画面の右ボタンはサーチとデリート
    //----------------------------------------------------------
    self.navigationItem.rightBarButtonItems = 
        @[
            [[[NSUserDefaults standardUserDefaults] stringForKey:@"SaveAdress"] isEqualToString:@""] || ![[NSUserDefaults standardUserDefaults] stringForKey:@"SaveAdress"] ? 
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                    target:self
                                                    action:@selector(UseEventDelete)] : 
            [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_save.png"] 
                                                    style:UIBarButtonItemStylePlain 
                                                    target:self 
                                                    action:@selector(UseEventUpLoad)],
            [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_magnifier.png"] 
                                                    style:UIBarButtonItemStylePlain 
                                                    target:self 
                                                    action:@selector(requestNewPath)] 
        ];
    if (!_path) {
        [self requestNewPath];
    }
    //-------------------------------------------------------------------------
    // 広告チェックタイマー始動
    //-------------------------------------------------------------------------
    ADTimer=[NSTimer scheduledTimerWithTimeInterval:5.0 
        target:self
        selector:@selector(LayoutCheck)
        userInfo:nil
        repeats:YES
    ];
    [self PreLayoutCyousei];
    if(_items.count>0)
        [SVProgressHUD dismiss];
}

-(void)PreLayoutCyousei{
    self.view.frame = [self objcLayOutCyouSei];
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height);
    //----------------------------------------------------------
    // メニューボタン
    //----------------------------------------------------------
    self.navigationItem.leftBarButtonItem = !BackBottomFLG || self.view.frame.size.width > self.view.frame.size.height ? menuButton : nil;
    self.navigationItem.leftItemsSupplementBackButton  = self.view.frame.size.width > self.view.frame.size.height;
}

-(void) viewWillDisappear:(BOOL)animated {
    [ADTimer invalidate];
[[[NSOperationQueue alloc] init] addOperation:[NSBlockOperation blockOperationWithBlock: ^{
    [SVProgressHUD showWithStatus:@"お待ちください。"];
}]];
}

- (void) reloadPath
{
    KxSMBAuth *auth;
    NSString *path;
    NSString *current_server;
    if (_path.length) {
        
        path = _path;
        self.title = path.lastPathComponent;
        current_server = [[[[path componentsSeparatedByString:@"//"]  objectAtIndex:1] componentsSeparatedByString:@"/"]  objectAtIndex:0];
        auth = _cachedAuths[current_server];
    } else {
        path = @"smb://";
        self.title = @"smb://";
    }

    self.navigationItem.titleView = [self TitleLabel:self.title : [self objcHexStr:@"#FAFAFA" : 1]];
    

    [SVProgressHUD showWithStatus:auth ? @"認証処理中" : @"お待ちください。"];
    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];

    [provider fetchAtPath:path
                    block:^(id result)
     {
         if ([result isKindOfClass:[NSError class]]) {
             
             if(_path && auth) {
                 
                 if(_needNewPath){
                     [SVProgressHUD dismiss];
                     return;
                 } else {
                     NSLog(@"★認証不可 \n");
                     NgForPasswd = YES;
                     _smbAuthViewController.password = nil;
                     _smbAuthViewController.workgroup = nil;
                     [self updateStatus:result];
                 }
             } else {
                 NSLog(@"★未認証\n");
                 _needNewPath = NO;
                 //[self updateStatus:result];
             }
         } else {
             _needNewPath = YES;
             NSLog(@"★認証OK\n");

            //----------------------------------------------------------
            // 履歴の登録
            //----------------------------------------------------------
            [[NSUserDefaults standardUserDefaults] setObject:self.path forKey:@"LastServer"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if([self DB_SMB:[[NSUserDefaults standardUserDefaults] stringForKey:@"LastServer"]])
                [self showAlert:current_server:@"共有接続履歴に\n登録ました。"];
             _items = nil;
             [self updateStatus:nil];
             if ([result isKindOfClass:[NSArray class]]) {
                 _items = [result copy];
             } else if ([result isKindOfClass:[KxSMBItem class]]) {
                 _items = @[result];
             }
             _smbAuthViewController = [[SmbAuthViewController alloc] init];
             _smbAuthViewController.username = @"guest";
             _smbAuthViewController.password = @"";
             _smbAuthViewController.workgroup = @"";
             NgForPasswd = NO;
        }

            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
            }];
     }];
}

- (void) requestNewPath {
    
    
    if([[NSUserDefaults standardUserDefaults] stringForKey:@"LastServer"] && [[[NSUserDefaults standardUserDefaults] stringForKey:@"LastServer"] length] > 0) {
    self.path = [[NSUserDefaults standardUserDefaults] stringForKey:@"LastServer"];
    return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"接続先を入力"
                                                    message:@"smb://<IPアドレス>\n※トンネリングの場合は空白"
                                                   delegate:self
                                          cancelButtonTitle:@"キャンセル"
                                          otherButtonTitles:@"接続", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];//１行で実装
    [alert show];
}

- (void) updateStatus: (id) status
{
    UIFont *font = [UIFont boldSystemFontOfSize:16];
    
    if ([status isKindOfClass:[NSString class]]) {
        
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        CGSize sz = activityIndicator.frame.size;
        const float H = font.lineHeight + sz.height + 10;
        const float W = self.tableView.frame.size.width;
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, W, H)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, W, font.lineHeight)];
        label.text = status;
        label.font = font;
        label.textColor = [UIColor grayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.opaque = NO;
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [v addSubview:label];
        
        if(![self.refreshControl isRefreshing])
            [self.refreshControl beginRefreshing];
        
        self.tableView.tableHeaderView = v;
        
    } else if ([status isKindOfClass:[NSError class]]) {
        const float W = self.tableView.frame.size.width;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, W, font.lineHeight)];
        label.text = ((NSError *)status).localizedDescription;
        label.font = font;
        label.textColor = [UIColor redColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.opaque = NO;
        label.backgroundColor = [UIColor clearColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.tableView.tableHeaderView = label;
        
        [self.refreshControl endRefreshing];
        
    } else {
        
        self.tableView.tableHeaderView = nil;
        
        [self.refreshControl endRefreshing];
    }
}

- (void) actionCopyFile:(id)sender
{
    NSString *name = [NSString stringWithFormat:@"%lu.tmp", (unsigned long)[NSDate timeIntervalSinceReferenceDate]];
    NSString *path = [_path stringByAppendingSMBPathComponent:name];



    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
    [provider createFileAtPath:path overwrite:YES block:^(id result) {
        
        if ([result isKindOfClass:[KxSMBItemFile class]]) {
            
            NSData *data = [@"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." dataUsingEncoding:NSUTF8StringEncoding];
            
            KxSMBItemFile *itemFile = result;
            [itemFile writeData:data block:^(id result) {
                
                NSLog(@"completed:%@", result);
                if (![result isKindOfClass:[NSError class]]) {
                    [self reloadPath];
                }
            }];
            
        } else {
            
            NSLog(@"actionCopyFileエラー=%@", result);
        }
    }];
}

- (void) actionMkDir:(id)sender
{
    NSString *path = [_path stringByAppendingSMBPathComponent:@"NewFolder"];
    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
    id result = [provider createFolderAtPath:path];
    if ([result isKindOfClass:[KxSMBItemTree class]]) {
        
        NSMutableArray *ma = [_items mutableCopy];
        [ma addObject:result];
        _items = [ma copy];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_items.count-1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } else {
        
        NSLog(@"actionMkDirエラー=%@", result);
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    //=========================================================================
    // セパレーターの左端が切れないように
    //=========================================================================
    if ([cell respondsToSelector:@selector(separatorInset)]) {
        cell.separatorInset = UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(preservesSuperviewLayoutMargins)]) {
        cell.preservesSuperviewLayoutMargins = false;
    }
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }

    //----------------------------------------------------------
    //  連続描画対策。UITableViewで部品を表示する際は必須
    //----------------------------------------------------------
    for (UIView *subview in [[NSArray alloc] initWithArray:cell.contentView.subviews]) 
        [subview removeFromSuperview];

    //----------------------------------------------------------
    //  削除ボタンの表示
    //----------------------------------------------------------
    if(EditModeFlag){
        UIButton *DeleteBtn = [self makeButton:CGRectMake(self.view.frame.size.width - 44, 8, 40, 24) : @"削除" :indexPath.row];
        [DeleteBtn addTarget:self action:@selector(PushDeleteBtn:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:DeleteBtn];
    }

    //=========================================================================
    // セルの大きさを指定
    //=========================================================================
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    KxSMBItem *item = _items[indexPath.row];
    cell.textLabel.text = item.path.lastPathComponent;
    NSString *pathExtension = [cell.textLabel.text pathExtension];

    cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    cell.detailTextLabel.font = [UIFont  italicSystemFontOfSize:10];
    cell.detailTextLabel.textColor = [UIColor grayColor];

    //=========================================================================
    //ファイルかフォルダかの判定
    //=========================================================================
    if ([item isKindOfClass:[KxSMBItemTree class]]) {
        //=========================================================================
        //フォルダの場合
        //=========================================================================
        cell.imageView.image = [UIImage imageNamed:@"Foruda.png"];
        cell.accessoryType = EditModeFlag ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text =  @"";
    } else {
        //=========================================================================
        //ファイルの場合
        //=========================================================================
        cell.imageView.image = [UIImage imageNamed:[self IconImageFileName:pathExtension]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ %@Byte\n",[self.dateFormatter stringFromDate:item.stat.lastModified],[self KMByteStrings:item.stat.size]];
    }

    //=========================================================================
    // アイコンを整形して表示
    //=========================================================================
    //UIGraphicsBeginImageContext(CGSizeMake(TableViewCellIconWidth, TableViewCellIconHeight));
    //[cell.imageView.image drawInRect:CGRectMake(0, 0, TableViewCellIconWidth, TableViewCellIconHeight)];
    //cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsEndImageContext(); 
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    //=========================================================================
    // 削除モード中は処理しない
    //=========================================================================
    if(EditModeFlag){
        return;
    }
    KxSMBItem *item = _items[indexPath.row];
    if ([item isKindOfClass:[KxSMBItemTree class]]) {
        TreeViewController *vc = [[TreeViewController alloc] init];
        vc.BackBottomFLG = YES;
        vc.path = item.path;
        vc._cachedAuths = _cachedAuths;
        [self.navigationController pushViewController:vc];
    } else if ([item isKindOfClass:[KxSMBItemFile class]]) {
        FileViewController *vc = [[FileViewController alloc] init];
        vc.smbFile = (KxSMBItemFile *)item;
        [self.navigationController pushViewController:vc];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        KxSMBItem *item = _items[indexPath.row];
        [[KxSMBProvider sharedSmbProvider] removeAtPath:item.path block:^(id result) {
            
            NSLog(@"completed:%@", result);
            if (![result isKindOfClass:[NSError class]]) {
                [self reloadPath];
            }
        }];
    }
}

/**
 * 
 * 削除ボタンのイベント
 * 
 * @param
 * @return
 * @exception
 * @see
 * @since
 * @deprecated
 */
-(void)PushDeleteBtn :(UIButton *)btn{
    [SVProgressHUD showWithStatus:@"お待ちください。"];
    KxSMBItem *item = _items[btn.tag];
    [[KxSMBProvider sharedSmbProvider] removeAtPath:item.path block:^(id result) {
        if (![result isKindOfClass:[NSError class]]) {
            [self showAlert:item.path.lastPathComponent:@"削除しました。"];
            EditModeFlag =!EditModeFlag;
            [self reloadPath];
        } else {
            [self showAlert:item.path.lastPathComponent:@"削除に失敗。"];
        }
    }];
    [SVProgressHUD dismiss];
}

-(void)UseEventDelete{
    EditModeFlag =!EditModeFlag;
    [tableView reloadData];
}


/**
 * 
 * 広告読み込み状況の変化を確認してメインスクリーンを調整する
 * 
 * @param
 * @return
 * @exception
 * @see
 * @since
 * @deprecated
 */
- (void)LayoutCheck {
    if ( (self.view.frame.origin.y > 0 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"ADactive"]) || (self.view.frame.origin.y == 0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"ADactive"])) {
        [self PreLayoutCyousei];
    }
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if(buttonIndex != 1) {
        [SVProgressHUD dismiss];
        return;
    }

    //-------------------------------------------------------------------------
    //  トンネリング接続が無くで入力がない場合はエラー
    //-------------------------------------------------------------------------
    if((![[NSUserDefaults standardUserDefaults] stringForKey:@"ConnectServer"] || [[[NSUserDefaults standardUserDefaults] stringForKey:@"ConnectServer"] length] < 1) && [[[alertView textFieldAtIndex:0] text] length] < 1 ){
        [self showAlert:@"接続先未指定" :@"空白を指定する場合は\n先にトンネリング接続を\n確立してください。"];
        [SVProgressHUD dismiss];
        return;
    }

    //-------------------------------------------------------------------------
    //  登録アドレスが正しいhttp形式で無ければエラー
    //-------------------------------------------------------------------------
    if ((![[NSUserDefaults standardUserDefaults] stringForKey:@"ConnectServer"] || [[[NSUserDefaults standardUserDefaults] stringForKey:@"ConnectServer"] length] < 1) && [[[alertView textFieldAtIndex:0] text] rangeOfString:
                        @"(smb://[.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+)" options:NSRegularExpressionSearch].location == NSNotFound) {
        [self showAlert:@"無効なアドレス" :@"smb://<IP アドレス>\nと指定して下さい。"];
        [SVProgressHUD dismiss];
        return;
    }

    NSString *DefaultHost = ([[NSUserDefaults standardUserDefaults] stringForKey:@"ConnectServer"] && [[[NSUserDefaults standardUserDefaults] stringForKey:@"ConnectServer"] length] > 0) ? @"smb://127.0.0.1/" : @"";
    PushDone = NO;
    self.path = ([[[alertView textFieldAtIndex:0] text] length] > 0 && [[[[alertView textFieldAtIndex:0] text] componentsSeparatedByString:@"//"]  count] > 1)? [[alertView textFieldAtIndex:0] text] : DefaultHost;
}

#pragma mark - KxSMBProviderDelegate

- (void) presentSmbAuthViewControllerForServer: (NSString *) server
{
    if (!_smbAuthViewController) {
        _smbAuthViewController = [[SmbAuthViewController alloc] init];
        _smbAuthViewController.delegate = self;
        _smbAuthViewController.username = @"guest";
    }
    _smbAuthViewController.server = server;
    PushDone = NO;
    [SVProgressHUD dismiss];
    [self.view addSubview:_smbAuthViewController.view];
    
}

- (void) couldSmbAuthViewController: (SmbAuthViewController *) controller
                               done: (BOOL) done
{
    if (done) {
        PushDone = YES;
        KxSMBAuth *auth = [KxSMBAuth smbAuthWorkgroup:controller.workgroup
                                             username:controller.username
                                             password:controller.password];
        _cachedAuths[controller.server.uppercaseString] = auth;
        NSLog(@"【DONE】server->%@ workgroup->%@ username->%@ password->%@",
              controller.server.uppercaseString, auth.workgroup, auth.username, auth.password);
    }
    [_smbAuthViewController.view removeFromSuperview];
    [self reloadPath];
}

- (KxSMBAuth *) smbAuthForServer: (NSString *) server
                       withShare: (NSString *) share
{

    KxSMBAuth *auth = NgForPasswd ? nil : _cachedAuths[server.uppercaseString];
    
    if(_smbAuthViewController && _cachedAuths[server.uppercaseString] && !auth.username && !auth.password && PushDone){
        self.tableView.tableHeaderView = nil;
        KxSMBAuth *NDAuth = [KxSMBAuth smbAuthWorkgroup:_smbAuthViewController.workgroup
                                  username:_smbAuthViewController.username
                                  password:_smbAuthViewController.password];
        NSLog(@"【AUTH】能動認証 [%@] 結果:%@\n",_smbAuthViewController.username,NDAuth ? @"認証OK": @"認証NG");
        
        
        return NDAuth;
    }
    NSLog(@"【AUTH】%@ server->%@ workgroup->%@ username->%@ password->%@",NgForPasswd ? @"認証不可" : @"未認証又は認証済",
          server.uppercaseString, auth.workgroup, auth.username, auth.password);
    if (auth && auth.username && auth.password)
        return auth;
    if(![server isEqualToString:self.title])
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentSmbAuthViewControllerForServer:server];
        });
    return nil;
}

@end
