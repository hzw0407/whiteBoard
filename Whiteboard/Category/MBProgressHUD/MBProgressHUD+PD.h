//
//  MBProgressHUD+PD.h
//  SmartPen
//
//  Created by HZW on 2018/4/18.
//  Copyright © 2018年 L. All rights reserved.
//

#import "MBProgressHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (PD)
/**
 提示成功信息
 
 @param success 成功信息内容
 */
+ (void)showSuccess:(NSString *)success;

/**
 提示成功信息
 
 @param success 成功信息内容
 @param view 显示成功信息view
 */
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

/**
 提示错误信息
 
 @param error 错误信息view
 */
+ (void)showError:(NSString *)error;

/**
 提示错误信息
 
 @param error 错误信息
 @param view 显示信息view
 */
+ (void)showError:(NSString *)error toView:(UIView *)view;

/**
 提示信息

 @param message 信息内容
 @param time 过几秒后自动消失
 @return 返回实例 没设置时间需手动关闭
 */
+ (MBProgressHUD *)showMessage:(NSString *)message afterTime:(NSTimeInterval)time;

/**
 提示信息

 @param message 信息内容
 @return 返回实例 默认1.5秒后自动关闭
 */
+ (MBProgressHUD *)showMessage:(NSString *)message;

/**
 提示信息

 @param message 信息内容
 @param view 显示提示信息view
 @param time 过几秒后自动消失
 @return 返回实例 没设置时间需手动关闭
 */
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view afterTime:(NSTimeInterval)time;

/**
 菊花加载框

 @param info 提示文字
 */
+ (void)showLoading:(NSString *)info;

/**
 隐藏提示框
 */
+ (void)hideHUD;

/**
 隐藏提示框

 @param view 提示框所在的view
 */
+ (void)hideHUDForView:(UIView *)view;

@end
