//
//  MBProgressHUD+PD.m
//  SmartPen
//
//  Created by HZW on 2018/4/18.
//  Copyright © 2018年 L. All rights reserved.
//

#import "MBProgressHUD+PD.h"

@implementation MBProgressHUD (PD)

/**
 显示信息

 @param text 信息内容
 @param icon 图标
 @param view 显示的视图
 */
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    hud.label.textColor = [UIColor whiteColor];
    //hud.bezelView.style = MBProgressHUDBackgroundStyleSolidCo;
    hud.label.font = [UIFont systemFontOfSize:17.0];
    hud.userInteractionEnabled = NO;
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    //背景颜色
    hud.bezelView.backgroundColor = [UIColor grayColor];
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 1.5秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
    
}

/**
 菊花加载框
 
 @param info 提示文字
 */
+ (void)showLoading:(NSString *)info{
    
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    hud.label.text = info;
    hud.label.textColor = [UIColor whiteColor];
    //hud.bezelView.style = MBProgressHUDBackgroundStyleSolidCo;
    hud.label.font = [UIFont systemFontOfSize:17.0];
    hud.userInteractionEnabled = NO;
    //背景颜色
    hud.bezelView.backgroundColor = [UIColor grayColor];
    // 设置菊花模式
    hud.mode = MBProgressHUDModeIndeterminate;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
}

/**
 提示成功信息

 @param success 成功信息内容
 */
+ (void)showSuccess:(NSString *)success {
    [self showSuccess:success toView:nil];
    
}

/**
 提示成功信息

 @param success 成功信息内容
 @param view 显示成功信息view
 */
+ (void)showSuccess:(NSString *)success toView:(UIView *)view {
    [self show:success icon:@"MB_Success" view:view];
    
}

/**
 提示错误信息

 @param error 错误信息view
 */
+ (void)showError:(NSString *)error {
    [self showError:error toView:nil];
    
}

/**
 提示错误信息

 @param error 错误信息
 @param view 显示信息view
 */
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"MB_Fail" view:view];
    
}

/**
 提示信息

 @param message 信息内容
 @return 直接返回一个MBProgressHUD， 需要手动关闭
 */
+ (MBProgressHUD *)showMessage:(NSString *)message afterTime:(NSTimeInterval)time{
    return [self showMessage:message toView:nil afterTime:time];
    
}

/**
 提示信息
 
 @param message 信息内容
 @return 返回实例 默认1.5秒后自动关闭
 */
+ (MBProgressHUD *)showMessage:(NSString *)message{
    return [self showMessage:message toView:nil afterTime:1.5];
}

/**
 显示信息

 @param message 信息内容
 @param view 需要显示信息的试图
 @return 直接返回一个MBProgressHUD，需要手动关闭
 */
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view afterTime:(NSTimeInterval)time{
    if (view == nil) {
        view = [[UIApplication sharedApplication].windows lastObject];
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    //设置模式 不显示图标
    hud.mode = MBProgressHUDModeText;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    
    if (time > 0) {
        // n秒之后再消失
        [hud hideAnimated:YES afterDelay:time];
    }
    
    return hud;
    
}

/**
 手动关闭MBProgressHUD
 */
+ (void)hideHUD {
    [self hideHUDForView:nil];
    
}

/**
 关闭MBProgressHUD的视图

 @param view 传入的view
 */
+ (void)hideHUDForView:(UIView *)view {
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view animated:YES];
    
}

@end
