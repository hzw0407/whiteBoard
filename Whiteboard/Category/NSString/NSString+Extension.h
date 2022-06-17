//
//  NSString+Extension.h
//  SmartPen
//
//  Created by HZW on 2018/4/23.
//  Copyright © 2018年 L. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

/**
 动态计算文本size

 @param text 文本内容
 @param font 文字大小
 @param size 最大size
 @return 返回计算后的文本size
 */
+ (CGSize)getAutoCalculateWithSize:(NSString *)text withFont:(UIFont *)font withMaxSize:(CGSize)size;

/**
 动态计算文本高度

 @param text 文内内容
 @param font 文字大小
 @param size 最大size
 @return 返回计算后的高度
 */
+ (CGFloat)getAutoCalculateWithHeight:(NSString *)text withFont:(UIFont *)font withMaxSize:(CGSize)size;

/**
 动态计算文本宽度

 @param text 文本内容
 @param font 文字大小
 @param size 最大size
 @return 返回计算后的文本宽度
 */
+ (CGFloat)getAutoCalculateWithWidth:(NSString *)text withFont:(UIFont *)font withMaxSize:(CGSize)size;

/**
 判断输入的手机号是否正确

 @param phoneNumber 手机号
 @return 判断结果
 */
+ (BOOL)phoneNumberIsTrue:(NSString *)phoneNumber;

/**
 NSData转换成十六进制字符串

 @param data NSData数据
 @return 转换后的十六进制字符串
 */
+ (NSString *)convertDataToHexStr:(NSData *)data;

/**
 字符串转十六进制字符串

 @param string 字符串
 @return 转换后的十六进制字符串
 */
+ (NSString *)hexStringFromString:(NSString *)string;

/**
 十六进制字符串转换成NSData

 @param str 十六进制字符串
 @return 转换后的NSData类型
 */
+ (NSData *)convertHexStrToData:(NSString *)str;

/**
 获取本机ip地址

 @return 返回ip地址
 */
+ (NSString *)getIPAddress;

/**
 获取当前时间

 @return 返回时间
 */
+ (NSString*)getCurrentTimes;

@end
