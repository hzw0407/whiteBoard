//
//  TQLSettingCell.m
//  Whiteboard
//
//  Created by HZW on 2018/6/13.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLSettingCell.h"

@interface TQLSettingCell (){
    UIImageView *imageView;//连接图片
    UILabel *nameLabel;//白板名称
    UILabel *macAddressLabel;//白板mac地址
}

@end

@implementation TQLSettingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        
        nameLabel = [[UILabel alloc] init];
        nameLabel.text = @"Metting Kaap";
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:nameLabel];
        
        macAddressLabel = [[UILabel alloc] init];
        macAddressLabel.textColor = [UIColor textColor];
        macAddressLabel.font = [UIFont systemFontOfSize:11];
        [self addSubview:macAddressLabel];
        
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(AUTOSCALE_WIDTH(32));
        make.top.equalTo(self).offset(AUTOSCALE_HEIGHT(12.5));
        make.width.equalTo(@(AUTOSCALE_WIDTH(18.5)));
        make.height.equalTo(@(AUTOSCALE_WIDTH(18.5)));
    }];
    
    CGFloat nameWidth = [NSString getAutoCalculateWithWidth:nameLabel.text withFont:[UIFont systemFontOfSize:15] withMaxSize:CGSizeMake(1000, AUTOSCALE_HEIGHT(20))];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->imageView.mas_right).offset(AUTOSCALE_WIDTH(20));
        make.top.mas_equalTo(self->imageView.mas_top);
        make.width.equalTo(@(nameWidth));
        make.height.mas_equalTo(self->imageView.mas_height);
    }];
    
    [macAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self->nameLabel.mas_right).offset(AUTOSCALE_WIDTH(10));
        make.top.mas_equalTo(self->nameLabel.mas_top).offset(AUTOSCALE_HEIGHT(2));
        make.height.mas_equalTo(self->nameLabel.mas_height);
    }];
    
}

- (void)refreshWithModel:(TQLSettingModel *)model{
    imageView.image = IMAGENAME(@"Setting_Name");
    macAddressLabel.text = model.macAddress;
    CGFloat addressWidth = [NSString getAutoCalculateWithWidth:macAddressLabel.text withFont:[UIFont systemFontOfSize:11] withMaxSize:CGSizeMake(1000, AUTOSCALE_HEIGHT(20))];
    [macAddressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(addressWidth));
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
