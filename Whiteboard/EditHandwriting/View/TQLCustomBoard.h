//
//  TQLCustomBoard.h
//  Whiteboard
//
//  Created by HZW on 2018/6/20.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TQLCustomBoard : UIImageView

@property (nonatomic,copy) UIColor *lineColor;//画笔颜色

@property (nonatomic, assign) CGFloat lineWidth;//画笔粗细

@property (nonatomic, assign) NSInteger pageID;//页面id

@property (nonatomic, assign) BOOL isEraser;//是否橡皮擦模式

/**
 开始绘制

 @param point 开始坐标点
 */
//- (void)drawBeganPoint:(CGPoint)point;

/**
 添加数据点

 @param middlePoint 中间坐标点
 @param endPoint 结束坐标点
 */
//- (void)drawControlPoint:(CGPoint)middlePoint
//            withEndPoint:(CGPoint)endPoint;


/**
 创建图形上下文
 */
- (void)creatImageContex;

/**
 绘制完成生成图片
 */
- (void)creatImage;

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
         withIsHand:(BOOL)isFinger;

/**
 撤销
 */
- (void)revoke;

/**
 还原
 */
- (void)reduction;

/**
 橡皮擦
 */
- (void)eraser;

/**
 确认擦除
 */
- (void)deleteEraserData;

/**
 删除
 */
- (void)deleteData;

/**
 保存笔迹图片

 @param isSubmit 是否提交过数据
 */
- (void)saveImage:(BOOL)isSubmit;

/**
 获取笔迹图片图片

 @return 返回图片
 */
-(UIImage *)getImageFromView;

@end
