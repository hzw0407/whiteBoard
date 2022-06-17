//
//  TQLSettingModel.h
//  Whiteboard
//
//  Created by HZW on 2018/6/13.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TQLSettingModel : NSObject

/**
 白板mac地址
 */
@property (nonatomic, copy) NSString *macAddress;

/**
 连接状态
 */
@property (nonatomic, assign) NSInteger connectStatus;

@end
