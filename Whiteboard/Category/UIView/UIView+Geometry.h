//
//  UIView+Geometry.h
//  SmartPen
//
//  Created by L on 2017/9/10.
//  Copyright © 2017年 L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Geometry)

@property (nonatomic) CGFloat width;

@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat originX;

@property (nonatomic) CGFloat originY;

@property (nonatomic) CGFloat centerX;

@property (nonatomic) CGFloat centerY;

@property (nonatomic) CGPoint origin;

@property (nonatomic) CGSize size;

- (void)setCornerRadius;

- (void)removeAllSubviews;

@end
