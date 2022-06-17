//
//  TQLColorView.m
//  Whiteboard
//
//  Created by HZW on 2018/7/9.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLColorView.h"

@interface TQLColorView ()

@property (nonatomic, strong) NSMutableArray *btnArray;

@end

@implementation TQLColorView

- (instancetype)init{
    if (self == [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = CORNRRRADIUS;
        
        CGFloat width = (AUTOSCALE_WIDTH(175) - AUTOSCALE_WIDTH(30) - AUTOSCALE_WIDTH(50)) / 6;
        for (NSInteger i = 0; i < 6; i++) {
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(AUTOSCALE_WIDTH(15) + width * i + AUTOSCALE_WIDTH(10) * i, AUTOSCALE_HEIGHT(10), width, width)];
            NSString *colorStr = [NSString stringWithFormat:@"HandwritingEdit_Color%zd",i + 1];
            [button setImage:IMAGENAME(colorStr) forState:UIControlStateNormal];
            button.layer.cornerRadius = button.height / 2;
            button.tag = 10 * i;
            [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [self.btnArray addObject:button];
        }
        
    }
    return self;
}

- (void)btnClick:(UIButton *)btn{
    
    for (UIButton *button in self.btnArray) {
        if (button.tag == btn.tag) {
            btn.transform = CGAffineTransformMakeScale(1.5, 1.5);
        }else{
            button.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }
    }
    
    UIColor *color;
    switch (btn.tag) {
            case 0:
            color = [UIColor blackColor];
            break;
            
        case 10:
            color = [UIColor colorWithHexString:@"#1e90ff"];
            break;
            
            case 20:
            color = [UIColor colorWithHexString:@"#00ff00"];
            break;
            
            case 30:
            color = [UIColor yellowColor];
            break;
            
            case 40:
            color = [UIColor redColor];
            break;
            
            case 50:
            color = [UIColor purpleColor];
            break;
            
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectColor:)]) {
        [self.delegate selectColor:color];
    }
}

- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

@end
