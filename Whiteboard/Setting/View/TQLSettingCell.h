//
//  TQLSettingCell.h
//  Whiteboard
//
//  Created by HZW on 2018/6/13.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQLSettingModel.h"

@interface TQLSettingCell : UITableViewCell

- (void)refreshWithModel:(TQLSettingModel *)model;

@end
