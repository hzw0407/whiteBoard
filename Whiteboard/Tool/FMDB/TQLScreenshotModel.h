//
//  TQLScreenshotModel.h
//  Whiteboard
//
//  Created by HZW on 2018/7/5.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TQLScreenshotModel : NSObject

/**
 页面id
 */
@property (nonatomic, assign) NSInteger pageID;

/**
 截图起始x坐标
 */
@property (nonatomic, assign) NSInteger pointX;

/**
 截图起始y坐标
 */
@property (nonatomic, assign) NSInteger pointY;

/**
 截图高度
 */
@property (nonatomic, assign) NSInteger width;

/**
 高度
 */
@property (nonatomic, assign) NSInteger height;

/**
 截图数据转换成str存储
 */
@property (nonatomic, copy) NSString *dataStr;

@end
