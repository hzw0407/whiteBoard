//
//  TQLSettingController.m
//  Whiteboard
//
//  Created by HZW on 2018/6/13.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLSettingController.h"
#import "TQLSettingCell.h"
#import "TQLSettingModel.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface TQLSettingController ()
<UITableViewDelegate,
UITableViewDataSource>

@property (nonatomic, strong) UIView *navigationView;//导航栏view
@property (nonatomic, strong) UIImageView *imageBackgroundView;//背景图
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *equipmentArray;//白板设备数组
@property (nonatomic, strong) UIView *headView;//表头
@property (nonatomic, strong) UIButton *connectButton;//断开、连接按钮

@end

@implementation TQLSettingController
#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor mainColor];
    [self setupNavTitle:@"设置"];
    
    [self.view addSubview:self.imageBackgroundView];
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.headView;
    [self.view addSubview:self.connectButton];
    
    TQLSettingModel *model = [[TQLSettingModel alloc] init];
    model.connectStatus = 1;
    model.macAddress = @"(192.168.168.136)";
    [self.equipmentArray addObject:model];
    
}

- (void)dealloc{
    
}

#pragma mark - CustomMethod

#pragma mark - ClickMethod
- (void)btnClick:(UIButton *)btn{
    if (btn.tag == 100) {
        //返回
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//修改签名
- (void)modifySign{
    UIAlertController *alertCntroller = [UIAlertController alertControllerWithTitle:@"编辑签名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style: UIAlertActionStyleCancel handler:nil];
    [alertCntroller addAction:cancelAction];
    
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = alertCntroller.textFields[0];
        UILabel *autographLabel = (UILabel *)[self.headView viewWithTag:200];
        autographLabel.text = textField.text;
        
    }];
    [alertCntroller addAction:sureAction];
    
    [alertCntroller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    [self presentViewController:alertCntroller animated:YES completion:nil];
}

//断开、连接白板
- (void)clickConnect{
    
}

#pragma mark - SystemDelegate

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TQLSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[TQLSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    TQLSettingModel *model = self.equipmentArray[indexPath.row];
    [cell refreshWithModel:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return AUTOSCALE_HEIGHT(70);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - CustomDelegate

#pragma mark - GetterAndSetter
- (UIImageView *)imageBackgroundView{
    if (!_imageBackgroundView) {
        _imageBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, AUTOSCALE_HEIGHT(183))];
        _imageBackgroundView.image = IMAGENAME(@"Setting_Background");
    }
    return _imageBackgroundView;
}

- (UIView *)navigationView{
    if (!_navigationView) {
        _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TOP_MARGIN)];
        
        //返回按钮
        UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(AUTOSCALE_WIDTH(10), IS_IPHONE_X ? 44 : 20, 44, 44)];
        [leftButton setImage:IMAGENAME(@"default_return") forState:UIControlStateNormal];
        leftButton.tag = 100;
        [leftButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_navigationView addSubview:leftButton];
        
        //标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, IS_IPHONE_X ? 44 : 20, SCREEN_WIDTH, 44)];
        titleLabel.text = @"设置";
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.tag = 101;
        [_navigationView addSubview:titleLabel];
        
    }
    return _navigationView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TOP_MARGIN, SCREEN_WIDTH, SCREEN_HEIGHT -TOP_MARGIN) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray *)equipmentArray{
    if (!_equipmentArray) {
        _equipmentArray = [NSMutableArray array];
    }
    return _equipmentArray;
}

- (UIView *)headView{
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, AUTOSCALE_HEIGHT(283))];
        _headView.backgroundColor = [UIColor clearColor];
        _headView.userInteractionEnabled = YES;
        
        //图片
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = IMAGENAME(@"Setting_Icon");
        [_headView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self->_headView.mas_centerX);
            make.top.equalTo(self->_headView).offset(AUTOSCALE_HEIGHT(17.5));
            make.width.equalTo(@(AUTOSCALE_WIDTH(110)));
            make.height.equalTo(@(AUTOSCALE_WIDTH(110)));
        }];
        
        //签名
        UILabel *signLabel = [[UILabel alloc] init];
        signLabel.text = @"签名";
        signLabel.textColor = [UIColor blackColor];
        signLabel.font = [UIFont systemFontOfSize:14];
        [_headView addSubview:signLabel];
        [signLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->_headView).offset(AUTOSCALE_WIDTH(28));
            make.top.mas_equalTo(imageView.mas_bottom).offset(AUTOSCALE_HEIGHT(36));
            make.width.equalTo(@(AUTOSCALE_WIDTH(30)));
            make.height.equalTo(@(AUTOSCALE_HEIGHT(20)));
        }];
        
        UIImageView *autographImageView = [[UIImageView alloc] init];
        autographImageView.image = IMAGENAME(@"Setting_Sign");
        [_headView addSubview:autographImageView];
        [autographImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->_headView).offset(AUTOSCALE_WIDTH(32));
            make.top.mas_equalTo(signLabel.mas_bottom).offset(AUTOSCALE_HEIGHT(12.5));
            make.width.equalTo(@(AUTOSCALE_WIDTH(18.5)));
            make.height.equalTo(@(AUTOSCALE_WIDTH(18.5)));
        }];

        UILabel *autographLabel = [[UILabel alloc] init];
        autographLabel.text = @"匿名";
        autographLabel.font = [UIFont systemFontOfSize:15];
        autographLabel.textColor = [UIColor blackColor];
        autographLabel.textAlignment = NSTextAlignmentCenter;
        autographLabel.tag = 200;
        [_headView addSubview:autographLabel];
        [autographLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(signLabel.mas_right).offset(0);
            make.right.equalTo(self->_headView).offset(-AUTOSCALE_WIDTH(32));
            make.top.mas_equalTo(autographImageView.mas_top);
            make.height.mas_equalTo(signLabel.mas_height);
        }];
        
        UIView *tapView = [[UIView alloc] init];
        tapView.backgroundColor = [UIColor clearColor];
        tapView.userInteractionEnabled = YES;
        [_headView addSubview:tapView];
        [tapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(autographLabel.mas_left).offset(0);
            make.right.mas_equalTo(autographLabel.mas_right).offset(0);
            make.top.mas_equalTo(autographLabel.mas_top).offset(0);
            make.width.mas_equalTo(autographLabel.mas_width);
            make.height.mas_equalTo(autographLabel.mas_height);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modifySign)];
        [tapView addGestureRecognizer:tap];
        
        //横线
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor lineColor];
        [_headView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->_headView).offset(AUTOSCALE_WIDTH(28));
            make.right.equalTo(self->_headView).offset(-AUTOSCALE_WIDTH(28));
            make.top.mas_equalTo(tapView.mas_bottom).offset(AUTOSCALE_HEIGHT(14));
            make.height.equalTo(@(1));
        }];
        
        //连接状态
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = @"白板";
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [_headView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->_headView).offset(AUTOSCALE_WIDTH(28));
            make.top.mas_equalTo(lineView.mas_bottom).offset(AUTOSCALE_HEIGHT(34));
            make.width.equalTo(@(AUTOSCALE_WIDTH(30)));
            make.height.equalTo(@(AUTOSCALE_HEIGHT(20)));
        }];
        
        UILabel *statusLabel = [[UILabel alloc] init];
        statusLabel.text = @"已连接";
        statusLabel.textColor = [UIColor textColor];
        statusLabel.font = [UIFont systemFontOfSize:11];
        statusLabel.textAlignment = NSTextAlignmentRight;
        [_headView addSubview:statusLabel];
        [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self->_headView).offset(-AUTOSCALE_WIDTH(36));
            make.top.mas_equalTo(lineView.mas_bottom).offset(AUTOSCALE_HEIGHT(36));
            make.width.equalTo(@(AUTOSCALE_WIDTH(50)));
            make.height.equalTo(@(AUTOSCALE_HEIGHT(20)));
        }];
        
    }
    return _headView;
}

- (UIButton *)connectButton{
    if (!_connectButton) {
        _connectButton = [[UIButton alloc] initWithFrame:CGRectMake(AUTOSCALE_WIDTH(25), SCREEN_HEIGHT - AUTOSCALE_HEIGHT(50), SCREEN_WIDTH - AUTOSCALE_WIDTH(50), AUTOSCALE_HEIGHT(35))];
        _connectButton.layer.cornerRadius = CORNRRRADIUS;
        _connectButton.backgroundColor = RGB_COLOR(78, 120, 255);
        [_connectButton setTitle:@"断开连接" forState:UIControlStateNormal];
        [_connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _connectButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_connectButton addTarget:self action:@selector(clickConnect) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_connectButton];
    }
    return _connectButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
