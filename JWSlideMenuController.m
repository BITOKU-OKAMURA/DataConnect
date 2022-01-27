//
//  JWSlideMenuController.m
//  JWSlideMenu
//
//  Created by Jeremie Weldin on 11/14/11.
//  Copyright (c) 2011 Jeremie Weldin. All rights reserved.
//
// ここでは広告とメニューの制御しかしない。
// バックグラウンドの処理は AppDalegate内で実施。
// RootVieeController廃止
//

#import "JWSlideMenuController.h"
#import "JWNavigationController.h"
#import "JWSlideMenuViewController.h"
// Swift側の定義を読み込む
#import "DataConnect-Swift.h"
@implementation JWSlideMenuController{
//@private  ViewController *SwiftView;
@private  CommonFunction *Common;
}
@synthesize menuView;
@synthesize contentToolbar;
@synthesize menuTableView;
@synthesize contentView;
@synthesize menuLabelColor,AdMobView,actInd,AdMobRequest,ADactive,ADTimer,CurrentTitle;

- (id)init
{
    self = [super init];
    if (self) {

        //-------------------------------------------------------------------------
        // swift側共通関数のキャスト
        // swift側の ViewController AppDelegateは双方で見れないので注意
        //-------------------------------------------------------------------------
        Common = [[CommonFunction alloc] init];//ロジックやエンティティの共通クラス群
        //SwiftView = [[ViewController alloc] init];//Viewの共通クラス群

        self->view_index = 0;
        //-------------------------------------------------------------------------
        // 広告読み込みインデクター初期設定
        //-------------------------------------------------------------------------
        actInd = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        actInd.color =[UIColor whiteColor];
        actInd.center = self.view.center;
        actInd.hidesWhenStopped = true;
        
        //-------------------------------------------------------------------------
        // 広告表示
        //-------------------------------------------------------------------------
        AdMobRequest = [GADRequest request];
        //AdMobRequest.testDevices = [NSArray arrayWithObjects:kGADSimulatorID,@"02f60757d110f5286a2b073897343ed4",@"a0ca456de9acc1472aa5c8ec8a41bd55",nil];
        AdMobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        self.AdMobView.frame = CGRectMake(0,StatusBarhHeight+NavigationBarHeight,AdMobView.bounds.size.width,AdMobView.bounds.size.height);
        AdMobView.adUnitID = @"ca-app-pub-6256230652309426/2548647390";//自分のアカウント
        //AdMobView.adUnitID = @"ca-app-pub-3940256099942544/2934735716";//Google指定のテストアカウント



        AdMobView.rootViewController = self;
        self.AdMobView.backgroundColor = [UIColor clearColor];
        AdMobView.delegate = self;
        AdMobView.hidden = YES;
        ADactive = NO;
        

        //----------------------------------------------------------
        // UIActivityIndicatorの座標定義
        //----------------------------------------------------------
        actInd.frame = CGRectMake(
                                  (AdMobView.bounds.size.width/2) - (actInd.bounds.size.width/2),
                                  AdMobView.frame.origin.y + (AdMobView.bounds.size.height/2) - (actInd.bounds.size.height/2),
                                  actInd.bounds.size.width,
                                  actInd.bounds.size.height
                                  );
        
        //-------------------------------------------------------------------------
        // 広告をロード
        //-------------------------------------------------------------------------
        [self AdViewLoad];
        
        //-------------------------------------------------------------------------
        // 広告チェックタイマー始動
        //-------------------------------------------------------------------------
        ADTimer=[NSTimer scheduledTimerWithTimeInterval:120.0
                                                 target:self
                                               selector:@selector(AdViewLoad)
                                               userInfo:nil
                                                repeats:YES
                 ];

        /*
         #define StatusBarhHeight 20.0
         #define NavigationBarHeight 44.0
         #define ToolBarHeight 44.0
         #define TabBarHeight 49.0
         
         */
        CGRect masterRect = self.view.bounds;
        float menuWidth = 267.0; //masterRect.size.width - 53
        
        CGRect menuFrame = CGRectMake(0.0, 10.0, menuWidth, masterRect.size.height);
        CGRect contentFrame = CGRectMake(0.0, 0.0, masterRect.size.width, masterRect.size.height );
        
        self.menuLabelColor = [UIColor grayColor];
        
        self.menuTableView = [[UITableView alloc] initWithFrame:menuFrame];
        self.menuTableView.dataSource = self;
        self.menuTableView.delegate = self;
        self.menuTableView.backgroundColor = [UIColor darkGrayColor];
        self.menuTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.menuTableView.separatorColor = [UIColor grayColor];

    //----------------------------------------------------------
    // 区切り線の幅を調整
    //----------------------------------------------------------
    if ([self.menuTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.menuTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    self.menuTableView.separatorInset = UIEdgeInsetsZero;
    if ([self.menuTableView respondsToSelector:@selector(layoutMargins)]) {
        self.menuTableView.layoutMargins = UIEdgeInsetsZero;
    }

        self.menuView = [[UIView alloc] initWithFrame:menuFrame];
        [self.menuView addSubview:self.menuTableView];
        
        self.contentView = [[UIView alloc] initWithFrame:contentFrame];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.contentView.backgroundColor = [UIColor grayColor];
        
        //-------------------------------------------------------------------------
        // 各種Viewの表示
        //-------------------------------------------------------------------------
        [self.view addSubview:self.menuView];
        [self.view insertSubview:self.contentView aboveSubview:self.menuView];
        [self.view addSubview:AdMobView];
        [self.view addSubview:actInd];
        
    }
    return self;
}

//-----------------------------------------------------------------------------
//自動画面回転時の配置替え
//-----------------------------------------------------------------------------
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)FromInterfaceOrientation {
[self ADLayOutCyousei];
}

-(void)ADLayOutCyousei {

    CGRect myBounds = [[UIScreen mainScreen] bounds];
    BOOL YokoMukiFLG = [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait ? NO : YES;
    AdMobView.adSize = YokoMukiFLG ? kGADAdSizeSmartBannerLandscape : kGADAdSizeSmartBannerPortrait;
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
    // AdViewの定義
    //----------------------------------------------------------
    self.AdMobView.frame = CGRectMake(
                                      sc_x/2-self.AdMobView.bounds.size.width/2,
                                      StatusBarhHeight+NavigationBarHeight  ,
                                      //0,
                                      self.AdMobView.bounds.size.width,
                                      self.AdMobView.bounds.size.height
                                      );
    
    //----------------------------------------------------------
    // UIActivityIndicatorの定義
    //----------------------------------------------------------
    self.actInd.frame = CGRectMake(
                                   (sc_x/2) - (self.actInd.bounds.size.width/2),
                                   self.AdMobView.frame.origin.y + (self.AdMobView.bounds.size.height/2) - (self.actInd.bounds.size.height/2),
                                   self.actInd.bounds.size.width,
                                   self.actInd.bounds.size.height
                                   );
    [self AdMobViewStatus];
}

/**
 *
 * GADBannerView デリゲード
 *
 * @param
 * @return
 * @exception
 * @see
 * @since
 * @deprecated
 */
-(void)AdViewLoad{
    if([Common isConnectedToNetwork]) {
        [AdMobView loadRequest:AdMobRequest];
        [actInd startAnimating];// インダクター回転
        [self.view bringSubviewToFront:actInd];
        ADactive = YES;
    } else {
        [actInd stopAnimating];// インダクター停止
        AdMobView.hidden = YES;
        [self.view sendSubviewToBack:actInd];
        ADactive = NO;
    }
    [self ADLayOutCyousei];
}

/**
 *
 * GADBannerView デリゲード
 *
 * @param
 * @return
 * @exception
 * @see
 * @since
 * @deprecated
 */
//広告が正常に表示された場合のデリゲード
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    ADactive = YES;
    AdMobView.hidden = NO;
//スナップショット撮影用
    //ADactive = NO;
   // AdMobView.hidden = YES;

    if([actInd isAnimating]){
        [actInd stopAnimating];//UIActivityIndicator停止
        [self.view sendSubviewToBack:actInd];
    }
    [self AdMobViewStatus];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    ADactive = NO;
    AdMobView.hidden = YES;
    if([actInd isAnimating]){
        [actInd stopAnimating];//UIActivityIndicator停止
        [self.view sendSubviewToBack:actInd];
    }
    NSLog(@"◆ 広告エラー\n");
    [self AdMobViewStatus];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction)toggleMenu
{
    [SVProgressHUD dismiss];
    [UIView beginAnimations:@"Menu Slide" context:nil];
    [UIView setAnimationDuration:0.2];
    if(self.contentView.frame.origin.x == 0) //Menu is hidden
    {
        [ADTimer invalidate];
        CGRect newFrame = CGRectOffset(self.contentView.frame, self.menuView.frame.size.width, 0.0);
        self.contentView.frame = newFrame;
    }
    else //Menu is shown
    {
        if(![ADTimer isValid]){
            ADTimer=[NSTimer scheduledTimerWithTimeInterval:120.0
                                                     target:self
                                                   selector:@selector(AdViewLoad)
                                                   userInfo:nil
                                                    repeats:YES
                     ];
        }
        [menuTableView reloadData];
        CGRect newFrame = CGRectOffset(self.contentView.frame, -(self.menuView.frame.size.width), 0.0);
        self.contentView.frame = newFrame;
    }
    
    //-------------------------------------------------------------------------
    // 広告Viewも同調 (X座標変更の為、共通メンバで処理は不可能)
    //-------------------------------------------------------------------------
    AdMobView.frame = CGRectMake(contentView.frame.origin.x,AdMobView.frame.origin.y,AdMobView.bounds.size.width,AdMobView.bounds.size.height);
    actInd.frame = CGRectMake(
                              AdMobView.frame.origin.x + (AdMobView.bounds.size.width/2) - (actInd.bounds.size.width/2),
                              AdMobView.frame.origin.y + (AdMobView.bounds.size.height/2) - (actInd.bounds.size.height/2),
                              actInd.bounds.size.width,
                              actInd.bounds.size.height
                              );
    [UIView commitAnimations];
}

-(JWNavigationController *)addViewController:(JWSlideMenuViewController *)controller withTitle:(NSString *)title andImage:(UIImage *)image
{

    JWNavigationController *navController = [[JWNavigationController alloc] initWithRootViewController:controller];
    navController.slideMenuController = self;
    navController.title = title;
    navController.tabBarItem.image = image;
    
    [self addChildViewController:navController];
    
    if([self.childViewControllers count] == 1)
    {
        [self.contentView addSubview:navController.view];
    }
    
    return navController;
}

#pragma mark - UITableViewDataSource/Delegate

-(CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath{

      if(indexPath.section == 0){
        return 36.0;  // １番目のセクションの行の高さを30にする
      }else{
        return 50.0;  // それ以外の行の高さを50にする
      }
}

#pragma mark - UITableViewDataSource/Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        // Do something here......................
    }
    
    //TODO: either support tabbaritem or a protocol in order to handle images in the menu.
    
    UIViewController *controller = (UIViewController *)[self.childViewControllers objectAtIndex:indexPath.row] ;
    cell.textLabel.text = controller.title;
    //cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.textColor = (view_index != indexPath.row) ? [UIColor whiteColor] : [UIColor colorWithRed:56.0f/255.0f green:56.0f/255.0f blue:56.0f/255.0f alpha:0.5f] ;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image = controller.tabBarItem.image;
    //UIGraphicsBeginImageContext(CGSizeMake(20, 20));
    //[cell.imageView.image drawInRect:CGRectMake(0, 0, 20, 20)];
    //cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsEndImageContext();
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.childViewControllers count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UIViewController *previousChildViewController =
    //[self transitionFromViewController:previousChildViewController toViewController:newController duration:0.5 options:UIViewAnimationOptionTransitionFlipFromLeft animations:NULL completion:NULL];
    
    if (view_index != indexPath.row){
        if([contentView.subviews count] == 1){
            [[contentView.subviews objectAtIndex:0] removeFromSuperview];
        }
        UIViewController* controller = (UIViewController*)[self.childViewControllers objectAtIndex:indexPath.row];
        controller.view.frame = self.contentView.bounds;
        CurrentTitle = controller.title;
        [contentView addSubview:controller.view];
        view_index = (int)indexPath.row;
    }
    [self toggleMenu];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setMenuView:nil];
    [self setContentView:nil];
    [self setMenuTableView:nil];
    [self setMenuLabelColor:nil];
    [super viewDidUnload];
}

-(void)AdMobViewStatus{
[[NSUserDefaults standardUserDefaults] setBool:AdMobView.hidden forKey:@"AdMobView_hidden"];
[[NSUserDefaults standardUserDefaults] setBool:ADactive forKey:@"ADactive"];
[[NSUserDefaults standardUserDefaults] setFloat:AdMobView.bounds.size.height forKey:@"AdMobView_height"];
[[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
@end
