//
//  TQLFMDBManager.m
//  Whiteboard
//
//  Created by HZW on 2018/6/27.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLFMDBManager.h"

@interface TQLFMDBManager ()

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) FMDatabase *dataBase;

@end

@implementation TQLFMDBManager

+ (instancetype)shareFMDBManager{
    static TQLFMDBManager *shareFMDBManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareFMDBManager = [TQLFMDBManager new];
    });
    return shareFMDBManager;
}

//建表
- (void)creatTable:(NSString *)tableName{
    // 创建数据库
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.filePath = [document stringByAppendingPathComponent:@"TQLData.sqlite"];
    //使用路径初始化FMDB对象
    self.dataBase = [FMDatabase databaseWithPath:self.filePath];
    //判断数据库是否打开，打开时才执行sql语句
    if ([self.dataBase open]) {
        //创建建表sql语句
        NSString *creatSQL;
        if ([tableName isEqualToString:dotTable]) {
            //白板数据表
            creatSQL = [NSString stringWithFormat:@"create table if not exists %@(%@ integer primary key autoincrement,%@ integer,%@ integer,%@ text,%@ integer,%@ integer,%@ integer,%@ integer,%@ integer)",@"dotTable",@"id",@"pageID",@"handwritingWidth",@"handwritingColor",@"pointX",@"pointY",@"pressure",@"mouseStatus",@"isEraser"];
        }else if ([tableName isEqualToString:localDotTable]){
            //本地手机绘制数据
            creatSQL = [NSString stringWithFormat:@"create table if not exists %@(%@ integer primary key autoincrement,%@ integer,%@ integer,%@ text,%@ integer,%@ integer,%@ integer,%@ integer,%@ integer)",@"localDotTable",@"id",@"pageID",@"handwritingWidth",@"handwritingColor",@"pointX",@"pointY",@"pressure",@"mouseStatus",@"isEraser"];
        }else if ([tableName isEqualToString:screenshotTable]){
            //截图数据表
            creatSQL = [NSString stringWithFormat:@"create table if not exists %@(%@ integer primary key autoincrement,%@ integer,%@ integer,%@ integer,%@ integer,%@ integer,%@ text)",@"screenshotTable",@"id",@"pageID",@"pointX",@"pointY",@"width",@"height",@"dataStr"];
        }else if ([tableName isEqualToString:handwritingList]){
            //笔迹图片
            creatSQL = [NSString stringWithFormat:@"create table if not exists %@(%@ integer primary key autoincrement,%@ inter,%@ text,%@ text,%@ text,%@ inter)",@"handwritingList",@"id",@"pageID",@"imageStr",@"name",@"time",@"isSubmit"];
        }
        BOOL result = [self.dataBase executeUpdate:creatSQL];
        if (result) {
            NSLog(@"建表成功");
        } else {
            NSLog(@"建表失败");
        }
    }
    // 关闭数据库
    [self.dataBase close];
}

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
withHandwritingList:(TQLHandwritingListModel *)handwritingListModel{
    //打开数据库
    [self.dataBase open];
    
    if ([tableName isEqualToString:dotTable]) {
        //白板数据
        NSString *insertSql = @"insert into dotTable(pageID,handwritingWidth, handwritingColor,pointX,pointY,pressure,mouseStatus,isEraser) values (?, ?, ?, ?, ?, ?, ?, ?)";
        BOOL result = [self.dataBase executeUpdate:insertSql, @(dotModel.pageID), @(dotModel.handwritingWidth), dotModel.handwritingColor,@(dotModel.pointX),@(dotModel.pointY),@(dotModel.pressure),@(dotModel.mouseStatus),@(dotModel.isEraser)];
        if (result) {
            NSLog(@"插入白板数据成功");
        } else {
            NSLog(@"插入白板数据失败");
        }
    }else if ([tableName isEqualToString:localDotTable]){
        //本地手机绘制数据
        NSString *insertSql = @"insert into localDotTable(pageID,handwritingWidth, handwritingColor,pointX,pointY,pressure,mouseStatus,isEraser) values (?, ?, ?, ?, ?, ?, ?, ?)";
        BOOL result = [self.dataBase executeUpdate:insertSql, @(dotModel.pageID), @(dotModel.handwritingWidth), dotModel.handwritingColor,@(dotModel.pointX),@(dotModel.pointY),@(dotModel.pressure),@(dotModel.mouseStatus),@(dotModel.isEraser)];
        if (result) {
            NSLog(@"插入本地数据成功");
        } else {
            NSLog(@"插入本地数据失败");
        }
    }else if ([tableName isEqualToString:screenshotTable]){
        //截图数据
        NSString *insertSql = @"insert into screenshotTable(pageID,pointX,pointY,width,height,dataStr) values (?, ?, ?, ?, ?, ?)";
        BOOL result = [self.dataBase executeUpdate:insertSql,@(screenshotModel.pageID),@(screenshotModel.pointX),@(screenshotModel.pointY),@(screenshotModel.width),@(screenshotModel.height),screenshotModel.dataStr];
        if (result) {
            NSLog(@"插入截图成功");
        }else{
            NSLog(@"插入截图失败");
        }
    }else if ([tableName isEqualToString:handwritingList]){
        //笔迹图片
        NSString *insertSql = @"insert into handwritingList(pageID,imageStr,name,time,isSubmit) values (?,?,?,?,?)";
        BOOL result = [self.dataBase executeUpdate:insertSql,@(handwritingListModel.pageID),handwritingListModel.imageStr,handwritingListModel.name,handwritingListModel.time,@(handwritingListModel.isSubmit)];
        if (result) {
            NSLog(@"插入笔迹图片成功");
        }else{
            NSLog(@"插入笔迹图片失败");
        }
    }
    
    // 创建操作队列
//    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:self.filePath];
//    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
//    dispatch_async(q, ^{
//        [queue inDatabase:^(FMDatabase * _Nonnull db) {
//            //创建插入语句
//            if ([tableName isEqualToString:dotTable]) {
//                //白板数据
//                NSString *insertSql = @"insert into dotTable(pageID,handwritingWidth, handwritingColor,pointX,pointY,pressure,mouseStatus) values (?, ?, ?, ?, ?, ?, ?)";
//                BOOL result = [db executeUpdate:insertSql, @(dotModel.pageID), @(dotModel.handwritingWidth), dotModel.handwritingColor,@(dotModel.pointX),@(dotModel.pointY),@(dotModel.pressure),@(dotModel.mouseStatus)];
//                if (result) {
//                    NSLog(@"插入数据成功");
//                } else {
//                    NSLog(@"插入数据失败");
//                }
//            }else if ([tableName isEqualToString:localDotTable]){
//                //本地手机绘制数据
//                NSString *insertSql = @"insert into localDotTable(pageID,handwritingWidth, handwritingColor,pointX,pointY,pressure,mouseStatus) values (?, ?, ?, ?, ?, ?, ?)";
//                BOOL result = [db executeUpdate:insertSql, @(dotModel.pageID), @(dotModel.handwritingWidth), dotModel.handwritingColor,@(dotModel.pointX),@(dotModel.pointY),@(dotModel.pressure),@(dotModel.mouseStatus)];
//                if (result) {
//                    NSLog(@"插入数据成功");
//                } else {
//                    NSLog(@"插入数据失败");
//                }
//            }else if ([tableName isEqualToString:screenshotTable]){
//                //截图数据
//                NSString *insertSql = @"insert into screenshotTable(pageID,pointX,pointY,width,height,dataStr) values (?, ?, ?, ?, ?, ?)";
//                BOOL result = [db executeUpdate:insertSql,@(screenshotModel.pageID),@(screenshotModel.pointX),@(screenshotModel.pointY),@(screenshotModel.width),@(screenshotModel.height),screenshotModel.dataStr];
//                if (result) {
//                    NSLog(@"插入截图成功");
//                }else{
//                    NSLog(@"插入截图失败");
//                }
//            }
//        }];
//    });
    //关闭数据库
    [self.dataBase close];
    
}

/**
 删
 
 @param model 删除条件
 @param tableName 表名
 */
- (void)FMDBDelete:(TQLDotModel *)model
     withTableName:(NSString *)tableName{
    //打开数据库
    [self.dataBase open];
    //删除语句
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@ where pointX = %zd and pointY = %zd",tableName,model.pointX,model.pointY];
    BOOL result = [self.dataBase executeUpdate:sqlStr];
    if (result) {
        NSLog(@"删除成功");
    } else {
        NSLog(@"删除失败");
    }
    //关闭数据库
    [self.dataBase close];
}

/**
 删除全部
 
 @param tableName 表名
 */
- (void)FMDBDeleteAll:(NSString *)tableName{
    //打开数据库
    [self.dataBase open];
    //删除语句
    NSString *sqlStr = [NSString stringWithFormat:@"delete from %@",tableName];
    BOOL result = [self.dataBase executeUpdate:sqlStr];
    if (result) {
        NSLog(@"删除成功");
    } else {
        NSLog(@"删除失败");
    }
    //关闭数据库
    [self.dataBase close];
}

/**
 改
 
 @param model 数据模型
 */
- (void)FMDBUpdate:(TQLDotModel *)model{
    //打开数据库
    [self.dataBase open];
    //更新语句
    BOOL result = [self.dataBase executeUpdate:@"update dotTbale set pointX = ? where pointX = ?", @(123), @(model.pointX)];
    if (result) {
        NSLog(@"更新成功");
    } else {
        NSLog(@"更新失败");
    }
    //关闭数据库
    [self.dataBase close];
}

/**
 查询单个数据
 
 @param model 查询条件
 @param tableName 表名
 @return 查询结果
 */
- (TQLDotModel *)FMDBSearchSingle:(TQLDotModel *)model withTableName:(NSString *)tableName{
    //打开数据库
    [self.dataBase open];
    //接收查询结果的类
    FMResultSet *resultSet = [self.dataBase executeQuery:@"select * from %@ where pointX = ?",tableName,@(model.pointX)];
    TQLDotModel *resultModel = [[TQLDotModel alloc] init];
    if (resultSet) {
        // 遍历出需要的结果内容
        while ([resultSet next]) {
            resultModel.pageID = [resultSet intForColumn:@"pageID"];
            resultModel.handwritingWidth = [resultSet intForColumn:@"handwritingWidth"];
            resultModel.handwritingColor = [resultSet stringForColumn:@"handwritingColor"];
            resultModel.pointX = [resultSet intForColumn:@"pointX"];
            resultModel.pointY = [resultSet intForColumn:@"pointY"];
            resultModel.pressure = [resultSet intForColumn:@"pressure"];
            resultModel.mouseStatus = [resultSet intForColumn:@"mouseStatus"];
            resultModel.isEraser = [resultSet intForColumn:@"isEraser"];
        }
    } else {
        NSLog(@"查询失败");
    }
    //关闭数据库
    [self.dataBase close];
    
    return resultModel;
}

/**
 查询所有数据
 
 @param tableName 表名
 @return 查询结果
 */
- (NSArray *)FMDBSearchAll:(NSString *)tableName{
    //打开数据库
    [self.dataBase open];
    //接收查询结果的类
    FMResultSet *resultSet = [self.dataBase executeQuery:[NSString stringWithFormat:@"select * from %@",tableName]];
    NSMutableArray *resultArray = [NSMutableArray array];
    if (resultSet) {
        // 遍历出需要的结果内容
        if ([tableName isEqualToString:dotTable] || [tableName isEqualToString:localDotTable]) {
            //白板数据或是本地手机数据
            while ([resultSet next]) {
                TQLDotModel *resultModel = [[TQLDotModel alloc] init];
                resultModel.pageID = [resultSet intForColumn:@"pageID"];
                resultModel.handwritingWidth = [resultSet intForColumn:@"handwritingWidth"];
                resultModel.handwritingColor = [resultSet stringForColumn:@"handwritingColor"];
                resultModel.pointX = [resultSet intForColumn:@"pointX"];
                resultModel.pointY = [resultSet intForColumn:@"pointY"];
                resultModel.pressure = [resultSet intForColumn:@"pressure"];
                resultModel.mouseStatus = [resultSet intForColumn:@"mouseStatus"];
                resultModel.isEraser = [resultSet intForColumn:@"isEraser"];
                [resultArray addObject:resultModel];
            }
        }else if ([tableName isEqualToString:screenshotTable]){
            //截图数据
            while ([resultSet next]) {
                TQLScreenshotModel *model = [[TQLScreenshotModel alloc] init];
                model.pageID = [resultSet intForColumn:@"pageID"];
                model.pointX = [resultSet intForColumn:@"pointX"];
                model.pointY = [resultSet intForColumn:@"pointY"];
                model.width = [resultSet intForColumn:@"width"];
                model.height = [resultSet intForColumn:@"height"];
                model.dataStr = [resultSet stringForColumn:@"dataStr"];
                [resultArray addObject:model];
            }
        }else if ([tableName isEqualToString:handwritingList]){
            //笔迹图片
            while ([resultSet next]) {
                TQLHandwritingListModel *model = [[TQLHandwritingListModel alloc] init];
                model.pageID = [resultSet intForColumn:@"pageID"];
                model.imageStr = [resultSet stringForColumn:@"imageStr"];
                model.name = [resultSet stringForColumn:@"name"];
                model.time = [resultSet stringForColumn:@"time"];
                model.isSubmit = [resultSet intForColumn:@"isSubmit"];
                [resultArray addObject:model];
            }
        }
    }else {
        NSLog(@"查询失败");
    }
    //关闭数据库
    [self.dataBase close];
    
    return resultArray;
}

/**
 删表
 
 @param tableName 表名
 */
- (void)FMDBDeleteTable:(NSString *)tableName{
    //打开数据库
    [self.dataBase open];
    BOOL result = [self.dataBase executeUpdate:[NSString stringWithFormat:@"drop table if exists %@;",tableName]];
    if (result) {
        NSLog(@"删除表成功");
    }else{
        NSLog(@"删除表失败");
    }
    [self.dataBase close];
}

@end
