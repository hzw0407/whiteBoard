//
//  TQLScoketConnect.m
//  Whiteboard
//
//  Created by HZW on 2018/6/22.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLScoketConnect.h"
#import "GCDAsyncUdpSocket.h"

@interface TQLScoketConnect ()
<GCDAsyncUdpSocketDelegate>

@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;

@end

@implementation TQLScoketConnect

/**
 监听接口，接收数据
 
 @param port 目标端口
 */
- (void)MonitorPort:(uint16_t)port{
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError * error = nil;
    [self.udpSocket bindToPort:port error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }else {
        [self.udpSocket beginReceiving:&error];
    }
}

/**
 发送收据
 
 @param data 数据
 @param host 目标ip地址
 @param port 目标端口
 */
- (void)sendData:(NSData *)data
        withHost:(NSString *)host
        withPort:(uint16_t)port{
    
    [self.udpSocket sendData:data toHost:host port:port withTimeout:-1 tag:0];
    
}

/**
 关闭连接
 */
- (void)close{
    [self.udpSocket close];
}

//消息发送成功
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendDataSuccess)]) {
        [self.delegate sendDataSuccess];
    }
}

//消息发送失败
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendDataFailure:)]) {
        [self.delegate sendDataFailure:error];
    }
}

//接收到的消息
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    if (self.delegate && [self.delegate respondsToSelector:@selector(receiveData:)]) {
        [self.delegate receiveData:data];
    }
}

//连接关闭
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectClose)]) {
        [self.delegate connectClose];
    }
}

@end
