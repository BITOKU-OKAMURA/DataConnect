//
//  JWSlideMenuViewController.h
//  JWSlideMenu
//
//  Created by Jeremie Weldin on 11/24/11.
//  Copyright (c) 2011 Jeremie Weldin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JWNavigationController.h"
#import "define.h"
//@class JWSlideMenuController;
@class JWSlideMenuController;
@interface JWSlideMenuViewController : UIViewController {
}
@property (nonatomic, retain) JWNavigationController *navigationController;
@property (nonatomic, retain) JWSlideMenuController *slideMenu;
@property (nonatomic, retain) JWSlideMenuController *slideMenuController;
@property (nonatomic,strong)  NSString* ssh_serverName;
@property BOOL AdActiveFLG;
@property (nonatomic,strong) NSDateFormatter *dateFormatter;
@property (nonatomic,strong) NSString *DocumentPath,*CachePath;
-(CGRect)objcLayOutCyouSei;
-(UIColor*)objcHexStr:(NSString *)hexStr : (CGFloat)alpha;
-(UILabel*)TitleLabel:(NSString *)Message : (UIColor*)Color;
-(void)showAlert:(NSString *)title : (NSString *)text;
-(UIButton*)makeButton:(CGRect)frame : (NSString *)text :(int)tag ;
- (NSString*)KMByteStrings:(long)Bytes;
-(NSString*)IconImageFileName:(NSString*)pathExtension;
-(BOOL)DB_SMB:(NSString*)LastServer;
@end
