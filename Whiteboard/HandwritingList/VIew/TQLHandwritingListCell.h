//
//  TQLHandwritingListCell.h
//  Whiteboard
//
//  Created by HZW on 2018/7/7.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQLHandwritingListModel.h"

@protocol TQLHandwritingListCellDelegate <NSObject>

//点击某个cell编辑
//- (void)clickEdit:(NSInteger)index;

@end

@interface TQLHandwritingListCell : UICollectionViewCell

- (void)refreshWithModel:(TQLHandwritingListModel *)model withIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) id<TQLHandwritingListCellDelegate>delegate;

@end
