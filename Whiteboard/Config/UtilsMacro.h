//
//  UtilsMacro.h
//  SmartPen
//
//  Created by 刘星 on 2018/4/12.
//  Copyright © 2018年 L. All rights reserved.
//

#ifndef UtilsMacro_h
#define UtilsMacro_h

//#pragma mark - Size
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define SCREEN_BOUNDS [UIScreen mainScreen].bounds

#define AUTOSCALE_HEIGHT(H) ((SCREEN_HEIGHT/667)*H)

#define AUTOSCALE_WIDTH(W) ((SCREEN_WIDTH/375.0)*W)

#define IS_Pad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define IS_IPHONE_X (SCREEN_WIDTH == 375.0 && SCREEN_HEIGHT == 812.0)

#define TOP_MARGIN (IS_IPHONE_X ? 88.0 : 64.0)

#define TABBAR_HEIGHT (IS_IPHONE_X ? (49.0+34.0) : 49.0)

#define STATUSBAR_HEIGHT (IS_IPHONE_X ? 44:20)

#define ACTUAL_RECT (CGRect){0, TOP_MARGIN, SCREEN_WIDTH, SCREEN_HEIGHT - TOP_MARGIN}

#define CORNRRRADIUS 5.0

#define IMAGENAME(name) [UIImage imageNamed:name]
#define UrlImage(name) [NSURL URLWithString:name]

//NSUserDefaults
#define USER_DEFAULTS_SET(object, key) ({\
NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];\
[userDefault setObject:object forKey:key];\
[userDefault synchronize];})

#define USER_DEFAULTS_GET_OBJECT(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]

#define USER_DEFAULTS_GET_STRING(key) [[NSUserDefaults standardUserDefaults] stringForKey:key]

#define USER_DEFAULTS_GET_ARRAY(key) [ [NSUserDefaults standardUserDefaults] arrayForKey:key]

//#pragma mark - UIColor

#define RandColor RGB_COLOR(arc4random_uniform(255), arc4random_uniform(255), arc4random_uniform(255))

#define RGBA_COLOR(R, G, B, A) [UIColor colorWithRed:((R) / 255.0f) \
green:((G) / 255.0f) \
blue:((B) / 255.0f) \
alpha:A]

#define RGB_COLOR(R,G,B) [UIColor colorWithRed:((R) / 255.0f) \
green: ((G) / 255.0f) \
blue:((B) / 255.0f) \
alpha: 1.0f]

#define COLOR_WITH_HEX(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1.0f]

#define HEX_FROM_COLOR(color) ({ \
if (CGColorGetNumberOfComponents(color.CGColor) < 4) { \
const CGFloat *components = CGColorGetComponents(color.CGColor); \
color = [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]]; \
} \
NSString *hex = (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) ? [NSString stringWithFormat:@"#FFFFFF"] : [NSString stringWithFormat:@"#%02X%02X%02X", (int)((CGColorGetComponents(color.CGColor))[0]*255.0), (int)((CGColorGetComponents(color.CGColor))[1]*255.0), (int)((CGColorGetComponents(color.CGColor))[2]*255.0)]; \
(hex); \
})

#define CKGColor(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define CKGAColor(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f \
alpha:(a)]

#define DEFAULT_GRAYCOLOR RGB_COLOR(238, 238, 238)

#define GETFONT(x) [UIFont fontWithName:@"Helvetica" size:x]
#define GETCustomFont(fontName,fontSize) [UIFont fontWithName:fontName size:fontSize]




#endif /* UtilsMacro_h */
