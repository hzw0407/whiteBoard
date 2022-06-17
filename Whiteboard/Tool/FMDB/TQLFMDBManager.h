//
//  TQLFMDBManager.h
//  Whiteboard
//
//  Created by HZW on 2018/6/27.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TQLDotModel.h"
#import "TQLHandwritingListModel.h"

@interface TQLFMDBManager : NSObject

/**
 单例

 @return 实例对象
 */
+ (instancetype)shareFMDBManager;

/**
 建表

 @param tableName 表名
 */
- (void)creatTable:(NSString *)tableName;

/**
 增

 @param tableName 表名
 @param dotModel 笔迹数据模型
 @param screenshotModel 截图数据模型
 @param handwritingListModel 笔迹图片模型
 */
- (void)FMDBInsert:(NSString *)tableName
      withDotModel:(TQLDotModel *)dotModel
    withScreenshot:(TQLScreenshotModel *)screenshotModel
withHandwritingList:(TQLHandwritingListModel *)handwritingListModel;

/**
 删

 @param model 删除条件
 @param tableName 表名
 */
- (void)FMDBDelete:(TQLDotModel *)model
     withTableName:(NSString *)tableName;

/**
 删除全部

 @param tableName 表名
 */
- (void)FMDBDeleteAll:(NSString *)tableName;

/**
 改

 @param model 更新条件
 */
- (void)FMDBUpdate:(TQLDotModel *)model;

/**
 查询单个数据

 @param model 查询条件
 @param tableName 表名
 @return 查询结果
 */
- (TQLDotModel *)FMDBSearchSingle:(TQLDotModel *)model withTableName:(NSString *)tableName;

/**
 查询所有数据

 @param tableName 表名
 @return 查询结果
 */
- (NSArray *)FMDBSearchAll:(NSString *)tableName;

/**
 删表

 @param tableName 表名
 */
- (void)FMDBDeleteTable:(NSString *)tableName;

@end
