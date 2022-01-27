//
//  JWSlideMenuViewController.m
//  JWSlideMenu
//
//  Created by Jeremie Weldin on 11/24/11.
//  Copyright (c) 2011 Jeremie Weldin. All rights reserved.
//

#import "JWSlideMenuViewController.h"
#import "JWSlideMenuController.h"
// Swift側の定義を読み込む
//#import "DataConnect-Swift.h"
@implementation JWSlideMenuViewController
@synthesize navigationController,slideMenu,slideMenuController,ssh_serverName,dateFormatter,CachePath,DocumentPath;
- (id)init
{
    self = [super init];
    slideMenu = [JWSlideMenuController alloc];
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"];
    dateFormatter.dateFormat = @"yyyy/MM/dd HH:mm";
    self.DocumentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    self.CachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    return self;
}

/**
 *
 * テキストボタンの生成 アクションコントロールは自分で書く(下記見本)
 * addTarget(self, action: "test", forControlEvents: UIControlEvents.TouchUpInside)
 * @param
 * @return
 * @exception
 * @see
 * @since
 * @deprecated
 */
-(UIButton*)makeButton:(CGRect)frame : (NSString *)text :(int)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    // ボタンのフレーム
    button.frame = frame;
    
    // ボタンのタグ
    button.tag = tag;
    
    // ボタンのアール
    button.layer.cornerRadius = 5;
    
    // ボタンの枠線
    button.layer.borderWidth = 0;
    
    // ボタンの背景色
    button.backgroundColor = [self objcHexStr:@"#1E90FF" : 1];
    
    // ボタンの影
    button.layer.shadowOffset = CGSizeMake(1.5, 1.5);
    button.layer.shadowOpacity = 0.5;
    
    // ボタンの文字
    [button setTitle:text forState:UIControlStateNormal];
    
    // ボタンの文字の色
    [button setTitleColor:[self objcHexStr:@"#F8F8F8" : 1] forState:UIControlStateNormal];
    
    // ボタンの文字の影 (影の位置を変更しないと影は表示されないので注意)
    [button setTitleShadowColor:[self objcHexStr:@"#1C1C1C" : 1] forState:UIControlStateNormal];
    
    // ボタンの文字の影の位置
    button.titleLabel.shadowOffset = CGSizeMake(1.2, 1.2);
    
    // ボタンが押された時の文字色
    [button setTitleShadowColor:[self objcHexStr:@"#1E90FF" : 1] forState:UIControlStateHighlighted];
    
    // ボタンのフォント
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    //利用不可時の色設定
    [button setTitleColor:[ UIColor grayColor ] forState:UIControlStateDisabled ];
    [button setTitleShadowColor:[ UIColor grayColor ] forState:UIControlStateDisabled];

    return button;
}

/**
 *
 * レイアウトの位置や幅を調整する
 *
 * @param
 * @return UILabel
 * @exception
 * @see
 * @since
 * @deprecated
 */
-(CGRect)objcLayOutCyouSei {
    CGRect myBounds = [[UIScreen mainScreen] bounds];
    CGFloat AdMobView_height;
    BOOL YokoMukiFLG = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ? NO : YES;
    float sc_x;
    float sc_y;
    if(myBounds.size.width > myBounds.size.height){
        sc_x = YokoMukiFLG ? myBounds.size.width : myBounds.size.height;
        sc_y = YokoMukiFLG ? myBounds.size.height : myBounds.size.width;
    } else {
        sc_x = YokoMukiFLG ? myBounds.size.height : myBounds.size.width;
        sc_y = YokoMukiFLG ? myBounds.size.width : myBounds.size.height;
    }

    //----------------------------------------------------------
    // 広告表示の判定
    //----------------------------------------------------------
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"ADactive"]) {
        AdMobView_height = 0;
    } else {
        AdMobView_height = [[NSUserDefaults standardUserDefaults] floatForKey:@"AdMobView_height"];
    }
    return CGRectMake(
                      0,
                      AdMobView_height,
                      sc_x,
                      sc_y-AdMobView_height - NavigationBarHeight - StatusBarhHeight
                      );
}

/**
 *
 * アラートの表示
 *
 * @param
 * @return
 * @exception
 * @see
 * @since
 * @deprecated  ლ(´ڡ`ლ)
 */
-(void)showAlert:(NSString *)title : (NSString *)text {
    UIAlertController *alert;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >=8.0){
        alert = [UIAlertController alertControllerWithTitle:title
                                                    message:text preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
        [[[UIAlertView alloc] initWithTitle:title
                                    message:text
                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

/**
 *
 * 文字列16進数カラーで UIColor を作成する
 *
 * @param
 * @return UILabel
 * @exception
 * @see
 * @since
 * @deprecated
 */
-(UIColor*)objcHexStr:(NSString *)hexStr : (CGFloat)alpha {
    unsigned int color;
    [[NSScanner scannerWithString:[[hexStr stringByReplacingOccurrencesOfString:@"#" withString:@""] substringWithRange:NSMakeRange(0, 6)]] scanHexInt:&color];
    return [UIColor colorWithRed:((color & 0xFF0000) >> 16)/255.0f green:((color & 0x00FF00) >> 8) /255.0f blue:(color & 0x0000FF) /255.0f alpha:alpha];
}

/**
 *
 * ナビゲーションバーのタイトルを生成する
 *
 * @param
 * @return UILabel
 * @exception
 * @see
 * @since
 * @deprecated
 */
-(UILabel*)TitleLabel:(NSString *)Message : (UIColor*)Color {
    UILabel* title_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,self.view.bounds.size.height)];
    title_label.backgroundColor = [UIColor clearColor];
    title_label.numberOfLines = 0;
    title_label.font = [UIFont boldSystemFontOfSize:16.0f];
    title_label.shadowColor = [self objcHexStr:@"#1C1C1C" : 1];
    title_label.shadowOffset = CGSizeMake(1, 1);
    title_label.textColor = Color;
    title_label.text = Message ;
    [title_label sizeToFit];
    title_label.textAlignment = NSTextAlignmentCenter;
    return title_label;
}

- (NSString*)KMByteStrings:(long)Bytes {
    int intByte;
    NSString *strByte;
    if(Bytes < 1024) {
        intByte = 1;
        strByte = @"";
    } else if(Bytes >= 1024 && Bytes < 1048576){
        intByte = 1024;
        strByte = @"K";
    } else {
        intByte = 1048576;
        strByte = @"M";
    }
    return [NSString stringWithFormat: @"%ld.%@%@",Bytes/intByte,[[NSString stringWithFormat: @"%03ld",Bytes%intByte] substringToIndex:2],strByte];
}


-(NSString*)IconImageFileName:(NSString*)pathExtension{
    if([pathExtension caseInsensitiveCompare:@"html"] == NSOrderedSame ||
       [pathExtension caseInsensitiveCompare:@"htm"] == NSOrderedSame)
        return @"WWW5.png";
    else if([pathExtension caseInsensitiveCompare:@"gif"] == NSOrderedSame ||
            [pathExtension caseInsensitiveCompare:@"jpeg"] == NSOrderedSame ||
            [pathExtension caseInsensitiveCompare:@"jpg"] == NSOrderedSame ||
            [pathExtension caseInsensitiveCompare:@"bmp"] == NSOrderedSame ||
            [pathExtension caseInsensitiveCompare:@"png"] == NSOrderedSame ||
            [pathExtension caseInsensitiveCompare:@"tiff"] == NSOrderedSame)
        return @"image.png";
    else if([pathExtension caseInsensitiveCompare:@"xls"] == NSOrderedSame || [pathExtension caseInsensitiveCompare:@"xlsx"] == NSOrderedSame)return @"XLS1.png";
    else if([pathExtension caseInsensitiveCompare:@"doc"] == NSOrderedSame || [pathExtension caseInsensitiveCompare:@"docx"] == NSOrderedSame)return @"DOC1.png";
    else if([pathExtension caseInsensitiveCompare:@"ppt"] == NSOrderedSame || [pathExtension caseInsensitiveCompare:@"pptx"] == NSOrderedSame)return @"PPT1.png";
    else if([pathExtension caseInsensitiveCompare:@"pdf"] == NSOrderedSame)return @"PDF1.png";
    else if([pathExtension caseInsensitiveCompare:@"zip"] == NSOrderedSame || [pathExtension caseInsensitiveCompare:@"zip"] == NSOrderedSame)return @"winzip.png";
    else if([pathExtension caseInsensitiveCompare:@"m4v"] == NSOrderedSame ||
            [pathExtension caseInsensitiveCompare:@"mp4"] == NSOrderedSame ||
            [pathExtension caseInsensitiveCompare:@"3gp"] == NSOrderedSame ||
            [pathExtension caseInsensitiveCompare:@"mov"] == NSOrderedSame ||
            [pathExtension caseInsensitiveCompare:@"qt"]  == NSOrderedSame)
        return @"Movie.png";
    else
        return @"File.png";
}

-(BOOL)DB_SMB:(NSString*)LastServer{
    FMDatabase *_ldb = [FMDatabase databaseWithPath:[NSString stringWithFormat: @"%@/.database/current.sqlite",self.DocumentPath]];
    FMResultSet *result;
    NSString *Title = [[[[LastServer componentsSeparatedByString:@"smb://"]  objectAtIndex:1] componentsSeparatedByString:@"/"]  objectAtIndex:0];
    if([Title isEqualToString:@"127.0.0.1"])
        return NO;
    [_ldb open];
    result = [_ldb executeQuery:[NSString stringWithFormat: @"select count(favorite_id) from favorite_List where favorite_title = '%@' and favorite_kubun = 2;",Title]];
    if ( ![result next] || [result intForColumn:@"count(favorite_id)"] > 0)
        return NO;
    [_ldb executeUpdate:@"insert into favorite_List (favorite_title,favorite_uri,favorite_kubun) values(?,?,2);",Title,LastServer];
    [result close];
    [_ldb close];
    _ldb=nil;
    return YES;
}
@end
