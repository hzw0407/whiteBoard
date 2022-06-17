//
//  TQLCustomBoard.m
//  Whiteboard
//
//  Created by HZW on 2018/6/20.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLCustomBoard.h"
#import <QuartzCore/QuartzCore.h>
#import "TQLDotModel.h"
#import "TQLFMDBManager.h"

@interface TQLCustomBoard ()
//@property (nonatomic, strong) NSMutableArray * pointArray;//所有点的数组
//@property (nonatomic, strong) NSMutableArray *revokeLayerArray;//被撤销的layer数组
@property (nonatomic, strong) TQLFMDBManager *FMDBManager;//数据库
@property (nonatomic, strong) NSMutableArray *eraserArray;//橡皮擦删除的数据数组
@property (nonatomic, strong) NSMutableArray *tempArray;//橡皮擦擦除的点数据


@end


@implementation TQLCustomBoard

#pragma mark - lifecycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
    self.userInteractionEnabled = YES;
    self.isEraser = NO;
    
    self.FMDBManager = [TQLFMDBManager shareFMDBManager];
    
}

#pragma mark - CustomMethod
//开始触摸
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint beganPoint = [touch locationInView:self];
    
    TQLDotModel *model = [[TQLDotModel alloc] init];
    model.pageID = self.pageID;
    model.handwritingWidth = self.lineWidth;
    if (self.isEraser) {
        model.handwritingColor = @"00FFFFFF";
    }else{
        if (CGColorEqualToColor(self.lineColor.CGColor, [UIColor blackColor].CGColor)) {
            //黑色用下面的方面转会有问题 所以单独存
            model.handwritingColor = @"000000";
        }else{
            model.handwritingColor = [UIColor hexStringFromColor:self.lineColor];
        }
    }
    model.pointX = (NSInteger)beganPoint.x;
    model.pointY = (NSInteger)beganPoint.y;
    model.pressure = 1023;
    model.mouseStatus = 1;
    model.isEraser = self.isEraser;
    
    if (self.isEraser) {
        //橡皮擦擦除的数据
        self.tempArray = [NSMutableArray array];
        [self.tempArray addObject:model];
    }else{
        //需要保存的数据
        [self.FMDBManager FMDBInsert:localDotTable withDotModel:model withScreenshot:nil withHandwritingList:nil];
    }
    
}

//移动手指
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    
    CGPoint previousPoint = [touch previousLocationInView:self];
    
    TQLDotModel *model = [[TQLDotModel alloc] init];
    model.pageID = self.pageID;
    model.handwritingWidth = self.lineWidth;
    if (self.isEraser) {
        model.handwritingColor = @"00FFFFFF";
    }else{
        if (CGColorEqualToColor(self.lineColor.CGColor, [UIColor blackColor].CGColor)) {
            //黑色用下面的方面转会有问题 所以单独存
            model.handwritingColor = @"000000";
        }else{
            model.handwritingColor = [UIColor hexStringFromColor:self.lineColor];
        }
    }
    model.pointX = (NSInteger)currentPoint.x;
    model.pointY = (NSInteger)currentPoint.y;
    model.pressure = 1023;
    model.mouseStatus = 2;
    model.isEraser = self.isEraser;
    
    [self drawEachDot:self.lineColor withLineWidth:self.lineWidth withIsEarser:self.isEraser withCurrentPoint:currentPoint withPreviousPoint:previousPoint withIsHand:YES];
    
    if (self.isEraser) {
        //橡皮擦擦除的数据
        [self.tempArray addObject:model];
    }else{
        //需要保存的数据
        [self.FMDBManager FMDBInsert:localDotTable withDotModel:model withScreenshot:nil withHandwritingList:nil];
    }
    
}

//结束触摸
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    
    TQLDotModel *model = [[TQLDotModel alloc] init];
    model.pageID = self.pageID;
    model.handwritingWidth = self.lineWidth;
    if (self.isEraser) {
        model.handwritingColor = @"00FFFFFF";
    }else{
        if (CGColorEqualToColor(self.lineColor.CGColor, [UIColor blackColor].CGColor)) {
            //黑色用下面的方面转会有问题 所以单独存
            model.handwritingColor = @"000000";
        }else{
            model.handwritingColor = [UIColor hexStringFromColor:self.lineColor];
        }
    }
    model.pointX = (NSInteger)currentPoint.x;
    model.pointY = (NSInteger)currentPoint.y;
    model.pressure = 1023;
    model.mouseStatus = 3;
    model.isEraser = self.isEraser;
    
    if (self.isEraser) {
        //橡皮擦擦除的数据
        [self.tempArray addObject:model];
        [self.eraserArray addObject:self.tempArray];
    }else{
        //需要保存的数据
        [self.FMDBManager FMDBInsert:localDotTable withDotModel:model withScreenshot:nil withHandwritingList:nil];
    }
    
}

/**
 创建图形上下文
 */
- (void)creatImageContex{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
    [self.image drawAtPoint:CGPointZero];
}

/**
 绘制完成生成图片
 */
- (void)creatImage{
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

/**
 绘制每个点
 
 @param color 笔迹颜色
 @param lineWidth 笔迹宽度
 @param isEarser 是否橡皮擦
 @param currentPoint 当前点
 @param previousPoint 上一个点
 @param isFinger 是否是手指触摸屏幕绘制
 */
- (void)drawEachDot:(UIColor *)color
      withLineWidth:(CGFloat)lineWidth
       withIsEarser:(BOOL)isEarser
   withCurrentPoint:(CGPoint)currentPoint
  withPreviousPoint:(CGPoint)previousPoint
         withIsHand:(BOOL)isFinger{
    
    if (isFinger) {
        //手指触摸绘制
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0.0);
        [self.image drawAtPoint:CGPointZero];
    }
   
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, lineWidth);
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    
    CGContextSetLineCap(context, kCGLineCapRound);
    
    if(isEarser){
        //橡皮擦
        CGContextSetBlendMode(context, kCGBlendModeClear);
    }
    
    CGContextMoveToPoint(context, previousPoint.x, previousPoint.y);
    
    CGContextAddQuadCurveToPoint(context, previousPoint.x, previousPoint.y, currentPoint.x, currentPoint.y);
    
    CGContextStrokePath(context);
    
    
    if (isFinger) {
        //手指触摸绘制
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
}

// 计算中间点
CGPoint midPoint(CGPoint p1, CGPoint p2){
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

//保存笔迹图片
- (void)saveImage:(BOOL)isSubmit{
    
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *imageStr = [NSString convertDataToHexStr:imageData];
    TQLHandwritingListModel *model = [[TQLHandwritingListModel alloc] init];
    model.pageID = self.pageID;
    model.imageStr = imageStr;
    model.name = @"会议笔迹";
    model.time = [NSString getCurrentTimes];
    model.isSubmit = isSubmit;
    [self.FMDBManager FMDBInsert:handwritingList withDotModel:nil withScreenshot:nil withHandwritingList:model];
}

//将UIView转成UIImage
- (UIImage *)getImageFromView{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//撤销
- (void)revoke{
    //只针对橡皮擦数据进行撤销
    if (self.eraserArray.count > 0) {
        self.image = nil;
        [self.eraserArray removeObjectAtIndex:self.eraserArray.count - 1];
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self.FMDBManager FMDBSearchAll:localDotTable]];
        for (NSArray *array in self.eraserArray) {
            for (TQLDotModel *model in array) {
                [tempArray addObject:model];
            }
        }
        
        //白板数据也要重绘
        NSArray *dotArray = [self.FMDBManager FMDBSearchAll:dotTable];
        [tempArray addObjectsFromArray:dotArray];
        NSArray *screenArray = [self.FMDBManager FMDBSearchAll:screenshotTable];
        [tempArray addObjectsFromArray:screenArray];
        
        CGPoint previousPoint = CGPointZero;
        NSInteger index = 0;
        //是否是up点和down点的连续点
        BOOL isDowmUp = NO;
        
        for (TQLDotModel *model in tempArray) {
            
            TQLDotModel *currentModel = tempArray[index];
            if (index < tempArray.count - 1) {
                TQLDotModel *nextModel = tempArray[index + 1];
                if (currentModel.mouseStatus == 3 && nextModel.mouseStatus == 1) {
                    isDowmUp = YES;
                }
            }
            
            if (model.mouseStatus == 1) {
                previousPoint = CGPointMake(model.pointX, model.pointY);
            }
            
            //当前点
            CGPoint currentPoint = CGPointMake(model.pointX, model.pointY);
            if (index == 0) {
                //第一个点创建图形上下文
                [self creatImageContex];
            }else if (index == tempArray.count - 1){
                //最后一个点绘制完成生成图片
                [self creatImage];
            }else{
                if (!isDowmUp) {
                    //不是up点和down点连续的点
                    [self drawEachDot:[UIColor colorWithHexString:model.handwritingColor] withLineWidth:model.handwritingWidth withIsEarser:model.isEraser withCurrentPoint:currentPoint withPreviousPoint:previousPoint withIsHand:NO];
                }
            }
            previousPoint = currentPoint;
            isDowmUp = NO;
            
            index ++;
        }
    }
}

//还原
- (void)reduction{

}

//橡皮擦
- (void)eraser{
    self.lineWidth = 5.0f;
    self.isEraser = YES;
}

/**
 确认擦除
 */
- (void)deleteEraserData{
    for (NSArray *array in self.eraserArray) {
        for (TQLDotModel *model in array) {
            [self.FMDBManager FMDBInsert:localDotTable withDotModel:model withScreenshot:nil withHandwritingList:nil];
        }
    }
}

//删除
- (void)deleteData{
    self.image = nil;
    [self.FMDBManager FMDBDeleteAll:localDotTable];
    [self.FMDBManager FMDBDeleteAll:dotTable];
    [self.FMDBManager FMDBDeleteAll:screenshotTable];
}

#pragma mark - ClickMethod

#pragma mark - SystemDelegate

#pragma mark - CustomDelegate

#pragma mark - GetterAndSetter
//- (NSMutableArray *)pointArray{
//    if (!_pointArray) {
//        _pointArray = [NSMutableArray array];
//    }
//    return _pointArray;
//}

- (NSMutableArray *)eraserArray{
    if (!_eraserArray) {
        _eraserArray = [NSMutableArray array];
    }
    return _eraserArray;
}

@end
