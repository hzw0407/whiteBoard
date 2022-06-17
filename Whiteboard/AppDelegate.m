//
//  AppDelegate.m
//  Whiteboard
//
//  Created by HZW on 2018/6/12.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "AppDelegate.h"
#import "TQLHomeController.h"
#import <UMShare/UMShare.h>
#import <UMCommon/UMCommon.h>
#import "TQLEditHandwritingController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    TQLEditHandwritingController *vc = [[TQLEditHandwritingController alloc] init];
    UINavigationController *nacVC = [[UINavigationController alloc] initWithRootViewController:vc];
    nacVC.navigationBarHidden = YES;
    self.window.rootViewController = nacVC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    //初始化友盟SDK
    [UMConfigure initWithAppkey:UMAPPKEY channel:@"App Store"];
    //设置打开日志 输出可供调试参考的log信息. 发布产品时必须设置为NO.
    [UMConfigure setLogEnabled:NO];
    //第三方平台初始化
    [self confitUShareSettings];
    
    return YES;
}

//未安装新浪微博客户端会弹出Webview进行登录和分享，之后会回调至以下函数
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (void)confitUShareSettings
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WXAPPID appSecret:WXAppSecret redirectURL:@"http://mobile.umeng.com/social"];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQAPPID  appSecret:QQAppSecret redirectURL:@"tencent1106784333"];
    
    /* 设置新浪的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:WBAPPID appSecret:WBAppSecret redirectURL:@"https://itunes.apple.com/cn/genre/%E9%9F%B3%E4%B9%90/id34"];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //即将进入后台
    [[NSNotificationCenter defaultCenter] postNotificationName:@"willResignActive" object:nil userInfo:nil];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    //已经进入后台
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    //即将进入前台
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    //已经在前台
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didBecomeActive" object:nil userInfo:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
