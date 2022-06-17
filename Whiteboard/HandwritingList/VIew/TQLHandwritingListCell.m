//
//  TQLHandwritingListCell.m
//  Whiteboard
//
//  Created by HZW on 2018/7/7.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLHandwritingListCell.h"

@interface TQLHandwritingListCell (){
    UIView *baseView;//父视图
    UIImageView *imageView;//图片
    UILabel *nameLabel;//笔迹名称
    UILabel *timeLabel;//时间
    UIImageView *isSubmitImageView;//是否提交过
}

@end;

@implementation TQLHandwritingListCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        baseView = [[UIView alloc] init];
        baseView.backgroundColor = RGB_COLOR(58, 148, 255);
        baseView.layer.cornerRadius = CORNRRRADIUS;
        baseView.clipsToBounds = YES;
        [self addSubview:baseView];
        
        imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor redColor];
        [baseView addSubview:imageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont systemFontOfSize:12];
        [baseView addSubview:nameLabel];
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont systemFontOfSize:10];
        [baseView addSubview:timeLabel];
        
        isSubmitImageView = [[UIImageView alloc] init];
//        [isSubmitImageView addTarget:self action:@selector(editClick:) forControlEvents:UIControlEventTouchUpInside];
        [baseView addSubview:isSubmitImageView];
    }
    return self;
}

- (void)layoutSubviews{
    //调用此方法线才会显示
    [super layoutSubviews];
    
    [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self).offset(0);
        make.top.bottom.equalTo(self).offset(0);
    }];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->baseView).offset(0);
        make.right.equalTo(self->baseView).offset(0);
        make.top.equalTo(self->baseView).offset(0);
        make.bottom.equalTo(self->baseView).offset(-AUTOSCALE_HEIGHT(35));
        make.height.equalTo(@(AUTOSCALE_HEIGHT(210)));
    }];
    
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->baseView).offset(AUTOSCALE_WIDTH(10));
        make.top.mas_equalTo(self->imageView.mas_bottom);
//        make.width.equalTo(0);
        make.height.equalTo(@(AUTOSCALE_HEIGHT(35)));
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(0);
        make.top.mas_equalTo(self->nameLabel.mas_top);
//        make.width.equalTo(0);
        make.height.mas_equalTo(self->nameLabel.mas_height);
    }];
    
    [isSubmitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-AUTOSCALE_WIDTH(10));
        make.top.mas_equalTo(self->imageView.mas_bottom).offset(AUTOSCALE_HEIGHT(12.5));
        make.width.equalTo(@(AUTOSCALE_WIDTH(10)));
        make.height.equalTo(@(AUTOSCALE_HEIGHT(10)));
    }];
}

- (void)refreshWithModel:(TQLHandwritingListModel *)model withIndexPath:(NSIndexPath *)indexPath{
    NSData *data = [NSString convertHexStrToData:model.imageStr];
    imageView.image = [UIImage imageWithData:data];
    nameLabel.text = model.name;
    CGFloat nameLabelWidth = [NSString getAutoCalculateWithWidth:nameLabel.text withFont:[UIFont systemFontOfSize:12] withMaxSize:CGSizeMake(1000, nameLabel.height)];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(nameLabelWidth));
    }];
    timeLabel.text = model.time;
    CGFloat timeLabelWidth = [NSString getAutoCalculateWithWidth:timeLabel.text withFont:[UIFont systemFontOfSize:10] withMaxSize:CGSizeMake(1000, timeLabel.height)];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->nameLabel.mas_right).offset(AUTOSCALE_WIDTH(10));
        make.width.equalTo(@(timeLabelWidth));
    }];
    if (model.isSubmit) {
        isSubmitImageView.image = IMAGENAME(@"handwritingList_submit");
    }
//    [editButton setImage:IMAGENAME(@"handwritingList_edit") forState:UIControlStateNormal];
//    editButton.tag = indexPath.row;
}

//分享
//- (void)editClick:(UIButton *)btn{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(clickEdit:)]) {
//        [self.delegate clickEdit:btn.tag];
//    }
//}

@end
