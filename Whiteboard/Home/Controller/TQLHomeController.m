//
//  TQLHomeController.m
//  Whiteboard
//
//  Created by HZW on 2018/6/12.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLHomeController.h"
#import <AVFoundation/AVFoundation.h>
#import "TQLHandwritingListController.h"
#import "TQLSettingController.h"
#import "TQLEditHandwritingController.h"

/** 扫描内容的Y值 */
//#define scanContent_Y self.view.frame.size.height * 0.24
#define scanContent_Y AUTOSCALE_HEIGHT(178.5)
/** 扫描内容的X值 */
//#define scanContent_X self.view.frame.size.width * 0.15
#define scanContent_X AUTOSCALE_WIDTH(57.5)

#define layerBounds  [UIScreen mainScreen].bounds

@interface TQLHomeController ()
<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice *avDevice;//摄像设备
@property (nonatomic, strong) AVCaptureSession *avSession;//输入输出
@property (nonatomic, strong) UIImageView *lineImgView;

@end

@implementation TQLHomeController
#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 44)];
    titleLabel.text = @"扫一扫";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
//    [self setupNavTitleView:titleLabel];
//    [self setupLeftViewClear];
    
    [self judgePower];
    
    //app从后台进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self hideNavigation];
    [self againScan];
}

- (void)dealloc{
    self.avDevice = nil;
    self.avSession = nil;
}

#pragma mark - CustomMethod
//相机权限判断
- (void)judgePower{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (granted) {
                //配置扫描view
                [self loadScanControl];
                [self setLayer];
            } else {
                //无权限
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请在iPhone的”设置-隐私-相机“选项中，允许App访问你的相机" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *sureAtion = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:sureAtion];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }
            
        });
    }];
}

//绘制扫描框layer层
- (void)setLayer{
    //扫码框
    UIImageView *scanView = [[UIImageView alloc] init];
//    scanView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
//    scanView.layer.borderWidth = 0.8;
//    scanView.backgroundColor = [UIColor clearColor];
    scanView.image = IMAGENAME(@"Home_scanCode");
    [self.view addSubview:scanView];
    [scanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(scanContent_X);
        make.right.equalTo(self.view).offset(-scanContent_X);
        make.top.equalTo(self.view).offset(scanContent_Y);
        make.height.equalTo(@(layerBounds.size.width - 2 * scanContent_X));
    }];

    //顶部半透明view
//    UIView *topView = [[UIView alloc] init];
//    topView.backgroundColor = RGBA_COLOR(206, 214, 222, 1);
//    [self.view addSubview:topView];
//    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.view).offset(0);
//        make.top.equalTo(self.view).offset(TOP_MARGIN);
//        make.width.mas_equalTo(self.view.mas_width);
//        make.height.equalTo(@(scanContent_Y - TOP_MARGIN));
//    }];
//
//    //左侧半透明view
//    UIView *leftView = [[UIView alloc] init];
//    leftView.backgroundColor = [RGBA_COLOR(206, 214, 222, 1) colorWithAlphaComponent:0.4];
//    [self.view addSubview:leftView];
//    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view).offset(0);
//        make.width.equalTo(@(scanContent_X));
//        make.top.mas_equalTo(topView.mas_bottom);
//        make.height.mas_equalTo(scanView.mas_height);
//    }];
//
//    //右侧半透明view
//    UIView *rightView = [[UIView alloc] init];
//    rightView.backgroundColor = [RGBA_COLOR(206, 214, 222, 1) colorWithAlphaComponent:0.4];
//    [self.view addSubview:rightView];
//    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(scanView.mas_right);
//        make.width.mas_equalTo(leftView.mas_width);
//        make.top.mas_equalTo(leftView.mas_top);
//        make.height.mas_equalTo(leftView.mas_height);
//    }];
//
//    //底部半透明view
//    UIView *bottomView = [[UIView alloc] init];
//    bottomView.backgroundColor = [RGBA_COLOR(206, 214, 222, 1) colorWithAlphaComponent:0.4];
//    [self.view addSubview:bottomView];
//    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.right.equalTo(self.view).offset(0);
//        make.top.mas_equalTo(scanView.mas_bottom);
//        make.height.equalTo(@(SCREEN_HEIGHT - scanView.height - topView.height - TOP_MARGIN));
//    }];
    
    //提示信息
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor clearColor];
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont boldSystemFontOfSize:12.0];
    promptLabel.textColor = [UIColor whiteColor];
    promptLabel.text = @"请对准需要识别的二维码";
    [self.view addSubview:promptLabel];
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).offset(0);
        make.top.mas_equalTo(scanView.mas_bottom).offset(AUTOSCALE_HEIGHT(27));
        make.height.equalTo(@(AUTOSCALE_HEIGHT(20)));
    }];
    
    //添加line
//    self.lineImgView = [[UIImageView alloc] init];
//    self.lineImgView.image = IMAGENAME(@"QRCodeScanningLine");
//    [self.view addSubview:self.lineImgView];
//    [self.lineImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(scanView.mas_left);
//        make.right.mas_equalTo(scanView.mas_right);
//        make.width.mas_equalTo(scanView.mas_width);
//        make.top.mas_equalTo(scanView.mas_top);
//        make.height.equalTo(@(AUTOSCALE_HEIGHT(5)));
//    }];
    
    // line移动的范围为 一个扫码框的高度(由于图片问题再减去图片的高度)
//    CABasicAnimation * lineAnimation = [self animationWith:@(0) toValue:@(layerBounds.size.width - 2 * scanContent_X - 1) repCount:MAXFLOAT duration:1.5f];
//    [self.lineImgView.layer addAnimation:lineAnimation forKey:@"LineImgViewAnimation"];
    
    //文档按钮
    UIButton *fileButton = [[UIButton alloc] init];
    fileButton.backgroundColor = [UIColor clearColor];
    [fileButton setImage:IMAGENAME(@"Home_file") forState:UIControlStateNormal];
    [fileButton setTitle:@"文档" forState:UIControlStateNormal];
    [fileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    fileButton.titleLabel.font = [UIFont systemFontOfSize:12];
//    fileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [fileButton setTitleEdgeInsets:UIEdgeInsetsMake(fileButton.titleLabel.frame.size.height + 40, -fileButton.imageView.frame.size.width - fileButton.titleLabel.frame.size.width, 0, 0)];
    [fileButton setImageEdgeInsets:UIEdgeInsetsMake(0,0, fileButton.titleLabel.intrinsicContentSize.height, -fileButton.titleLabel.intrinsicContentSize.width)];
    fileButton.tag = 100;
    [fileButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fileButton];
    [fileButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(AUTOSCALE_WIDTH(24));
        make.bottom.equalTo(self.view).offset(-AUTOSCALE_HEIGHT(19));
        make.width.equalTo(@(AUTOSCALE_WIDTH(41)));
        make.height.equalTo(@(AUTOSCALE_HEIGHT(45)));
    }];
    
    //设置按钮
    UIButton *settingButton = [[UIButton alloc] init];
    settingButton.backgroundColor = [UIColor clearColor];
    [settingButton setImage:IMAGENAME(@"Home_setting") forState:UIControlStateNormal];
    [settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [settingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    settingButton.titleLabel.font = [UIFont systemFontOfSize:12];
//    settingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [settingButton setTitleEdgeInsets:UIEdgeInsetsMake(settingButton.titleLabel.frame.size.height + 40, -settingButton.imageView.frame.size.width - settingButton.titleLabel.frame.size.width, 0, 0)];
    [settingButton setImageEdgeInsets:UIEdgeInsetsMake(0,0, settingButton.titleLabel.intrinsicContentSize.height, -settingButton.titleLabel.intrinsicContentSize.width)];
    settingButton.tag = 101;
    [settingButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:settingButton];
    [settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-AUTOSCALE_WIDTH(10));
        make.bottom.mas_equalTo(fileButton.mas_bottom);
        make.width.mas_equalTo(fileButton.mas_width);
        make.height.mas_equalTo(fileButton.mas_height);
    }];
}

//创建扫描控件
- (void)loadScanControl {
    
    //获取摄像设备
    self.avDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.avDevice error:nil];
    
    //创建输出流
    AVCaptureMetadataOutput *metdataOutput = [[AVCaptureMetadataOutput alloc] init];
    //设置代理 在主线程刷新
    [metdataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫码框作用范围 (由于扫码时系统默认横屏关系, 导致作用框原点变为我们绘制的框的右上角,而不是左上角) 且参数为比率不是像素点
    metdataOutput.rectOfInterest = CGRectMake(scanContent_Y / layerBounds.size.height, scanContent_X / layerBounds.size.width, (layerBounds.size.width - 2 * scanContent_X)/layerBounds.size.height, (layerBounds.size.width - 2 * scanContent_X) / layerBounds.size.width);
    
    //初始化连接对象
    self.avSession = [[AVCaptureSession alloc] init];
    //设置高质量采集率
    [self.avSession setSessionPreset:AVCaptureSessionPresetHigh];
    //组合
    [self.avSession addInput:input];
    [self.avSession addOutput:metdataOutput];
    
    
    //设置扫码格式支持的码(一定要在 session 添加 addOutput之后再设置 否则会崩溃)
    metdataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    //展示layer
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.avSession];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    
    [self.avSession startRunning];
    
}

//扫描线动画
- (CABasicAnimation*)animationWith:(id)fromValue toValue:(id)toValue repCount:(CGFloat)repCount duration:(CGFloat)duration{
    
    CABasicAnimation *lineAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    lineAnimation.fromValue = fromValue;
    lineAnimation.toValue = toValue;
    lineAnimation.repeatCount = repCount;
    lineAnimation.duration = duration;
    lineAnimation.fillMode = kCAFillModeForwards;
    lineAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return lineAnimation;
    
}

//移除动画
- (void)removeAnimationAboutScan{
    
    [self.lineImgView.layer removeAnimationForKey:@"LineImgViewAnimation"];
//    self.lineImgView.hidden = YES;
}

//重新开始扫描
- (void)againScan{
    [self.avSession startRunning];
    CABasicAnimation * lineAnimation = [self animationWith:@(0) toValue:@(layerBounds.size.width - 2 * scanContent_X - 1) repCount:MAXFLOAT duration:1.5f];
    [self.lineImgView.layer addAnimation:lineAnimation forKey:@"LineImgViewAnimation"];
}

//从后台进入前台
- (void)applicationBecomeActive{
    [self againScan];
}

#pragma mark - ClickMethod
- (void)btnClick:(UIButton *)btn{
    if (btn.tag == 100) {
        //文档
        TQLHandwritingListController *vc = [[TQLHandwritingListController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (btn.tag == 101){
        //设置
        TQLSettingController *vc = [[TQLSettingController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - SystemDelegate

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    //获取数据
    AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
    NSLog(@"扫描到的数据是%@",metadataObj.stringValue);
    //解析
    NSArray *tempArray = [metadataObj.stringValue componentsSeparatedByString:@";"];
    NSArray *IPArray = [tempArray[0] componentsSeparatedByString:@":"];
    NSArray *portArray = [tempArray[1] componentsSeparatedByString:@":"];
    NSString *IPStr = IPArray[1];
    NSString *portStr = portArray[1];
    
    //停止扫描
    [self.avSession stopRunning];
    
    //取消line动画
    [self removeAnimationAboutScan];
    
    TQLEditHandwritingController *vc = [[TQLEditHandwritingController alloc] init];
    vc.host = IPStr;
    vc.port = [portStr integerValue];
    vc.pushType = 0;
    vc.pageID = 0;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - CustomDelegate

#pragma mark - GetterAndSetter


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
