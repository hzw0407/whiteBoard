//
//  TQLLineWidthView.h
//  Whiteboard
//
//  Created by HZW on 2018/7/10.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TQLLineWidthViewDelegate <NSObject>

//选中字体粗细
- (void)selectWidth:(CGFloat)width;

@end

@interface TQLLineWidthView : UIView

@property (nonatomic, assign) id<TQLLineWidthViewDelegate>delegate;

@end
