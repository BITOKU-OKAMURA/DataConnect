//
//  JWSlideMenuController.h
//  JWSlideMenu
//
//  Created by Jeremie Weldin on 11/14/11.
//  Copyright (c) 2011 Jeremie Weldin. All rights reserved.
//

#import "stdafx.h"
@class JWNavigationController;
@class JWSlideMenuViewController;
@interface JWSlideMenuController : UIViewController <UITableViewDataSource, UITableViewDelegate,ADBannerViewDelegate,GADBannerViewDelegate>{
@private int view_index;
}
@property (retain, nonatomic) UITableView *menuTableView;
@property (retain, nonatomic) UIView *menuView;
@property (retain, nonatomic) UIToolbar *contentToolbar;
@property (retain, nonatomic) UIView *contentView;
@property (retain, nonatomic) UIColor *menuLabelColor;
@property                     BOOL ADactive;
@property (retain, nonatomic) NSTimer *ADTimer;
@property (retain, nonatomic) GADBannerView *AdMobView;
@property (retain, nonatomic) UIActivityIndicatorView *actInd;
@property (retain, nonatomic) GADRequest *AdMobRequest;
@property (strong, nonatomic) NSString *CurrentTitle;
-(IBAction)toggleMenu;
-(JWNavigationController *)addViewController:(JWSlideMenuViewController *)controller withTitle:(NSString *)title andImage:(UIImage *)image;
-(void)AdViewLoad;
-(void)AdMobViewStatus;
-(void)ADLayOutCyousei;
@end
