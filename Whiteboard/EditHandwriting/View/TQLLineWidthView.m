//
//  TQLLineWidthView.m
//  Whiteboard
//
//  Created by HZW on 2018/7/10.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLLineWidthView.h"

@interface TQLLineWidthView ()

@property (nonatomic, strong) NSMutableArray *btnArray;

@end;

@implementation TQLLineWidthView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        NSArray *fontArray = @[@"细",@"正常",@"小粗",@"粗",@"特粗"];
        for (NSInteger i = 0; i < fontArray.count; i++) {
            //竖线
            UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(AUTOSCALE_WIDTH(15) + AUTOSCALE_WIDTH(1) * i + AUTOSCALE_WIDTH(38) * i, AUTOSCALE_HEIGHT(10), AUTOSCALE_WIDTH(1), AUTOSCALE_HEIGHT(5))];
            verticalLineView.backgroundColor = [UIColor grayColor];
            verticalLineView.tag = 300 + i;
            [self addSubview:verticalLineView];
            
            //横线
            if (i != fontArray.count - 1) {
                UIView *horizontalLineView = [[UIView alloc] initWithFrame:CGRectMake(verticalLineView.originX, verticalLineView.originY + verticalLineView.height, AUTOSCALE_WIDTH(40), AUTOSCALE_HEIGHT(1))];
                horizontalLineView.backgroundColor = [UIColor grayColor];
                [self addSubview:horizontalLineView];
            }
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(verticalLineView.originX - AUTOSCALE_WIDTH(15), verticalLineView.originY + verticalLineView.height + AUTOSCALE_HEIGHT(5), AUTOSCALE_WIDTH(30), AUTOSCALE_HEIGHT(30))];
//            button.backgroundColor = [UIColor redColor];
            [button setTitle:fontArray[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHexString:@"#7b7b7b"] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithHexString:@"#4e78ff"] forState:UIControlStateSelected];
            button.titleLabel.font = [UIFont systemFontOfSize:9];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            button.tag = 100 + i;
            [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            [self.btnArray addObject:button];
            
            //小圆点
            if (i == 1) {
                //默认选中正常字体
                button.selected = YES;
                UIImageView *circleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(verticalLineView.originX - AUTOSCALE_WIDTH(1), verticalLineView.originY + verticalLineView.height - AUTOSCALE_HEIGHT(1), AUTOSCALE_WIDTH(4.5), AUTOSCALE_WIDTH(4.5))];
                circleImageView.image = IMAGENAME(@"HandwritingEdit_Circle");
                circleImageView.tag = 200;
                [self addSubview:circleImageView];
            }
        }
        
    }
    return self;
}

- (void)btnClick:(UIButton *)btn{
    
    for (UIButton *tempBtn in self.btnArray) {
        if (btn.tag == tempBtn.tag) {
            btn.selected = YES;
        }else{
            tempBtn.selected = NO;
        }
    }
    CGFloat width = 0.0;
    
    switch (btn.tag - 100) {
        case 0:
            width = 1;
            break;
            
            case 1:
            width = 2;
            break;
            
            case 2:
            width = 3;
            break;
            
            case 3:
            width = 5;
            break;
            
            case 4:
            width = 10;
            break;
            
        default:
            break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectWidth:)]) {
        [self.delegate selectWidth:width];
    }
    
    UIView *verticalLineView = (UIView *)[self viewWithTag:btn.tag + 200];
    UIImageView *circleImageView = (UIImageView *)[self viewWithTag:200];
    circleImageView.originX = verticalLineView.originX - AUTOSCALE_WIDTH(1);
    
}

- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

@end
