//
//  UIColor+HEX.h
//  SmartPen
//
//  Created by L on 2017/9/15.
//  Copyright © 2017年 L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HEX)

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert withAlpha:(CGFloat)alpha;

+ (UIColor *)colorWithRGBHex:(UInt32)hex;

+ (UIColor *)colorWithRGBHex:(UInt32)hex withAlpha:(CGFloat)alpha;

+ (NSString *)hexStringFromColor:(UIColor *)color;

@end
