//
//  TQLBaseNavigationController.h
//  Whiteboard
//
//  Created by HZW on 2018/6/12.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TQLBaseNavigationController : UIViewController

@property (nonatomic, strong) UINavigationItem *navItem;

/**
 隐藏导航栏
 */
- (void)hideNavigation;

/**
 点击左边按钮
 */
- (void)clickedNavLeft;

/**
 点击右边按钮
 */
- (void)clickedNavRight;

/**
 返回到指定VC
 
 @param vc 指定控制器
 */
- (void)backToVC:(UIViewController *)vc;

/**
 设置导航栏标题
 
 @param title 标题文字
 */
- (void)setupNavTitle:(NSString *)title;

/**
 自定义导航栏标题view
 
 @param view 自定义view
 */
- (void)setupNavTitleView:(UIView *)view;

/**
 导航条左边按钮
 
 @param title 文字
 */
- (void)setupLeftButtonTitle:(NSString *)title;

/**
 导航条左边按钮
 
 @param title 文字
 @param color 颜色
 */
- (void)setupLeftButtonTitle:(NSString *)title textColor:(UIColor *)color;

/**
 清除左边view
 */
- (void)setupLeftViewClear;

/**
 导航条右边按钮
 
 @param title 文字
 */
- (void)setupRightButtonTitle:(NSString *)title;

/**
 导航条右边按钮
 
 @param title 文字
 @param color 颜色
 */
- (void)setupRightButtonTitle:(NSString *)title textColor:(UIColor *)color;

/**
 导航条右边按钮
 
 @param image 图片
 */
- (void)setupRightButtonImage:(UIImage *)image;

/**
 自定义导航条左边
 
 @param view view description
 */
- (void)setupLeftView:(UIView *)view;

/**
 自定义导航条右边
 
 @param view view description
 */
- (void)setupRightView:(UIView *)view;

/**
 设置导航栏颜色

 @param color 颜色
 */
- (void)setupNavigationColor:(UIColor *)color;

@end
