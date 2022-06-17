//
//  TQLColorView.h
//  Whiteboard
//
//  Created by HZW on 2018/7/9.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TQLColorViewDelegate <NSObject>

//选中的颜色
- (void)selectColor:(UIColor *)color;

@end

@interface TQLColorView : UIView

@property (nonatomic, assign) id<TQLColorViewDelegate>delegate;

@end
