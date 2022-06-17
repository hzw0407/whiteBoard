//
//  TQLBaseNavigationController.m
//  Whiteboard
//
//  Created by HZW on 2018/6/12.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLBaseNavigationController.h"

@interface TQLBaseNavigationController ()

@property (nonatomic, strong) UINavigationBar *navigationBar;

@end

@implementation TQLBaseNavigationController
#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupNavigation];
    [self setupLeftButtonTitle:nil];
    [self setupPopGesture];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //    [self setStatusBarBackgroundColor:[UIColor mainColor]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.tabBarController.tabBar setHidden:YES];
    
}

#pragma mark - CustomMethod
//设置状态栏背景色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

//设置导航栏颜色
- (void)setNavigatinBarBackgroundColor:(UIColor *)color{
    self.navigationBar.barTintColor = color;
}

- (void)setupNavigation {
    
    [self.view addSubview:self.navigationBar];
    self.navigationBar.items = @[self.navItem];
}

/**
 启动系统手势返回
 */
- (void)setupPopGesture{
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }
}

//隐藏导航栏
- (void)hideNavigation{
    //    [self setStatusBarBackgroundColor:[UIColor clearColor]];
    [self.navigationBar removeFromSuperview];
}

//设置导航栏标题
- (void)setupNavTitle:(NSString *)title{
    self.navItem.title = title;
}

//自定义导航栏标题view
- (void)setupNavTitleView:(UIView *)view{
    self.navItem.titleView = view;
}

//设置导航栏左边按钮文字
- (void)setupLeftButtonTitle:(NSString *)title{
    [self setupLeftButtonTitle:title textColor:[UIColor whiteColor]];
}

//设置导航栏左边文字和颜色
- (void)setupLeftButtonTitle:(NSString *)title textColor:(UIColor *)color{
    UIImage *backImage =  [IMAGENAME(@"default_return") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    leftButton.titleLabel.font = [UIFont systemFontOfSize:28];
    [leftButton setTitleColor:color forState:UIControlStateNormal];
    [leftButton setTitle:title forState:UIControlStateNormal];
    [leftButton setImage:backImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(clickedNavLeft) forControlEvents:UIControlEventTouchUpInside];
    
    leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navItem.leftBarButtonItem = leftItem;
}

/**
 清除左边view
 */
- (void)setupLeftViewClear{
    self.navItem.leftBarButtonItem = nil;
    self.navItem.leftBarButtonItems = nil;
}

//设置右边按钮文字
- (void)setupRightButtonTitle:(NSString *)title{
    [self setupRightButtonTitle:title textColor:[UIColor whiteColor]];
}

//设置右边按钮文字和颜色
- (void)setupRightButtonTitle:(NSString *)title textColor:(UIColor *)color{
    [self setupRightButtonTitle:title textColor:color image:nil];
}

//设置右边按钮图片
- (void)setupRightButtonImage:(UIImage *)image{
    [self setupRightButtonTitle:nil textColor:nil image:image];
}

//右边按钮设置
- (void)setupRightButtonTitle:(NSString *)title textColor:(UIColor *)color image:(UIImage *)image
{
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    [rightButton setTitleColor:color forState:UIControlStateNormal];
    [rightButton setTitle:title forState:UIControlStateNormal];
    [rightButton setImage:image forState:UIControlStateNormal];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    rightButton.titleLabel.font = GETFONT(16);
    [rightButton addTarget:self action:@selector(clickedNavRight) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navItem.rightBarButtonItem = rightItem;
}

//自定义导航栏左边
- (void)setupLeftView:(UIView *)view {
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navItem.leftBarButtonItem = leftItem;
}

//自定义导航栏右边
- (void)setupRightView:(UIView *)view {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navItem.rightBarButtonItem = rightItem;
}

//设置导航栏颜色
- (void)setupNavigationColor:(UIColor *)color{
    self.navigationBar.barTintColor = color;
    UIView *barView =(UIView *)[self.navigationBar viewWithTag:100];
    barView.backgroundColor = color;
}

#pragma mark - ClickMethod
- (void)clickedNavLeft{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickedNavRight{
    
}

//返回指定vc
- (void)backToVC:(UIViewController *)vc{
    NSArray *array = self.navigationController.viewControllers;
    
    UIViewController *toVC = nil;
    for (NSInteger i = array.count - 1; i >= 0; i--) {
        UIViewController *tempVC = array[i];
        if ([tempVC isKindOfClass:[vc class]]) {
            toVC = tempVC;
            break;
        }
    }
    
    if (toVC) {
        [self.navigationController popToViewController:toVC animated:YES];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - SystemDelegate

#pragma mark - CustomDelegate

#pragma mark - GetterAndSetter
- (UINavigationBar *)navigationBar {
    if (!_navigationBar) {
        _navigationBar = [UINavigationBar new];
        _navigationBar.frame = (CGRect){0, STATUSBAR_HEIGHT, SCREEN_WIDTH, 44};
        _navigationBar.barTintColor = RGB_COLOR(255, 255, 255);
        
        //状态栏添加背景色view
        UIView *barView = [[UIView alloc] initWithFrame:CGRectMake(0,-STATUSBAR_HEIGHT, self.view.frame.size.width, STATUSBAR_HEIGHT)];
        barView.backgroundColor = RGB_COLOR(255, 255, 255);
        barView.tag = 100;
        [_navigationBar addSubview:barView];
        
    }
    return _navigationBar;
}

- (UINavigationItem *)navItem {
    if (!_navItem) {
        _navItem = [UINavigationItem new];
    }
    return _navItem;
}

@end
