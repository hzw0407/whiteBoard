//
//  UIColor+Commonly.m
//  SmartPen
//
//  Created by HZW on 2018/4/29.
//  Copyright © 2018年 L. All rights reserved.
//

#import "UIColor+Commonly.h"

@implementation UIColor (Commonly)
/**
 主体背景颜色
 
 @return 淡蓝色
 */
+ (UIColor *)mainColor{
//    return RGB_COLOR(242, 248, 255);
    return [UIColor colorWithHexString:@"#f2f8ff"];
}

/**
 线的颜色
 
 @return 实例
 */
+ (UIColor *)lineColor{
    //    return [UIColor colorWithHexString:@"a09fa0"];
    return [UIColor colorWithHexString:@"cbcbcc"];
}

/**
 文字颜色
 
 @return 实例
 */
+ (UIColor *)textColor{
    return [UIColor colorWithHexString:@"#4e78ff"];
}

@end
