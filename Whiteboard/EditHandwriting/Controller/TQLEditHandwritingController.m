//
//  TQLEditHandwritingController.m
//  Whiteboard
//
//  Created by HZW on 2018/6/15.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLEditHandwritingController.h"
#import "TQLCustomBoard.h"
#import "GCDAsyncUdpSocket.h"
#import "TQLFMDBManager.h"
#import "TQLDotModel.h"
#import "TQLScreenshotModel.h"
#import "TQLColorView.h"
#import "TQLLineWidthView.h"
#import <MessageUI/MessageUI.h>
#import <UShareUI/UShareUI.h>
#import "AppDelegate.h"

@interface TQLEditHandwritingController ()
<UIGestureRecognizerDelegate,
GCDAsyncUdpSocketDelegate,
TQLColorViewDelegate,
TQLLineWidthViewDelegate>

@property (nonatomic, strong) UIView *navigationView;//导航栏view
@property (nonatomic, strong) TQLCustomBoard *customBoard;//画板
@property (nonatomic, strong) UIImageView *toolView;//底部工具栏
@property (nonatomic, strong) TQLColorView *colorView;//颜色view
@property (nonatomic, strong) TQLLineWidthView *lineWidthView;//字体粗细view
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;//udp数据传输
@property (nonatomic, strong) NSTimer *timer;//心跳包定时器
@property (nonatomic, copy) NSString *meetingNameStr;//与会者名字
@property (nonatomic, strong) NSTimer *retransmissionTimer;//消息重发定时器
@property (nonatomic, assign) BOOL isRetransmission;//是否需要重发消息
@property (nonatomic, strong) TQLFMDBManager *FMDBManager;//数据库
@property (nonatomic, assign) NSInteger sendCount;//本地绘制数据发送次数
@property (nonatomic, strong) NSDictionary *lastDic;//上次发送的信息
@property (nonatomic, strong) UIImageView *imageView;//截图
@property (nonatomic, strong) NSMutableData *imageData;//截图数据
@property (nonatomic, strong) TQLScreenshotModel *imageModel;//截图信息模型
@property (nonatomic, strong) NSMutableArray *whiteDeleteArray;//白板橡皮擦数据数组
@property (nonatomic, strong) NSMutableArray *whiteTempArray;//白板橡皮擦擦除的点数据

@property (nonatomic, assign) CGPoint whitePrePoint;//绘制白板笔迹时上一点坐标
@property (nonatomic, assign) BOOL whiteIsDownUp;//绘制白板笔迹时判断是否是down点和up点的连接点
@property (nonatomic, strong) TQLDotModel *whiteTempModel;//绘制白板笔迹时记录上一个点的数据模型

@end

@implementation TQLEditHandwritingController
#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor mainColor];
    
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.customBoard];
    [self.customBoard addSubview:self.imageView];
    [self.customBoard addSubview:self.colorView];
    [self.customBoard addSubview:self.lineWidthView];
    [self.view addSubview:self.toolView];
    
    [self setLayoutView];
    
    self.isRetransmission = YES;
    self.imageData = [NSMutableData data];
    self.imageModel = [[TQLScreenshotModel alloc] init];
    
    [self udpScoketInit];
    [self addtimer];
    
    if (self.pushType == 0) {
        //首页进来
        [self writeName];
    }
    
    self.FMDBManager = [TQLFMDBManager shareFMDBManager];
    [self.FMDBManager creatTable:dotTable];
    [self.FMDBManager creatTable:localDotTable];
    [self.FMDBManager creatTable:screenshotTable];
    [self.FMDBManager creatTable:handwritingList];
    
    self.sendCount = 0;
    self.whitePrePoint = CGPointZero;
    self.whiteIsDownUp = NO;
    self.whiteTempModel = nil;
    
    if (self.pushType == 1) {
        //从笔迹列表进来
        [self performSelector:@selector(drawDataBase) withObject:nil afterDelay:0.1];
    }
    
    //即将进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:@"willResignActive" object:nil];
    //已经进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:@"didBecomeActive" object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //隐藏导航栏
    [self hideNavigation];
    //禁止侧滑返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    //横屏
    [self orientationToPortrait:UIInterfaceOrientationLandscapeLeft];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //开启侧滑返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    
    //竖屏
    [self orientationToPortrait:UIInterfaceOrientationPortrait];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    //关闭连接
    [self.udpSocket close];
    
}

- (void)dealloc{
    self.navigationView = nil;
    self.customBoard = nil;
    self.colorView = nil;
    self.lineWidthView = nil;
    self.toolView = nil;
    self.udpSocket = nil;
    [self.timer invalidate];
    self.timer = nil;
    self.FMDBManager = nil;
    self.lastDic = nil;
    self.imageView = nil;
    self.imageData = nil;
    self.imageModel = nil;
    self.whiteTempArray = nil;
    self.whiteDeleteArray = nil;
    self.whiteTempModel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - CustomMethod
//布局
- (void)setLayoutView{
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(0);
        make.height.equalTo(@(TOP_MARGIN));
    }];
    
    UIButton *leftButton = (UIButton *)[self.navigationView viewWithTag:100];
    [leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.navigationView).offset(AUTOSCALE_WIDTH(10));
        make.top.equalTo(self.navigationView).offset(IS_IPHONE_X ? 44 : 20);
        make.width.height.equalTo(@(44));
        make.height.equalTo(@(44));
    }];
    
    UILabel *titleLabel = (UILabel *)[self.navigationView viewWithTag:101];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.navigationView.mas_centerX);
        make.top.equalTo(self.navigationView).offset(IS_IPHONE_X ? 44 : 20);
        make.width.equalTo(@(AUTOSCALE_WIDTH(100)));
        make.height.equalTo(@(44));
    }];
    
    UIButton *submitButton = (UIButton *)[self.navigationView viewWithTag:102];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.navigationView).offset(-AUTOSCALE_WIDTH(20));
        make.top.equalTo(self.navigationView).offset(IS_IPHONE_X ? 44 : 20);
        make.width.height.equalTo(@(44));
        make.height.equalTo(@(44));
    }];
    
    [self.customBoard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(AUTOSCALE_WIDTH(22));
        make.right.equalTo(self.view).offset(-AUTOSCALE_WIDTH(22));
        make.top.mas_equalTo(self.navigationView.mas_bottom).offset(AUTOSCALE_HEIGHT(20));
        make.bottom.equalTo(self.view).offset(-AUTOSCALE_HEIGHT(50));
    }];
    
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).offset(0);
        make.top.mas_equalTo(self.customBoard.mas_bottom);
        make.bottom.equalTo(self.view).offset(0);
    }];
    
    NSArray *array = @[@"分享",@"颜色",@"字体粗细",@"橡皮擦",@"删除"];
    NSArray *imageArray = @[@"HandwritingEdit_Share",@"HandwritingEdit_Color",@"HandwritingEdit_Font",@"HandwritingEdit_Eraser",@"HandwritingEdit_Delete"];
    CGFloat buttonWidth = ((SCREEN_HEIGHT - AUTOSCALE_WIDTH(100)) / array.count);
    for (NSInteger i = 0; i < array.count; i++) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:array[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setImage:IMAGENAME(imageArray[i]) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:11];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(button.titleLabel.frame.size.height + 30, -button.imageView.frame.size.width - button.titleLabel.frame.size.width, 0, 0)];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0,0, button.titleLabel.intrinsicContentSize.height, -button.titleLabel.intrinsicContentSize.width)];
        button.tag = 200 + i;
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.toolView addSubview:button];

        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.toolView).offset(AUTOSCALE_WIDTH(10) + AUTOSCALE_WIDTH(20) * i + buttonWidth * i);
            make.top.equalTo(self.toolView).offset(AUTOSCALE_HEIGHT(5));
            make.bottom.equalTo(self.toolView).offset(0);
            make.width.equalTo(@(buttonWidth));
        }];
        
        if (i == 3) {
            //橡皮擦的确认、撤销按钮
            CGFloat tempButtonLeft = AUTOSCALE_WIDTH(10) + AUTOSCALE_WIDTH(20) * i + buttonWidth * i;
            NSArray *tempArray = @[@"确认",@"撤销"];
            NSArray *tempImageArray = @[@"HandwritingEdit_Sure",@"HandwritingEdit_Revoke"];
            for (NSInteger k = 0; k < tempArray.count; k++) {
                UIButton *tempButton = [[UIButton alloc] init];
                [tempButton setTitle:tempArray[k] forState:UIControlStateNormal];
                [tempButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                tempButton.titleLabel.font = [UIFont systemFontOfSize:11];
                [tempButton setImage:IMAGENAME(tempImageArray[k]) forState:UIControlStateNormal];
                [tempButton setTitleEdgeInsets:UIEdgeInsetsMake(tempButton.titleLabel.frame.size.height + 30, -tempButton.imageView.frame.size.width - tempButton.titleLabel.frame.size.width, 0, 0)];
                [tempButton setImageEdgeInsets:UIEdgeInsetsMake(0,0, tempButton.titleLabel.intrinsicContentSize.height, -tempButton.titleLabel.intrinsicContentSize.width)];
                tempButton.tag = 300 + k;
                tempButton.hidden = YES;
                [tempButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.toolView addSubview:tempButton];
                
                [tempButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.toolView).offset(tempButtonLeft + buttonWidth / 2 * k);
                    make.top.equalTo(self.toolView).offset(AUTOSCALE_HEIGHT(5));
                    make.bottom.equalTo(self.toolView).offset(0);
                    make.width.equalTo(@((buttonWidth - AUTOSCALE_WIDTH(5)) / 2));
                }];
            }
        }
        
        if (i == 1) {
            //设置颜色view的frame
            [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(button.mas_left).offset(-AUTOSCALE_WIDTH(35));
                make.bottom.equalTo(self.customBoard).offset(-AUTOSCALE_HEIGHT(10));
                make.width.equalTo(@(AUTOSCALE_WIDTH(175)));
                make.height.equalTo(@(AUTOSCALE_HEIGHT(40)));
            }];
        }
        if (i == 2) {
            //设置字体粗细view的frame
            [self.lineWidthView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(button.mas_left).offset(-AUTOSCALE_WIDTH(45));
                make.bottom.equalTo(self.customBoard).offset(-AUTOSCALE_HEIGHT(10));
                make.width.equalTo(@(AUTOSCALE_WIDTH(188)));
                make.height.equalTo(@(AUTOSCALE_HEIGHT(50)));
            }];
        }
    }
    
}

//即将进入后台
- (void)willResignActive{
    //竖屏
    [self orientationToPortrait:UIInterfaceOrientationPortrait];
}

//已经进入前台
- (void)didBecomeActive{
    //横屏
    [self orientationToPortrait:UIInterfaceOrientationLandscapeLeft];
}

//设置屏幕方向
- (void)orientationToPortrait:(UIInterfaceOrientation)orientation {
    
    SEL selector = NSSelectorFromString(@"setOrientation:");
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
    [invocation setSelector:selector];
    [invocation setTarget:[UIDevice currentDevice]];
    int val = orientation;
    //前两个参数已被target和selector占用
    [invocation setArgument:&val atIndex:2];
    [invocation invoke];
}

//设置样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

//设置是否隐藏
- (BOOL)prefersStatusBarHidden {
    return NO;
}

//设置隐藏动画
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

//绘制数据库数据
- (void)drawDataBase{
    
    //屏幕绘制数据
    NSArray *screenArray = [self.FMDBManager FMDBSearchAll:localDotTable];
    NSMutableArray *temOneArray = [NSMutableArray array];
    for (TQLDotModel *model in screenArray) {
        if (model.pageID == self.pageID) {
            //只绘制当前页的数据
            [temOneArray addObject:model];
        }
    }
    if (temOneArray.count > 0) {
        //上一个点
        CGPoint previousPoint = CGPointZero;
        NSInteger index = 0;
        //是否是up点和down点的连续点
        BOOL isDowmUp = NO;
        
        for (TQLDotModel *model in temOneArray) {
            
//            [self drawWhiteSendData:model];
            
            TQLDotModel *currentModel = temOneArray[index];
            if (index < temOneArray.count - 1) {
                TQLDotModel *nextModel = temOneArray[index + 1];
                if (currentModel.mouseStatus == 3 && nextModel.mouseStatus == 1) {
                    isDowmUp = YES;
                }
            }

            if (model.mouseStatus == 1) {
                previousPoint = CGPointMake(model.pointX, model.pointY);
            }

            //当前点
            CGPoint currentPoint = CGPointMake(model.pointX, model.pointY);
            if (index == 0) {
                //第一个点创建图形上下文
                [self.customBoard creatImageContex];
            }else if (index == temOneArray.count - 1){
                //最后一个点绘制完成生成图片
                [self.customBoard creatImage];
            }else{
                if (!isDowmUp) {
                    //不是up点和down点连续的点
                    [self.customBoard drawEachDot:[UIColor colorWithHexString:model.handwritingColor] withLineWidth:model.handwritingWidth withIsEarser:model.isEraser withCurrentPoint:currentPoint withPreviousPoint:previousPoint withIsHand:NO];
                }
            }
            previousPoint = currentPoint;
            isDowmUp = NO;

            index ++;
        }
    }
    
    //白板传过来保存的数据
    NSArray *whiteArray = [self.FMDBManager FMDBSearchAll:dotTable];
    NSMutableArray *tempTwoArray = [NSMutableArray array];
    for (TQLDotModel *model in whiteArray) {
        if (model.pageID == self.pageID) {
            //只绘制当前页数据
            [tempTwoArray addObject:model];
        }
    }
    if (tempTwoArray.count > 0) {
        //上一个点
        CGPoint previousPoint = CGPointZero;
        NSInteger index = 0;
        //是否是up点和down点的连续点
        BOOL isDowmUp = NO;
        
        for (TQLDotModel *model in tempTwoArray) {
            
            TQLDotModel *currentModel = tempTwoArray[index];
            if (index < tempTwoArray.count - 1) {
                TQLDotModel *nextModel = tempTwoArray[index + 1];
                if (currentModel.mouseStatus == 3 && nextModel.mouseStatus == 1) {
                    isDowmUp = YES;
                }
            }
            
            if (model.mouseStatus == 1) {
//                previousPoint = CGPointMake(model.pointX, model.pointY);
                previousPoint = [self equalProportionScale:model.pointX withPointY:model.pointY];
            }
            
            //当前点
            CGPoint currentPoint = [self equalProportionScale:model.pointX withPointY:model.pointY];
            if (index == 0) {
                //第一个点创建图形上下文
                [self.customBoard creatImageContex];
            }else if (index == tempTwoArray.count - 1){
                //最后一个点绘制完成生成图片
                [self.customBoard creatImage];
            }else{
                if (!isDowmUp) {
                    //不是up点和down点连续的点
                    UIColor *color;
                    if ([model.handwritingColor isEqualToString:@"000000ff"]) {
                        color = [UIColor blackColor];
                    }else{
                        color = [UIColor colorWithHexString:model.handwritingColor];
                    }
                    [self.customBoard drawEachDot:color withLineWidth:model.handwritingWidth withIsEarser:model.isEraser withCurrentPoint:currentPoint withPreviousPoint:previousPoint withIsHand:NO];
                }
            }
            previousPoint = currentPoint;
            isDowmUp = NO;
            
            index ++;
        }
    }
    
    //截图数据
    NSArray *imageArray = [self.FMDBManager FMDBSearchAll:screenshotTable];
    NSMutableArray *tempThreeArray = [NSMutableArray array];
    for (TQLDotModel *model in imageArray) {
        //只绘制当前页数据
        if (model.pageID == self.pageID) {
            [tempThreeArray addObject:model];
        }
    }
    if (tempThreeArray.count > 0) {
        TQLScreenshotModel *imageModel2 = tempThreeArray[0];
        UIImageView *imageView = [[UIImageView alloc] init];
        NSData *imageData = [NSString convertHexStrToData:imageModel2.dataStr];
        imageView.image = [UIImage imageWithData:imageData];
        [self.customBoard addSubview:imageView];
        CGPoint point = [self equalProportionScale:imageModel2.pointX withPointY:imageModel2.pointY];
        CGSize size = [self equalProporionSize:imageModel2.width withHeight:imageModel2.height];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.customBoard).offset(point.x);
            make.top.equalTo(self.customBoard).offset(point.y);
            make.width.equalTo(@(size.width));
            make.height.equalTo(@(size.height));
        }];
    }

}

//填写签到名称
- (void)writeName{
    UIAlertController *alertCntroller = [UIAlertController alertControllerWithTitle:@"请填写姓名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = alertCntroller.textFields[0];
        self.meetingNameStr = textField.text;
        //拼接上本机ip地址一起发送过去
        [self sendData:[NSString stringWithFormat:@"%@;%@",textField.text,[NSString getIPAddress]] withInstructions:@"A1" withValue:5 withTag:0];
        
    }];
    [alertCntroller addAction:sureAction];
    
    [alertCntroller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    [self presentViewController:alertCntroller animated:YES completion:nil];
}

//udp初始化
- (void)udpScoketInit{
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError * error = nil;
    [self.udpSocket bindToPort:self.port error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }else {
        [self.udpSocket beginReceiving:&error];
    }
}

//发送消息
- (void)sendData:(NSString *)dataStr
withInstructions:(NSString *)instructions
       withValue:(NSInteger)intValue
         withTag:(NSInteger)tag{
    
    NSData *hexStr;
    if (dataStr.length > 0) {
        if ([instructions isEqualToString:@"C8"]) {
            //截图应答
            hexStr = [self intToData:dataStr.integerValue withByteLength:2];
        }else{
            //其他需要传数据情况
            hexStr = [self dataFromString:dataStr];
        }
    }else{
        if ([instructions isEqualToString:@"C3"]) {
            //坐标数据
            NSArray *array = [self.FMDBManager FMDBSearchAll:@"dotTable"];
            TQLDotModel *model = array[self.sendCount];
            hexStr = [self changeCoorinate:model];
        }else{
            //其他不需要传数据情况
            hexStr = [self intToData:intValue withByteLength:intValue];
        }
    }
    Byte *byte = (Byte *)malloc(hexStr.length + 7);
    byte[0] = 0xFF;
    if ([instructions isEqualToString:@"A1"]){
        //签到
        byte[1] = 0xA1;
    }else if ([instructions isEqualToString:@"AB"]){
        //屏幕分辨率获取成功应答
        byte[1] = 0xAB;
    }else if ([instructions isEqualToString:@"A5"]){
        //请求数据
        byte[1] = 0xA5;
    }else if ([instructions isEqualToString:@"C4"]){
        //接收到坐标数据发送应答
        byte[1] = 0xC4;
    }else if ([instructions isEqualToString:@"A7"]){
        //提交数据请求
        byte[1] = 0xA7;
    }else if ([instructions isEqualToString:@"C3"]){
        //提交数据
        byte[1] = 0xC3;
    }else if ([instructions isEqualToString:@"A2"]){
        //心跳包
        byte[1] = 0xA2;
    }else if ([instructions isEqualToString:@"C8"]){
        //收到截图数据应答
        byte[1] = 0xC8;
    }else if ([instructions isEqualToString:@"C2"]){
        //首页切页指令应答
        byte[1] = 0xC2;
    }else if ([instructions isEqualToString:@"C6"]){
        //收到橡皮擦数据应答
        byte[1] = 0xC6;
    }else if ([instructions isEqualToString:@"CB"]){
        //收到撤销指令应答
        byte[1] = 0xCB;
    }else if ([instructions isEqualToString:@"CD"]){
        //收到还原指令应答
        byte[1] = 0xCD;
    }else if ([instructions isEqualToString:@"D2"]){
        //收到清除指令应答
        byte[1] = 0xD2;
    }else if ([instructions isEqualToString:@"D4"]){
        //收到保存指令应答
        byte[1] = 0xD4;
    }
    byte[2] = hexStr.length;
    byte[3] = hexStr.length << 8;
    byte[4] = hexStr.length << 16;
    byte[5]= hexStr.length << 32;
    memcpy(byte + 6, [hexStr bytes], hexStr.length);
    byte[hexStr.length + 6] = 0xFE;
    NSData *data = [NSData dataWithBytes:byte length:hexStr.length + 7];
    [self.udpSocket sendData:data toHost:self.host port:self.port withTimeout:-1 tag:tag];
    
    self.lastDic = @{ @"dataStr":dataStr,
                      @"instructions":instructions,
                      @"intValue":[NSNumber numberWithInteger:intValue],
                      @"tag":[NSNumber numberWithInteger:tag]
                      };
}

//字符串转NSData
- (NSData *)dataFromString:(NSString *)string{
    
    NSData *myData = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myData bytes];
    NSData *data = [NSData dataWithBytes:bytes length:myData.length];
    return data;
}

/**
 整型转NSData

 @param value 需要转换的整型
 @param length 转换的字节数
 @return 转换后的数据
 */
- (NSData *)intToData:(NSInteger)value withByteLength:(NSInteger)length{
    
    if (length == 0) {
        Byte byte[0] = {};
        return [NSData dataWithBytes:byte length:0];
    }else if (length == 1){
        Byte byte[1] = {};
        byte[0] = (Byte) (value & 0xFF);
        return [NSData dataWithBytes:byte length:1];
    }else if (length == 2){
        Byte byte[2] = {};
        byte[0] = (Byte)(value & 0xFF);
        byte[1] = (Byte)((value & 0xFF) << 8);
        return [NSData dataWithBytes:byte length:2];
    }else if (length == 4){
        Byte byte[4] = {};
        byte[0] = (Byte)(value & 0xFF);
        byte[1] = (Byte)((value & 0xFF) << 8);
        byte[2] = (Byte)((value & 0xFF) << 16);
        byte[3] = (Byte)((value & 0xFF) << 24);
        return [NSData dataWithBytes:byte length:4];
    }else{
        return nil;
    }
    
}

/**
 NSData转整型

 @param data 需要转换的data数据
 @param length 字节数
 @return 转换后的整型
 */
- (NSInteger)dataToInt:(NSData *)data withByteLength:(NSInteger)length{
    
    if (length == 1) {
        Byte byte[1] = {};
        [data getBytes:byte length:1];
        NSInteger value;
        value = (NSInteger) (byte[0] & 0xFF);
        return value;
    }else if (length == 2){
        Byte byte[2] = {};
        [data getBytes:byte length:2];
        NSInteger value;
        value = (NSInteger) (((byte[1] & 0xFF) << 8)
                       | (byte[0] & 0xFF));
        return value;
    }else if (length == 4){
        Byte byte[4] = {};
        [data getBytes:byte length:4];
        NSInteger value;
        value = (NSInteger) (((byte[3] & 0xFF << 24 ))
                       | ((byte[2] & 0xFF) << 16)
                       | ((byte[1] & 0xFF) << 8)
                       | (byte[0] & 0xFF));
        return value;
    }else{
        return 0;
    }
    
}

//创建定时器
- (void)addtimer{
    self.timer = [NSTimer timerWithTimeInterval:30 target:self selector:@selector(longConnectToSocket) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)longConnectToSocket{
    //发送固定格式的心跳包
    [self sendData:[NSString stringWithFormat:@"%@;%@",self.meetingNameStr,[NSString getIPAddress]] withInstructions:@"A2" withValue:5 withTag:2];
}

//判断接收到的是哪个指令
- (void)judgeInstructions:(NSData *)data{
    
    Byte *byte = (Byte *)[data bytes];
    uint16_t protocolHeader = byte[0];
    uint16_t instructions = byte[1];
    if (protocolHeader == 255) {
        //协议头是FF
        if (instructions == 170) {
            //AA 收到屏幕分辨率 发送应答
            [self sendData:@"" withInstructions:@"AB" withValue:1 withTag:0];
            //解析白板的分辨率
            NSData *widthData = [data subdataWithRange:NSMakeRange(6, 4)];
            NSData *heightData = [data subdataWithRange:NSMakeRange(10, 4)];
            NSInteger whiteBoardWidth = [self dataToInt:widthData withByteLength:4];
            NSInteger whiteBoardHeight = [self dataToInt:heightData withByteLength:4];
            USER_DEFAULTS_SET([NSNumber numberWithInteger:whiteBoardWidth], WHITEWIDTH);
            USER_DEFAULTS_SET([NSNumber numberWithInteger:whiteBoardHeight], WHITEHEIGHT);
            
            //发送请求数据指令
            [self sendData:@"" withInstructions:@"A5" withValue:0 withTag:0];
        }else if (instructions == 197){
            //C5 橡皮擦坐标数据
            
            //解析橡皮擦数据
            [self analysisEraser:data];
            //接收到数据发送应答 继续接收下一个包数据
            [self sendData:@"" withInstructions:@"C6" withValue:1 withTag:0];
        }else if (instructions == 166){
            //A6 app请求数据应答指令
        }else if (instructions == 168){
            //A8 app提交数据应答指令
            
            //发送坐标数据
            [self sendCoorinate];
        }else if (instructions == 193){
            //C1 切页指令
            
            //发送应答
            [self sendData:@"" withInstructions:@"C2" withValue:1 withTag:0];
        }else if (instructions == 195){
            //C3 白板传过来的书写坐标数据
            
            //解析坐标数据
            [self analysisCoordinateData:data];
            //接收到数据发送应答 继续接收下一个包数据
            [self sendData:@"" withInstructions:@"C4" withValue:1 withTag:0];
        }else if (instructions == 196){
            //C4 白板接收到数据应答 继续传数据过去
            
            //继续发送坐标数据
            NSArray *array = [self.FMDBManager FMDBSearchAll:localDotTable];
            if (self.sendCount < array.count) {
                [self sendCoorinate];
            }else{
                //数据发送完毕
                self.sendCount = 0;
            }
        }else if (instructions == 199){
            //C7 截图数据
            
            //数据长度
            NSData *lengthData = [data subdataWithRange:NSMakeRange(2, 4)];
            NSInteger length = [self dataToInt:lengthData withByteLength:4];
            
            if (length == 0) {
                //结束包
                //发送结束包应答
                [self sendData:@"" withInstructions:@"C8" withValue:1 withTag:0];
            }else{
                
                //页面id
                NSData *pageIDData = [data subdataWithRange:NSMakeRange(6, 2)];
                NSInteger pageID = [self dataToInt:pageIDData withByteLength:2];
                self.imageModel.pageID = pageID;
                //包号
                NSData *packetData = [data subdataWithRange:NSMakeRange(8, 2)];
                NSInteger packetNum = [self dataToInt:packetData withByteLength:2];
                
                //发送收到数据应答 继续接收数据
                [self sendData:[NSString stringWithFormat:@"%zd",packetNum] withInstructions:@"C8" withValue:2 withTag:0];
            }
            
            [self analysisScreenshot:data];
        }else if (instructions == 202){
            //CA 撤销指令
            
            [self revokeWhite];
            
            //发送应答
            [self sendData:@"" withInstructions:@"CB" withValue:1 withTag:0];
        }else if (instructions == 204){
            //CC 还原指令
            
            //发送应答
            [self sendData:@"" withInstructions:@"CD" withValue:1 withTag:0];
        }else if (instructions == 209){
            //D1 清除指令
            self.customBoard.image = nil;
            [self.FMDBManager FMDBDeleteAll:dotTable];
            [self.FMDBManager FMDBDeleteAll:screenshotTable];
            [self drawDataBase];
            
            //发送应答
            [self sendData:@"" withInstructions:@"D2" withValue:1 withTag:0];
        }else if (instructions == 211){
            //D3 保存指令
            
            //保存截图
            [self.customBoard saveImage:YES];
            
            //发送应答
            [self sendData:@"" withInstructions:@"D4" withValue:1 withTag:0];
        }
    }else{
        NSLog(@"协议头错误");
    }
}

//消息重发
- (void)retransmission{
    if (self.isRetransmission) {
        NSString *dataStr = self.lastDic[@"dataStr"];
        NSString *instructions = self.lastDic[@"instructions"];
        NSNumber *valueNum = self.lastDic[@"intValue"];
        NSInteger intValue = valueNum.integerValue;
        NSNumber *tagNum = self.lastDic[@"tag"];
        NSInteger tag = tagNum.integerValue;
        [self sendData:dataStr withInstructions:instructions withValue:intValue withTag:tag];
    }
}

//解析坐标数据
- (void)analysisCoordinateData:(NSData *)data{
    TQLDotModel *model = [[TQLDotModel alloc] init];
    model.isEraser = NO;
    
    //页码id
    NSData *pageIDData = [data subdataWithRange:NSMakeRange(6, 2)];
    model.pageID = [self dataToInt:pageIDData withByteLength:2];
    //线宽
    NSData *widthData = [data subdataWithRange:NSMakeRange(8, 2)];
    model.handwritingWidth = [self dataToInt:widthData withByteLength:2];
    //颜色的十六进制
    NSData *colorData = [data subdataWithRange:NSMakeRange(10, 4)];
    model.handwritingColor = [NSString convertDataToHexStr:colorData];
    //x坐标
    NSData *pointXData = [data subdataWithRange:NSMakeRange(14, 2)];
    model.pointX = [self dataToInt:pointXData withByteLength:2];
    //y坐标
    NSData *pointYData = [data subdataWithRange:NSMakeRange(16, 2)];
    model.pointY = [self dataToInt:pointYData withByteLength:2];
    //压力值
    NSData *pressureData = [data subdataWithRange:NSMakeRange(18, 2)];
    model.pressure = [self dataToInt:pressureData withByteLength:2];
    //鼠标状态
    NSData *mouseData = [data subdataWithRange:NSMakeRange(20, 1)];
    model.mouseStatus = [self dataToInt:mouseData withByteLength:1];
    
    [self.FMDBManager FMDBInsert:dotTable withDotModel:model withScreenshot:nil withHandwritingList:nil];
    
    [self drawWhiteSendData:model];
}

//绘制白板传过来的数据
- (void)drawWhiteSendData:(TQLDotModel *)model{
    
    if (self.whiteTempModel.mouseStatus == 3 && model.mouseStatus == 1) {
        self.whiteIsDownUp = YES;
    }

    CGPoint currentPoint = [self equalProportionScale:model.pointX withPointY:model.pointY];
//    CGPoint currentPoint = CGPointMake(model.pointX, model.pointY);
    
    if (model.mouseStatus == 1) {
        self.whitePrePoint = [self equalProportionScale:model.pointX withPointY:model.pointY];
    }
    
    UIColor *color;
    if ([model.handwritingColor isEqualToString:@"000000ff"]) {
        color = [UIColor blackColor];
    }else{
        color = [UIColor colorWithHexString:model.handwritingColor];
    }
    if (!self.whiteIsDownUp) {
        self.customBoard.pageID = model.pageID;
        [self.customBoard drawEachDot:color withLineWidth:model.handwritingWidth withIsEarser:model.isEraser withCurrentPoint:currentPoint withPreviousPoint:self.whitePrePoint withIsHand:YES];
    }
    
//    if (model.mouseStatus == 1) {
//        [self.customBoard creatImageContex];
////        self.whitePrePoint = CGPointMake(model.pointX, model.pointY);
//        self.whitePrePoint = [self equalProportionScale:model.pointX withPointY:model.pointY];
//    }else if (model.mouseStatus == 3){
//        [self.customBoard creatImage];
//    }else{
//        if (!self.whiteIsDownUp) {
//            [self.customBoard drawEachDot:[UIColor colorWithHexString:model.handwritingColor] withLineWidth:model.handwritingWidth withIsEarser:model.isEraser withCurrentPoint:currentPoint withPreviousPoint:self.whitePrePoint withIsHand:NO];
//        }
//    }
    
    self.whiteTempModel = model;
    self.whitePrePoint = currentPoint;
    self.whiteIsDownUp = NO;
    
}

//转换坐标数据
- (NSData *)changeCoorinate:(TQLDotModel *)model{
    NSMutableData *data = [NSMutableData data];
    //页码id
    NSData *pageIDData = [self intToData:model.pageID withByteLength:2];
    [data appendData:pageIDData];
    //笔迹宽度
    NSData *handwritingWidthData = [self intToData:model.handwritingWidth withByteLength:2];
    [data appendData:handwritingWidthData];
    //笔迹颜色
    NSInteger colorInt = [self numberWithHexString:model.handwritingColor];
    NSData *colorData = [self intToData:colorInt withByteLength:4];
    [data appendData:colorData];
    //x坐标
    NSData *pointXData = [self intToData:model.pointX withByteLength:2];
    [data appendData:pointXData];
    //y坐标
    NSData *pointYData = [self intToData:model.pointY withByteLength:2];
    [data appendData:pointYData];
    //压力值
    NSData *preData = [self intToData:model.pressure withByteLength:2];
    [data appendData:preData];
    //鼠标状态
    NSData *mouseData = [self intToData:model.mouseStatus withByteLength:1];
    [data appendData:mouseData];
    
    return data;
}

//解析截图包数据
- (void)analysisScreenshot:(NSData *)data{
    
    //数据长度
    NSData *lengthData = [data subdataWithRange:NSMakeRange(2, 4)];
    NSInteger length = [self dataToInt:lengthData withByteLength:4];
    if (length == 0) {
        //结束包
        self.imageView.image = [UIImage imageWithData:self.imageData];
        NSString *imageStr = [NSString convertDataToHexStr:self.imageData];
        self.imageModel.dataStr = imageStr;
        [self.FMDBManager FMDBInsert:screenshotTable withDotModel:nil withScreenshot:self.imageModel withHandwritingList:nil];
        
        self.imageData = [NSMutableData data];
    }else{
        //包号
        NSData *packetData = [data subdataWithRange:NSMakeRange(8, 2)];
        NSInteger packetNum = [self dataToInt:packetData withByteLength:2];
        if (packetNum == 0) {
            //第一个包
            
            //x坐标
            NSData *pointXData = [data subdataWithRange:NSMakeRange(10, 2)];
            NSInteger pointX = [self dataToInt:pointXData withByteLength:2];
            self.imageModel.pointX = pointX;
            //y坐标
            NSData *pointYData = [data subdataWithRange:NSMakeRange(12, 2)];
            NSInteger pointY = [self dataToInt:pointYData withByteLength:2];
            self.imageModel.pointY = pointY;
            //宽度
            NSData *widthData = [data subdataWithRange:NSMakeRange(14, 2)];
            NSInteger width = [self dataToInt:widthData withByteLength:2];
            self.imageModel.width = width;
            //高度
            NSData *heightData = [data subdataWithRange:NSMakeRange(16, 2)];
            NSInteger height = [self dataToInt:heightData withByteLength:2];
            self.imageModel.height = height;
            //图像数据
            NSData *tempOneData = [data subdataWithRange:NSMakeRange(18, data.length - 19)];
            [self.imageData appendData:tempOneData];
            
            //设置图片位置
            CGPoint point = [self equalProportionScale:pointX withPointY:pointY];
            CGSize size = [self equalProporionSize:width withHeight:height];
            [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.customBoard).offset(point.x);
                make.top.equalTo(self.customBoard).offset(point.y);
                make.width.equalTo(@(size.width));
                make.height.equalTo(@(size.height));
            }];
        }else{
            NSData *tempTwoData = [data subdataWithRange:NSMakeRange(10, data.length - 11)];
            [self.imageData appendData:tempTwoData];
        }
    }
    
}

//解析橡皮擦数据
- (void)analysisEraser:(NSData *)data{
    
    TQLDotModel *model = [[TQLDotModel alloc] init];
    model.isEraser = YES;
    
    //页面id
    NSData *pageIDData = [data subdataWithRange:NSMakeRange(6, 2)];
    NSInteger pageID = [self dataToInt:pageIDData withByteLength:2];
    model.pageID = pageID;
    
    //橡皮擦宽度
    NSData *widthData = [data subdataWithRange:NSMakeRange(8, 2)];
    NSInteger width = [self dataToInt:widthData withByteLength:2];
    model.handwritingWidth = width;
    
    //颜色
    model.handwritingColor = @"00FFFFFF";
    
    //x坐标
    NSData *pointXData = [data subdataWithRange:NSMakeRange(10, 2)];
    NSInteger pointX = [self dataToInt:pointXData withByteLength:2];
    model.pointX = pointX;
    
    //y坐标
    NSData *pointYData = [data subdataWithRange:NSMakeRange(12, 2)];
    NSInteger pointY = [self dataToInt:pointYData withByteLength:2];
    model.pointY = pointY;
    
    //鼠标状态
    NSData *mouseData = [data subdataWithRange:NSMakeRange(14, 1)];
    NSInteger mouse = [self dataToInt:mouseData withByteLength:1];
    model.mouseStatus = mouse;
    
    if (mouse == 1) {
        //down
        self.whiteTempArray = [NSMutableArray array];
        [self.whiteTempArray addObject:model];
    }else if (mouse == 2){
        //move
        [self.whiteTempArray addObject:model];
    }else if (mouse == 3){
        //up
        [self.whiteTempArray addObject:model];
        [self.whiteDeleteArray addObject:self.whiteTempArray];
    }
    
    [self drawWhiteSendData:model];
}

//撤销白板橡皮擦数据
- (void)revokeWhite{
    if (self.whiteDeleteArray.count > 0) {
        [self.whiteDeleteArray removeObjectAtIndex:self.whiteDeleteArray.count - 1];
        
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[self.FMDBManager FMDBSearchAll:dotTable]];
        for (NSArray *array in self.whiteDeleteArray) {
            for (TQLDotModel *model in array) {
                [tempArray addObject:model];
            }
        }
        
        //本地屏幕绘制的数据也要重绘
        NSArray *localArray = [self.FMDBManager FMDBSearchAll:localDotTable];
        [tempArray addObjectsFromArray:localArray];
        NSArray *screenArray = [self.FMDBManager FMDBSearchAll:screenshotTable];
        [tempArray addObjectsFromArray:screenArray];
        
        CGPoint previousPoint = CGPointZero;
        NSInteger index = 0;
        //是否是up点和down点的连续点
        BOOL isDowmUp = NO;
        
        for (TQLDotModel *model in tempArray) {
            
            TQLDotModel *currentModel = tempArray[index];
            if (index < tempArray.count - 1) {
                TQLDotModel *nextModel = tempArray[index + 1];
                if (currentModel.mouseStatus == 3 && nextModel.mouseStatus == 1) {
                    isDowmUp = YES;
                }
            }
            
            if (model.mouseStatus == 1) {
                previousPoint = CGPointMake(model.pointX, model.pointY);
            }
            
            //当前点
            CGPoint currentPoint = CGPointMake(model.pointX, model.pointY);
            if (index == 0) {
                //第一个点创建图形上下文
                [self.customBoard creatImageContex];
            }else if (index == tempArray.count - 1){
                //最后一个点绘制完成生成图片
                [self.customBoard creatImage];
            }else{
                if (!isDowmUp) {
                    //不是up点和down点连续的点
                    [self.customBoard drawEachDot:[UIColor colorWithHexString:model.handwritingColor] withLineWidth:model.handwritingWidth withIsEarser:model.isEraser withCurrentPoint:currentPoint withPreviousPoint:previousPoint withIsHand:NO];
                }
            }
            previousPoint = currentPoint;
            isDowmUp = NO;
            
            index ++;
        }
        
    }
}

//十六进制转数字
- (NSInteger)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}

//发送坐标数据
- (void)sendCoorinate{
    [self sendData:@"" withInstructions:@"C3" withValue:13 withTag:1];
}

//将白板坐标等比例缩放成手机屏幕坐标
- (CGPoint)equalProportionScale:(CGFloat)pointX withPointY:(CGFloat)pointY{
    
    //白板宽度、高度
    NSNumber *widthNum = USER_DEFAULTS_GET_OBJECT(WHITEWIDTH);
    NSNumber *heightNum = USER_DEFAULTS_GET_OBJECT(WHITEHEIGHT);
    
    CGFloat scalePointX = (self.customBoard.width / widthNum.integerValue * 1.0) * pointX;
    CGFloat scalePointY = (self.customBoard.height / heightNum.integerValue * 1.0) * pointY;
    
    return CGPointMake(scalePointX, scalePointY);
    
}

//将白板size等比例缩放成手机屏幕size
- (CGSize)equalProporionSize:(NSInteger)width withHeight:(NSInteger)height{
    
    //白板宽度、高度
    NSNumber *widthNum = USER_DEFAULTS_GET_OBJECT(WHITEWIDTH);
    NSNumber *heightNum = USER_DEFAULTS_GET_OBJECT(WHITEHEIGHT);
    
    CGFloat scaleWidth = (self.customBoard.width / widthNum.integerValue * 1.0) * width;
    CGFloat scaleHeight = (self.customBoard.height / heightNum.integerValue * 1.0) * height;
    
    return CGSizeMake(scaleWidth, scaleHeight);
    
}

// 计算中间点
- (CGPoint)middlePoint:(CGPoint)p1 withP2:(CGPoint)p2{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

//分享
-(void)tql_share{
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_YouDaoNote),@(UMSocialPlatformType_EverNote)]];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        [self shareWebPageToPlatformType:platformType];
    }];
}

- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    messageObject.text = @"腾千里";
    //分享图文
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
//    shareObject.thumbImage = IMAGENAME(@"BusinessNotes");
    [shareObject setShareImage:[self.customBoard getImageFromView]];
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}

#pragma mark - ClickMethod
- (void)btnClick:(UIButton *)btn{
    UIButton *tempButtonOne = (UIButton *)[self.toolView viewWithTag:300];
    UIButton *tempButtonTwo = (UIButton *)[self.toolView viewWithTag:301];
    
    if (btn.tag == 100) {
        //返回
        [self.navigationController popViewControllerAnimated:YES];
    }else if (btn.tag == 102){
        //提交数据
//        [self sendData:@"" withInstructions:@"A7" withValue:0 withTag:0];
//        [self.FMDBManager FMDBDeleteTable:dotTable];
//        NSData *data = [@"123" dataUsingEncoding:NSUTF8StringEncoding];
//        [self.udpSocket sendData:data toHost:self.host port:self.port withTimeout:-1 tag:0];
        [self.customBoard saveImage:YES];
    }else if (btn.tag == 200) {
        //分享
        self.colorView.hidden = YES;
        self.lineWidthView.hidden = YES;
        UIButton *eraserButton = (UIButton *)[self.toolView viewWithTag:203];
        eraserButton.hidden = NO;
        tempButtonOne.hidden = YES;
        tempButtonTwo.hidden = YES;
        self.customBoard.lineWidth = 2.0;
        self.customBoard.lineColor = [UIColor blackColor];
        self.customBoard.isEraser = NO;
        
        [self tql_share];
    }else if (btn.tag == 201){
        //颜色
        self.colorView.hidden = NO;
        self.lineWidthView.hidden = YES;
        UIButton *eraserButton = (UIButton *)[self.toolView viewWithTag:203];
        eraserButton.hidden = NO;
        tempButtonOne.hidden = YES;
        tempButtonTwo.hidden = YES;
        self.customBoard.lineWidth = 2.0;
        self.customBoard.lineColor = [UIColor blackColor];
        self.customBoard.isEraser = NO;
    }else if (btn.tag == 202){
        //字体粗细
        self.colorView.hidden = YES;
        self.lineWidthView.hidden = NO;
        UIButton *eraserButton = (UIButton *)[self.toolView viewWithTag:203];
        eraserButton.hidden = NO;
        tempButtonOne.hidden = YES;
        tempButtonTwo.hidden = YES;
        self.customBoard.lineWidth = 2.0;
        self.customBoard.lineColor = [UIColor blackColor];
        self.customBoard.isEraser = NO;
    }else if (btn.tag == 203){
        //橡皮擦
        self.colorView.hidden = YES;
        self.lineWidthView.hidden = YES;
        btn.hidden = YES;
        
        tempButtonOne.hidden = NO;
        tempButtonTwo.hidden = NO;
        
        [self.customBoard eraser];
    }else if (btn.tag == 204){
        //删除
        self.colorView.hidden = YES;
        self.lineWidthView.hidden = YES;
        UIButton *eraserButton = (UIButton *)[self.toolView viewWithTag:203];
        eraserButton.hidden = NO;
        tempButtonOne.hidden = YES;
        tempButtonTwo.hidden = YES;
        self.customBoard.lineWidth = 2.0;
        self.customBoard.lineColor = [UIColor blackColor];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"删除后不可恢复该笔迹" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.customBoard deleteData];
        }];
        [alertController addAction:sureAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }else if (btn.tag == 300){
        //橡皮擦确认删除
        [self.customBoard deleteEraserData];
    }else if (btn.tag == 301){
        //橡皮擦撤销删除
        [self.customBoard revoke];
    }
}

#pragma mark - SystemDelegate

#pragma mark - CustomDelegate

#pragma mark - GCDAsyncUdpSocketDelegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    if (tag == 0) {
        NSLog(@"发送信息成功");
    }else if (tag == 2){
        NSLog(@"心跳包发送成功");
    }
    if (tag == 1) {
        //向白板发送坐标数据成功
        self.sendCount ++;
    }
    self.retransmissionTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(retransmission) userInfo:nil repeats:YES];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"发送信息失败");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    
    self.isRetransmission = NO;
    [self.retransmissionTimer invalidate];
    self.retransmissionTimer = nil;
    
    //判断收到的应答是哪个
    [self judgeInstructions:data];
    
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    NSLog(@"udpSocket关闭");
    self.udpSocket.delegate = nil;
    self.udpSocket = nil;
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - TQLColorViewDelegate
//选中的颜色
- (void)selectColor:(UIColor *)color{
    self.customBoard.lineColor = color;
    self.colorView.hidden = YES;
}

#pragma mark - TQLLineWidthViewDelegate
- (void)selectWidth:(CGFloat)width{
    self.customBoard.lineWidth = width;
    self.lineWidthView.hidden = YES;
}

#pragma mark - GetterAndSetter
- (UIView *)navigationView{
    if (!_navigationView) {
        _navigationView = [[UIView alloc] init];
        _navigationView.backgroundColor = [UIColor whiteColor];
        
        //返回按钮
        UIButton *leftButton = [[UIButton alloc] init];
        [leftButton setImage:IMAGENAME(@"default_return") forState:UIControlStateNormal];
        leftButton.tag = 100;
        [leftButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_navigationView addSubview:leftButton];
        
        //标题
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.text = @"编辑笔迹";
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:20];
        titleLabel.tag = 101;
        [_navigationView addSubview:titleLabel];
        
        //提交按钮
        UIButton *submitButton = [[UIButton alloc] init];
        [submitButton setImage:IMAGENAME(@"HandwritingEdit_Save") forState:UIControlStateNormal];
        submitButton.tag = 102;
        [submitButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_navigationView addSubview:submitButton];
        
    }
    return _navigationView;
}

- (TQLCustomBoard *)customBoard{
    if (!_customBoard) {
        _customBoard = [[TQLCustomBoard alloc] init];
        _customBoard.lineColor = [UIColor blackColor];
        _customBoard.lineWidth = 2.0f;
        _customBoard.isEraser = NO;
        _customBoard.pageID = self.pageID;
    }
    return _customBoard;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
//        _imageView.backgroundColor = [UIColor redColor];
    }
    return _imageView;
}

- (UIImageView *)toolView{
    if (!_toolView) {
        _toolView = [[UIImageView alloc] init];
        _toolView.image = IMAGENAME(@"HandwritingEdit_Bottom");
        _toolView.userInteractionEnabled = YES;
    }
    return _toolView;
}

- (TQLColorView *)colorView{
    if (!_colorView) {
        _colorView = [[TQLColorView alloc] init];
        _colorView.delegate = self;
        _colorView.hidden = YES;
    }
    return _colorView;
}

- (TQLLineWidthView *)lineWidthView{
    if (!_lineWidthView) {
//        _lineWidthView = [[TQLLineWidthView alloc] initWithFrame:CGRectMake(AUTOSCALE_WIDTH(220), AUTOSCALE_HEIGHT(185), AUTOSCALE_WIDTH(188), AUTOSCALE_HEIGHT(50))];
        _lineWidthView = [[TQLLineWidthView alloc] init];
        _lineWidthView.delegate = self;
        _lineWidthView.hidden = YES;
    }
    return _lineWidthView;
}

- (NSMutableArray *)whiteDeleteArray{
    if (!_whiteDeleteArray) {
        _whiteDeleteArray = [NSMutableArray array];
    }
    return _whiteDeleteArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
