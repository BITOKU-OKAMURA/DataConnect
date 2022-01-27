//
//  FileViewController.m
//  kxsmb project
//  https://github.com/kolyvan/kxsmb/
//
//  Created by Kolyvan on 29.03.13.
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
#import "FileViewController.h"
#import "KxSMBProvider.h"

@interface FileViewController ()
@end
@implementation FileViewController {
    
    UILabel         *_nameLabel;
    UILabel         *_sizeLabel;
    UILabel         *_dateLabel;
    UIButton        *_downloadButton,*_ViewPlayButton;
    UIProgressView  *_downloadProgress;
    UILabel         *_downloadLabel;
    NSString        *_filePath;
    NSFileHandle    *_fileHandle;
    long            _downloadedBytes;
    NSDate          *_timestamp;
    UIImageView *_iconView;
    UIWebView *_webView;
    UIImageView *imageView;
    
    //UIAlertController *alert;
    NSString *folder,*UserTMP;
    int Add_selecVirew_height;
    UITextView *_textView;
    
}
@synthesize ADTimer;
- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void) dealloc
{
    [self closeFiles];
}
- (void) loadView
{
    UserTMP = [NSString stringWithFormat: @"%@DConeect",NSTemporaryDirectory()];
    self.view = [[UIView alloc] initWithFrame:[self objcLayOutCyouSei]];
    self.view.backgroundColor = [UIColor whiteColor];
    CGRect frame = self.view.frame;
    CGFloat W = frame.size.width;
    Add_selecVirew_height = 250;//小Viewを足した値
    
    _iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self IconImageFileName:[_smbFile.path pathExtension]]]];
    _iconView.frame = CGRectMake(10, 10, 80, 80);
    self.title =_smbFile.path.lastPathComponent;
    NSString *host = [[[[_smbFile.path componentsSeparatedByString:@"://"]  objectAtIndex:1] componentsSeparatedByString:@"/"]  objectAtIndex:0];
    folder = ([self.title isEqualToString:@"id_rsa"] || [self.title isEqualToString:@"id_rsa.pub"]) ?
    [NSString stringWithFormat:@"%@/%@/.ssh",self.DocumentPath,host] :
    [NSString stringWithFormat: @"%@/%@",self.DocumentPath,[[[_smbFile.path componentsSeparatedByString:@"://"]  objectAtIndex:1] stringByReplacingOccurrencesOfString:self.title withString:@""]];
    
    if([host isEqualToString:@"127.0.0.1"] || [host isEqualToString:@"localhost"])
        folder = [folder stringByReplacingOccurrencesOfString:host withString:[[NSUserDefaults standardUserDefaults] stringForKey:@"ConnectServer"]];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, W - 20, 60)];
    _nameLabel.font = [UIFont boldSystemFontOfSize:16];
    _nameLabel.numberOfLines = 0; // 行数無制限
    _nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _nameLabel.textColor = [UIColor darkTextColor];
    _nameLabel.opaque = NO;
    _nameLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _nameLabel.text = _smbFile.path;
    [_nameLabel sizeToFit];
    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100 + _nameLabel.bounds.size.height, W - 20, 20)];
    _sizeLabel.font = [UIFont systemFontOfSize:14];
    _sizeLabel.textColor = [UIColor darkTextColor];
    _sizeLabel.opaque = NO;
    _sizeLabel.backgroundColor = [UIColor clearColor];
    _sizeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 120 + _nameLabel.bounds.size.height, W - 20, 20)];
    _dateLabel.font = [UIFont systemFontOfSize:14];;
    _dateLabel.textColor = [UIColor darkTextColor];
    _dateLabel.opaque = NO;
    _dateLabel.backgroundColor = [UIColor clearColor];
    _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    _downloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _downloadButton.frame = CGRectMake(10, 140 + _nameLabel.bounds.size.height, 100, 20);
    _downloadButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    [_downloadButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_downloadButton addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    _downloadButton.tag = 1;
    _downloadLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 160 + _nameLabel.bounds.size.height, W - 20, 40)];
    _downloadLabel.opaque = NO;
    _downloadLabel.backgroundColor = [UIColor clearColor];
    _downloadLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _downloadLabel.numberOfLines = 2;
    
    _downloadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    _downloadProgress.frame = CGRectMake(10, 200 + _nameLabel.bounds.size.height, frame.size.width - 20, 30);
    _downloadProgress.hidden = YES;
    
    //----------------------------------------------------------
    // ViewPlayButton
    //----------------------------------------------------------
    _ViewPlayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _ViewPlayButton.frame = CGRectMake(100, 140 + _nameLabel.bounds.size.height, 100, 20);
    _ViewPlayButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [_ViewPlayButton setTitle:@"View/Play" forState:UIControlStateNormal];
    [_ViewPlayButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_ViewPlayButton addTarget:self action:@selector(downloadAction:) forControlEvents:UIControlEventTouchUpInside];
    _ViewPlayButton.tag = 2;
    if([self.title isEqualToString:@"id_rsa"] || [self.title isEqualToString:@"id_rsa.pub"])
        _ViewPlayButton.enabled=NO;

    //----------------------------------------------------------
    // selecViewの定義(親UIViewはself.view)
    //----------------------------------------------------------
    selecView = [[UIView alloc] init];
    selecView.frame = CGRectMake(0, 0, self.view.bounds.size.width,Add_selecVirew_height);
    selecView.backgroundColor=[UIColor whiteColor];
    
    //----------------------------------------------------------
    // selecView部品の追加
    //----------------------------------------------------------
    [selecView addSubview:_iconView];
    [selecView addSubview:_nameLabel];
    [selecView addSubview:_sizeLabel];
    [selecView addSubview:_dateLabel];
    
    
    //----------------------------------------------------------
    // キーボードのスクロール
    //----------------------------------------------------------
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(keyboardDidShow:)
        name:UIKeyboardDidShowNotification
    object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(keyboardDidHide:)
        name:UIKeyboardDidHideNotification
    object:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationItem.titleView = [self TitleLabel:self.title : [self objcHexStr:@"#FAFAFA" : 1]];
    self.view.frame = [self objcLayOutCyouSei];
    _nameLabel.text = _smbFile.path;
    [_nameLabel sizeToFit];
    _sizeLabel.text = [NSString stringWithFormat:@"サイズ：%@Byte", [self KMByteStrings:_smbFile.stat.size]];
    _dateLabel.text = [NSString stringWithFormat:@"最終更新:%@", [self.dateFormatter stringFromDate:_smbFile.stat.lastModified]];
    
    //----------------------------------------------------------
    // _downloadButton 表示非表示の判定
    //----------------------------------------------------------
    if (![[[NSFileManager alloc] init] fileExistsAtPath:[folder stringByAppendingPathComponent:self.title]] && ![[self.title substringToIndex:1] isEqualToString:@"."]){
        [selecView addSubview:_downloadButton];
        _downloadLabel.font = [UIFont systemFontOfSize:14];
        _downloadLabel.textColor = [UIColor darkTextColor];
    }else{
        _ViewPlayButton.frame = CGRectMake(10, 140 + _nameLabel.bounds.size.height, 100, 20);
        _downloadLabel.frame = CGRectMake(10, 160 + _nameLabel.bounds.size.height, self.view.bounds.size.width - 20, 20);
        _downloadLabel.font = [UIFont systemFontOfSize:12];
        _downloadLabel.textColor = [UIColor redColor];
        _downloadLabel.text= ![[self.title substringToIndex:1] isEqualToString:@"."] ? @"※ダウンロード済" : @"※ダウンロード不可";
    }
    [selecView addSubview:_downloadLabel];
    [selecView addSubview:_downloadProgress];
    [selecView addSubview:_ViewPlayButton];
    
    //----------------------------------------------------------
    // selecViewの表示
    //----------------------------------------------------------
    [self.view addSubview:selecView];
    
    //-------------------------------------------------------------------------
    // 広告チェックタイマー始動
    //-------------------------------------------------------------------------
    ADTimer=[NSTimer scheduledTimerWithTimeInterval:5.0
                                             target:self
                                           selector:@selector(LayoutCheck)
                                           userInfo:nil
                                            repeats:YES
             ];
    
    //----------------------------------------------------------
    // この画面の右ボタンは更新
    //----------------------------------------------------------
    self.navigationItem.rightBarButtonItem = nil;
    
    [SVProgressHUD dismiss];
}
- (void) viewWillDisappear:(BOOL)animated
{
    [[[NSOperationQueue alloc] init] addOperation:[NSBlockOperation blockOperationWithBlock: ^{
        [SVProgressHUD showWithStatus:@"お待ちください。"];
    }]];
    [[NSNotificationCenter defaultCenter] removeObserver:self
     name:UIKeyboardDidShowNotification object:nil];
[[NSNotificationCenter defaultCenter] removeObserver:self
     name:UIKeyboardDidHideNotification object:nil];
    [self closeFiles];
    [ADTimer invalidate];
    //[super viewWillDisappear:animated];
}
//-----------------------------------------------------------------------------
//自動画面回転時の配置替え
//-----------------------------------------------------------------------------
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)FromInterfaceOrientation {
    [self PostLayout];
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
    if ( (self.view.frame.origin.y > 0 && ![[NSUserDefaults standardUserDefaults] boolForKey:@"ADactive"]) || (self.view.frame.origin.y == 0 && [[NSUserDefaults standardUserDefaults] boolForKey:@"ADactive"]))
        [self PostLayout];
}
- (void) closeFiles
{
    if (_fileHandle) {
        
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
    
    [_smbFile close];
}
- (void) downloadAction:(UIButton*)button{
    [[[NSOperationQueue alloc] init] addOperation:[NSBlockOperation blockOperationWithBlock: ^{
        [SVProgressHUD showWithStatus:@"お待ちください。"];
    }]];
    NSFileManager *fm = [[NSFileManager alloc] init];
    //if(button.tag !=1 && [fm fileExistsAtPath:[folder stringByAppendingPathComponent:self.title]]){
    //    [self PlayView:[folder stringByAppendingPathComponent:self.title]];
    //    [SVProgressHUD dismiss];
    //    return;
    //}
    NSString *ExecDir = button.tag ==1 ? folder : UserTMP;
    if (!_fileHandle) {
        _filePath =  [ExecDir stringByAppendingPathComponent:self.title];
        if ([fm fileExistsAtPath:_filePath]){
            if(button.tag ==1)
                [fm removeItemAtPath:_filePath error:nil];
            else {
                [self PlayView:_filePath];
                [SVProgressHUD dismiss];
                return;
                    }
        }
        if(button.tag ==1)
            [fm createDirectoryAtPath:ExecDir withIntermediateDirectories:YES attributes:nil error:nil];
        [fm createFileAtPath:_filePath contents:nil attributes:nil];
        NSError *error;
        _fileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:_filePath]
                                                        error:&error];
        if (_fileHandle) {
            [_downloadButton setTitle: button.tag ==1 ? @"Cancel" : @"Download" forState:UIControlStateNormal];
            _downloadLabel.text = @"starting ..";
            _downloadedBytes = 0;
            _downloadProgress.progress = 0;
            _downloadProgress.hidden = NO;
            _timestamp = [NSDate date];
            [self download];
            
        } else {
            _downloadLabel.text = [NSString stringWithFormat:@"failed: %@", error.localizedDescription];
        }
    } else {
        //キャンセル動作
        if(button.tag ==1){
            //ダウンロード
            [_downloadButton setTitle:@"Download" forState:UIControlStateNormal];
            _downloadLabel.text = @"cancelled";
        } else {
            //ビュー
            NSLog(@"ビュー\n");
        }
        [[[NSFileManager alloc] init] removeItemAtPath:_filePath error:nil];
        [self closeFiles];
    }
}
-(void) updateDownloadStatus: (id) result
{
    //押下した場合のボタンタグ
    int BtnTag = [_filePath rangeOfString:UserTMP].location != NSNotFound ? 2 : 1;
    if ([result isKindOfClass:[NSError class]]) {
        NSError *error = result;
        [_downloadButton setTitle:@"Download" forState:UIControlStateNormal];
        _downloadLabel.text = [NSString stringWithFormat:@"failed: %@", error.localizedDescription];
        _downloadProgress.hidden = YES;
        [self closeFiles];
        [SVProgressHUD dismiss];
    } else if ([result isKindOfClass:[NSData class]]) {
        
        NSData *data = result;
        if (data.length == 0) {
            [_downloadButton setTitle:@"Download" forState:UIControlStateNormal];
            [self closeFiles];
            [SVProgressHUD dismiss];
        } else {
            
            NSTimeInterval time = -[_timestamp timeIntervalSinceNow];
            
            _downloadedBytes += data.length;
            _downloadProgress.progress = (float)_downloadedBytes / (float)_smbFile.stat.size;
            CGFloat value;
            NSString *unit;
            
            if (_downloadedBytes < 1024) {
                
                value = _downloadedBytes;
                unit = @"B";
                
            } else if (_downloadedBytes < 1048576) {
                
                value = _downloadedBytes / 1024.f;
                unit = @"KB";
                
            } else {
                
                value = _downloadedBytes / 1048576.f;
                unit = @"MB";
            }
            _downloadLabel.text = [NSString stringWithFormat:@"%@ %.1f%@ (%.1f%%) %.2f%@s",
                                   (BtnTag ==1) ? @"downloaded": @"buffered" ,
                                   value, unit,
                                   _downloadProgress.progress * 100.f,
                                   value / time, unit];
            if (_fileHandle) {
                [_fileHandle writeData:data];
                
                if(_downloadedBytes == _smbFile.stat.size) {
                    [self closeFiles];
                    //----------------------------------------------------------
                    // ビューかダウンロードかの判定
                    //----------------------------------------------------------
                    if(BtnTag ==1){
                        //ここでダウンロード正常終了の周知
                        [self showAlert:self.title :@"ダウンロード完了"];
                        [_downloadButton removeFromSuperview];
                        [SVProgressHUD dismiss];
                    } else {
                        [self PlayView:_filePath];
                    }
                } else {
                    [self download];
                }
            }
        }
    } else {
        NSAssert(false, @"bugcheck");
    }
}
- (void) PostLayout{
    self.view.frame = [self objcLayOutCyouSei];
    selecView.frame = CGRectMake(0, 0, self.view.bounds.size.width,Add_selecVirew_height);
    _textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _webView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}
- (void) PlayView:(NSString*)filePath{
    int enc_arr[] = {
        NSUTF8StringEncoding,
        NSShiftJISStringEncoding,
        NSJapaneseEUCStringEncoding,
        NSISO2022JPStringEncoding
        //NSUnicodeStringEncoding,
        //NSASCIIStringEncoding
    };
    int max = sizeof(enc_arr) / sizeof(enc_arr[0]);
    NSString *Ascii_TXT;
    for (int p=0; p<max; p++) {
        if ([[NSString alloc] initWithData : [[NSData alloc] initWithContentsOfFile:filePath] encoding : enc_arr[p]]!=nil){
            Ascii_TXT=[[NSString alloc] initWithData : [[NSData alloc] initWithContentsOfFile:filePath] encoding : NSUTF8StringEncoding];
            break;
        }
    }
    if((int)[[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] objectForKey:NSFileSize] < 1)
        return;
    if([@[@"png",@"jpg",@"gif",@"htm",@"html",@"pdf"] containsObject:[[filePath pathExtension] lowercaseString]]) {
        _webView = [[UIWebView alloc] initWithFrame: CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.height)];
        _webView.backgroundColor = [UIColor blackColor];
        _webView.scrollView.bounces = true;
        _webView.scalesPageToFit = true;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
        _webView.autoresizingMask = ( UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth );
        _webView.delegate = self;
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:filePath]]];
        [selecView removeFromSuperview];
        [self.view addSubview:_webView];
    }  else if (Ascii_TXT.length > 0) {
        
        //----------------------------------------------------------
        // この画面の右ボタンは更新
        //----------------------------------------------------------
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_save.png"] 
                                                    style:UIBarButtonItemStylePlain 
                                                    target:self 
                                                    action:@selector(actionCopyFile:)];

        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _textView.editable = YES;
        _textView.text = Ascii_TXT;
        // delegate
        _textView.delegate = self;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.layer.borderWidth = 0;
        _textView.clipsToBounds = YES;
        _textView.editable = YES;
        _textView.layer.cornerRadius = 10.0f;
        // ViewとDoneボタンの作成
        UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
        keyboardDoneButtonView.barStyle  = UIBarStyleBlack;
        keyboardDoneButtonView.translucent = YES;
        keyboardDoneButtonView.tintColor = nil;
        [keyboardDoneButtonView sizeToFit];
        // 完了ボタンとSpacerの配置
        UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStyleBordered target:self action:@selector(doneBtnClicked)];
        UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
        // Viewの配置
        _textView.inputAccessoryView = keyboardDoneButtonView;
        [selecView removeFromSuperview];
        [self.view addSubview:_textView];
        [SVProgressHUD dismiss];
    }
    
    [_ViewPlayButton removeFromSuperview];
}

//_webViewロード終了時のインダクタ
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [SVProgressHUD dismiss];
}

#pragma mark 完了ボタンのクリック
-(void)doneBtnClicked {
    [_textView resignFirstResponder];
}

#pragma mark キーボードが表示された時のイベント
- (void)keyboardDidShow:(NSNotification *)aNotification
{
    CGRect keyboardRect = [self.view
        convertRect:[[[aNotification userInfo]
                      objectForKey:UIKeyboardFrameEndUserInfoKey]
                     CGRectValue]
        toView:nil];
    CGRect viewRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    //viewRect.size.height -= (keyboardRect.size.height
    //    - NavigationBarHeight);
    viewRect.size.height -= keyboardRect.size.height;
    _textView.frame = viewRect;
}

#pragma mark キーボードが閉じた時のイベント
- (void)keyboardDidHide:(NSNotification *)aNotification
{
_textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark Doneでキーボードを閉じる
- (BOOL) textView: (UITextView*) textView shouldChangeTextInRange: (NSRange) range replacementText: (NSString*) text {
    //if ([text isEqualToString:@"\n"]) {
    //    [textView resignFirstResponder];
    //    return NO;
    //}
    return YES;
}




- (void) download
{
    __weak __typeof(self) weakSelf = self;
    [_smbFile readDataOfLength:32768
                         block:^(id result)
     {
         FileViewController *p = weakSelf;
         //if (p && p.isViewLoaded && p.view.window) {
         if (p) {
             [p updateDownloadStatus:result];
         }
     }];
}

- (void) actionCopyFile:(id)sender
{

    KxSMBProvider *provider = [KxSMBProvider sharedSmbProvider];
    [provider createFileAtPath:_smbFile.path overwrite:YES block:^(id result) {
        NSData *data = [_textView.text dataUsingEncoding:NSUTF8StringEncoding];
        if ([result isKindOfClass:[KxSMBItemFile class]]) {
            KxSMBItemFile *itemFile = result;
            [itemFile writeData:data block:^(id result) {
                NSLog(@"completed:%@", result);
                [self showAlert:self.title :@"ファイル更新完了"];
                [[NSFileManager defaultManager] removeItemAtPath:_filePath error:nil];
                [[NSFileManager defaultManager] createFileAtPath:_filePath contents:[NSData data] attributes:nil];
            }];
        } else {
            
            NSLog(@"actionCopyFileエラー=%@", result);
        }
    }];
}

@end
