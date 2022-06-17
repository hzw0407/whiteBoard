//
//  NSString+Extension.m
//  SmartPen
//
//  Created by HZW on 2018/4/23.
//  Copyright © 2018年 L. All rights reserved.
//

#import "NSString+Extension.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation NSString (Extension)

/**
 动态计算文本高度
 
 @param text 文内内容
 @param font 文字大小
 @param size 最大size
 @return 返回计算后的高度
 */
+ (CGFloat)getAutoCalculateWithHeight:(NSString *)text withFont:(UIFont *)font withMaxSize:(CGSize)size{
    return [self getAutoCalculateWithSize:text withFont:font withMaxSize:size].height;
}

/**
 动态计算文本宽度
 
 @param text 文本内容
 @param font 文字大小
 @param size 最大size
 @return 返回计算后的文本宽度
 */
+ (CGFloat)getAutoCalculateWithWidth:(NSString *)text withFont:(UIFont *)font withMaxSize:(CGSize)size{
    return [self getAutoCalculateWithSize:text withFont:font withMaxSize:size].width;
}

/**
 动态计算文本size
 
 @param text 文本内容
 @param font 文字大小
 @param size 最大size
 @return 返回计算后的文本size
 */
+ (CGSize)getAutoCalculateWithSize:(NSString *)text withFont:(UIFont *)font withMaxSize:(CGSize)size{
    NSMutableParagraphStyle *paragphStyle = [[NSMutableParagraphStyle alloc] init];
    paragphStyle.lineSpacing = 0;
    //设置行距为0
    paragphStyle.firstLineHeadIndent = 0.0;
    paragphStyle.hyphenationFactor = 0.0;
    paragphStyle.paragraphSpacingBefore = 0.0;
    NSDictionary *dic = @{
                          NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:paragphStyle,
                          NSKernAttributeName:@1.0f
                          };
    CGSize maxSize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    return maxSize;
}

/**
 判断输入的手机号是否正确
 
 @param phoneNumber 手机号
 @return 判断结果
 */
+ (BOOL)phoneNumberIsTrue:(NSString *)phoneNumber{
    
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0-9])|(14[57])|(17[013678]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:phoneNumber];
    
}

/**
 NSData转换成十六进制字符串
 
 @param data NSData数据
 @return 转换后的十六进制字符串
 */
+ (NSString *)convertDataToHexStr:(NSData *)data{
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

/**
 字符串转十六进制字符串
 
 @param string 字符串
 @return 转换后的十六进制字符串
 */
+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myData = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myData bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr = @"";
    for(int i = 0; i < [myData length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];
        ///16进制数
        if([newHexStr length] == 1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

/**
 十六进制字符串转换成NSData
 
 @param str 十六进制字符串
 @return 转换后的NSData类型
 */
+ (NSData *)convertHexStrToData:(NSString *)str{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}

/**
 获取本地ip地址

 @return 返回ip
 */
+ (NSString *)getIPAddress{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // 检索当前接口,在成功时,返回0
    success = getifaddrs(&interfaces); if (success == 0) {
        // 循环链表的接口
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // 检查接口是否en0 wifi连接在iPhone上
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // 得到NSString从C字符串
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // 释放内存
    freeifaddrs(interfaces);
    return address;
}

/**
 获取当前时间
 
 @return 返回时间
 */
+ (NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"YYYY-MM-dd"];
    
    NSDate *datenow = [NSDate date];
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
    
}

@end
