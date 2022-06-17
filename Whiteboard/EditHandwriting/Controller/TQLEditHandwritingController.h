//
//  TQLEditHandwritingController.h
//  Whiteboard
//
//  Created by HZW on 2018/6/15.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLBaseNavigationController.h"

@interface TQLEditHandwritingController : TQLBaseNavigationController

@property (nonatomic, assign) NSInteger pushType;//0首页 1文档列表
@property (nonatomic, copy) NSString *host;//ip地址
@property (nonatomic, assign) uint16_t port;//端口号
@property (nonatomic, assign) NSInteger pageID;//页码

@end
