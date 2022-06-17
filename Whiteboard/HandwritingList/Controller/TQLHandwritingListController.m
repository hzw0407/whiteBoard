//
//  TQLHandwritingListController.m
//  Whiteboard
//
//  Created by HZW on 2018/6/13.
//  Copyright © 2018年 HZW. All rights reserved.
//

#import "TQLHandwritingListController.h"
#import "TQLHandwritingListCell.h"
#import "TQLHandwritingListModel.h"
#import "TQLEditHandwritingController.h"
#import "TQLFMDBManager.h"

@interface TQLHandwritingListController ()
<UICollectionViewDelegate,
UICollectionViewDataSource,
TQLHandwritingListCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;//源数据数组
@property (nonatomic, strong) UIView *noDataView;//没有数据时view
@property (nonatomic, strong) TQLFMDBManager *FMDBManager;

@end

@implementation TQLHandwritingListController
#pragma mark - lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor mainColor];
    [self setupNavTitle:@"会议笔迹"];
    
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.collectionView];
    
    self.FMDBManager = [TQLFMDBManager shareFMDBManager];
    [self.FMDBManager creatTable:handwritingList];
    
    self.dataArray = [NSMutableArray arrayWithArray:[self.FMDBManager FMDBSearchAll:handwritingList]];
    if (self.dataArray.count > 0) {
        self.collectionView.hidden = NO;
        [self.collectionView reloadData];
        self.noDataView.hidden = YES;
    }else{
        self.noDataView.hidden = NO;
        self.collectionView.hidden = YES;
    }
    
}

- (void)dealloc{
    self.collectionView = nil;
    self.dataArray = nil;
    self.noDataView = nil;
    self.FMDBManager = nil;
}

#pragma mark - CustomMethod

#pragma mark - ClickMethod

#pragma mark - SystemDelegate

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TQLHandwritingListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    TQLHandwritingListModel *model = self.dataArray[indexPath.row];
    [cell refreshWithModel:model withIndexPath:indexPath];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((SCREEN_WIDTH - AUTOSCALE_WIDTH(30)) / 2, AUTOSCALE_HEIGHT(245));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(AUTOSCALE_HEIGHT(15), AUTOSCALE_WIDTH(10), 0, AUTOSCALE_WIDTH(10));
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    TQLEditHandwritingController *vc = [[TQLEditHandwritingController alloc] init];
    TQLHandwritingListModel *model = self.dataArray[indexPath.row];
    vc.host = @"192.168.168.245";
    vc.port = 5000;
    vc.pushType = 1;
    vc.pageID = model.pageID;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - CustomDelegate

#pragma mark - TQLHandwritingListCellDelegate
//- (void)clickEdit:(NSInteger)index{
//    NSLog(@"点击的是%zd个cell",index);
//}

#pragma mark - GetterAndSetter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView.hidden = YES;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //滚动方向
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, TOP_MARGIN, SCREEN_WIDTH, SCREEN_HEIGHT - TOP_MARGIN) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor mainColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[TQLHandwritingListCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

//- (NSMutableArray *)dataArray{
//    if (!_dataArray) {
//        _dataArray = [NSMutableArray array];
//    }
//    return _dataArray;
//}

- (UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_MARGIN, SCREEN_WIDTH, SCREEN_HEIGHT - TOP_MARGIN)];
        _noDataView.backgroundColor = [UIColor clearColor];
        _noDataView.hidden = YES;
        
        //图片
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = IMAGENAME(@"HandwritingList_Nodata");
        [_noDataView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->_noDataView).offset(AUTOSCALE_WIDTH(126.5));
            make.right.equalTo(self->_noDataView).offset(-AUTOSCALE_WIDTH(126.5));
            make.top.equalTo(self->_noDataView).offset(AUTOSCALE_HEIGHT(76.5));
            make.height.equalTo(@(AUTOSCALE_HEIGHT(194.5)));
        }];
        
        //提示文字
        UILabel *topTipLabel = [[UILabel alloc] init];
        topTipLabel.text = @"尚无会议笔迹";
        topTipLabel.textColor = [UIColor colorWithHexString:@"#6d6d6d"];
        topTipLabel.font = [UIFont systemFontOfSize:21];
        topTipLabel.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:topTipLabel];
        [topTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self->_noDataView).offset(0);
            make.top.mas_equalTo(imageView.mas_bottom).offset(AUTOSCALE_HEIGHT(63));
            make.height.equalTo(@(AUTOSCALE_HEIGHT(20)));
        }];
        
        UIButton *bottomTipButtonl = [[UIButton alloc] init];
        bottomTipButtonl.backgroundColor =RGB_COLOR(78, 120, 255);
        bottomTipButtonl.layer.cornerRadius = 10;
        [bottomTipButtonl setTitle:@"连接Meeting kaap共享白板笔迹" forState:UIControlStateNormal];
        [bottomTipButtonl setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        bottomTipButtonl.titleLabel.font = [UIFont systemFontOfSize:16];
        [_noDataView addSubview:bottomTipButtonl];
        [bottomTipButtonl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self->_noDataView).offset(AUTOSCALE_WIDTH(21.5));
            make.right.equalTo(self->_noDataView).offset(-AUTOSCALE_WIDTH(21.5));
            make.top.mas_equalTo(topTipLabel.mas_bottom).offset(AUTOSCALE_HEIGHT(42));
            make.height.equalTo(@(AUTOSCALE_HEIGHT(40)));
        }];
        
    }
    return _noDataView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
