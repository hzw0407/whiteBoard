//
//  TQLHandwritingListModel.h
//  Whiteboard
//
//  Created by HZW on 2018/6/13.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TQLHandwritingListModel : NSObject

/**
 页码
 */
@property (nonatomic, assign) NSInteger pageID;

/**
 图片
 */
@property (nonatomic, copy) NSString *imageStr;

/**
 笔迹名称
 */
@property (nonatomic, copy) NSString *name;

/**
 时间
 */
@property (nonatomic, copy) NSString *time;

/**
 是否提交过
 */
@property (nonatomic, assign) BOOL isSubmit;

@end
