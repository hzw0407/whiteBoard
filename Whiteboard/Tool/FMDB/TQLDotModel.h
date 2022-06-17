//
//  TQLDotModel.h
//  Whiteboard
//
//  Created by HZW on 2018/6/28.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TQLScreenshotModel.h"

@interface TQLDotModel : NSObject

/**
 页面id
 */
@property (nonatomic, assign) NSInteger pageID;

/**
 笔迹宽度
 */
@property (nonatomic, assign) NSInteger handwritingWidth;

/**
 笔迹颜色
 */
@property (nonatomic, copy) NSString *handwritingColor;

/**
 x坐标
 */
@property (nonatomic, assign) NSInteger pointX;

/**
 y坐标
 */
@property (nonatomic, assign) NSInteger pointY;

/**
 压力值
 */
@property (nonatomic, assign) NSInteger pressure;

/**
 鼠标状态 1down 2move 3up
 */
@property (nonatomic, assign) NSInteger mouseStatus;

/**
 是否橡皮擦状态
 */
@property (nonatomic, assign) BOOL isEraser;

@end
