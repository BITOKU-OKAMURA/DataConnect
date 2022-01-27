//
//  JWNavigationController.m
//  JWSlideMenu
//
//  Created by Jeremie Weldin on 11/22/11.
//  Copyright (c) 2011 Jeremie Weldin. All rights reserved.
//

#import "JWNavigationController.h"
#import "JWSlideMenuViewController.h"
@interface JWNavigationController(Private)

-(UIViewController*)removeTopViewController;

@end

@implementation JWNavigationController

@synthesize navigationBar;
@synthesize contentView;
@synthesize slideMenuController;
@synthesize rootViewController=_rootViewController;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        
        CGRect masterRect = [[UIScreen mainScreen] bounds];
        
        //CGRect contentFrame = CGRectMake(0.0, 0.0, masterRect.size.width, masterRect.size.height);
        //CGRect navBarFrame = CGRectMake(0.0, 0.0, masterRect.size.width, 44.0);
        
        CGRect contentFrame =  CGRectMake(0.0, NavigationBarHeight + StatusBarhHeight , masterRect.size.width, masterRect.size.height - NavigationBarHeight  - StatusBarhHeight  );
        CGRect navBarFrame =   CGRectMake(0.0, StatusBarhHeight , masterRect.size.width, NavigationBarHeight );
        
        self.view = [[[UIView alloc] initWithFrame:masterRect] autorelease];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.view.alpha = 1.0;
        //self.view.backgroundColor = [UIColor blackColor];//ナビゲーションバーの色
        self.view.backgroundColor = [UIColor clearColor];
        self.contentView = [[[UIView alloc] initWithFrame:contentFrame] autorelease];
        self.contentView.backgroundColor = [UIColor grayColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.contentView];
        
        self.navigationBar = [[[UINavigationBar alloc] initWithFrame:navBarFrame] autorelease];
        self.navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.navigationBar.delegate = self;
        self.navigationBar.tintColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        [self.view insertSubview:self.navigationBar aboveSubview:self.contentView];
        
    }
    return self;
}

//-----------------------------------------------------------------------------
//自動画面回転時の配置替え
//-----------------------------------------------------------------------------
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)FromInterfaceOrientation {
    CGRect myBounds = [[UIScreen mainScreen] bounds];
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
    self.contentView.frame =   CGRectMake(0.0,
                                          NavigationBarHeight + StatusBarhHeight ,
                                          sc_x,
                                          sc_y - NavigationBarHeight - StatusBarhHeight);
    self.navigationBar.frame = CGRectMake(0.0, StatusBarhHeight ,sc_x , NavigationBarHeight );
}

- (id)initWithRootViewController:(JWSlideMenuViewController *)rootViewController
{
    //2014.09.18 Xcode5.1の不具合にて警告非表示(未改修)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    self = [self init];
    if(self) {
        _rootViewController = rootViewController;
        //UIBarButtonItem *menuButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_list_bullets.png"] style:UIBarButtonItemStyleBordered target:self.slideMenuController action:@selector(toggleMenu)] autorelease];
        //rootViewController.navigationItem.leftBarButtonItem = menuButton;
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_blackbase.png"] forBarMetrics:UIBarMetricsDefault];
        //self.navigationBar.tintColor =[UIColor colorWithRed:78.0f/255.0f green:109.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        self.navigationBar.tintColor = [UIColor whiteColor];
        //self.navigationBar.barTintColor = [UIColor whiteColor];
        [self addChildViewController:rootViewController];
        [self.contentView addSubview:rootViewController.view];
        [self.navigationBar pushNavigationItem:rootViewController.navigationItem animated:YES];
        rootViewController.navigationController = self;
    }
    return self;
}

#pragma mark - UINavigationBarDelegate

- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    UIViewController *controller = [self.childViewControllers lastObject];
    
    if (item==controller.navigationItem) //Will now called only if a back button pop happens, not in manual pops
    {
        [self removeTopViewController];
    }
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item
{
    
}

#pragma mark - Stack Interaction

- (void)pushViewController:(JWSlideMenuViewController *)controller
{
    [self addChildViewController:controller];
    [self.navigationBar pushNavigationItem:controller.navigationItem animated:YES];
    controller.navigationController = self;
    
    controller.view.frame = self.contentView.bounds;
    
    if([self.childViewControllers count] == 1)
    {
        [self.contentView addSubview:controller.view];
    }
    else
    {
        UIViewController *previousController = [self.childViewControllers   objectAtIndex:[self.childViewControllers count]-2];
        [self transitionFromViewController:previousController toViewController:controller duration:0.5 options:UIViewAnimationOptionTransitionNone animations:NULL completion:NULL];
    }
}

- (UIViewController *)popViewController
{
    //Can use this to pop manually rather than back button alone
    UIViewController *controller = [self.childViewControllers lastObject];
    UIViewController *previousController = nil;
    if([self.childViewControllers count] > 1)
    {
        previousController = [self.childViewControllers objectAtIndex:[self.childViewControllers count]-2];
        previousController.view.frame = self.contentView.bounds;
    }
    
    [self transitionFromViewController:controller toViewController:previousController duration:0.3 options:UIViewAnimationOptionTransitionNone animations:NULL completion:NULL];
    [controller removeFromParentViewController];
    
    if(self.navigationBar.items.count > self.childViewControllers.count)
        [self.navigationBar popNavigationItemAnimated:YES];
    
    return controller;
}

- (void)viewDidUnload
{
    _rootViewController = nil;
    self.navigationBar = nil;
    self.contentView = nil;
    
    self.slideMenuController = nil;
    
    [super viewDidUnload];
}

- (void)dealloc {
    [_rootViewController release];
    [navigationBar release];
    [contentView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

-(UIViewController*)removeTopViewController
{
    UIViewController *controller = [self.childViewControllers lastObject];
    
    UIViewController *previousController = nil;
    if([self.childViewControllers count] > 1)
    {
        previousController = [self.childViewControllers objectAtIndex:[self.childViewControllers count]-2];
        previousController.view.frame = self.contentView.bounds;
        
        
    }
    
    
    [self transitionFromViewController:controller toViewController:previousController duration:0.3 options:UIViewAnimationOptionTransitionNone animations:NULL completion:NULL];
    [controller removeFromParentViewController];
    
    return controller;
}

@end
