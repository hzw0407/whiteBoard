//
//  TQLScoketConnect.h
//  Whiteboard
//
//  Created by HZW on 2018/6/22.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TQLScoketConnectDelegate <NSObject>

//消息发送成功
- (void)sendDataSuccess;

//消息发送失败
- (void)sendDataFailure:(NSError *)error;

//接收消息
- (void)receiveData:(NSData *)data;

//连接已关闭
- (void)connectClose;

@end

@interface TQLScoketConnect : NSObject

@property (nonatomic, assign) id<TQLScoketConnectDelegate>delegate;

/**
 监听接口，接收数据

 @param port 目标端口
 */
- (void)MonitorPort:(uint16_t)port;

/**
 发送收据

 @param data 数据
 @param host 目标ip地址
 @param port 目标端口
 */
- (void)sendData:(NSData *)data
        withHost:(NSString *)host
        withPort:(uint16_t)port;

/**
 关闭连接
 */
- (void)close;

@end
