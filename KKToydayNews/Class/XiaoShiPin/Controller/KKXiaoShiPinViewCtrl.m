//
//  KKXiaoShiPinViewCtrl.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKXiaoShiPinViewCtrl.h"
#import "KKXiaoShiPingSummaryView.h"

@interface KKXiaoShiPinViewCtrl ()
@property(nonatomic)KKXiaoShiPingSummaryView *sumaryView;
@end

@implementation KKXiaoShiPinViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self.view addSubview:self.sumaryView];
    [self.sumaryView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(KKStatusBarHeight);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
    [self.sumaryView refreshData:YES shouldShowTips:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark -- 加载数据

- (void)refreshData{
    [self.sumaryView beginPullDownUpdate];
}

#pragma park -- @property

- (KKXiaoShiPingSummaryView *)sumaryView{
    if(!_sumaryView){
        _sumaryView = ({
            KKSectionItem *item = [KKSectionItem new];
            item.category = @"hotsoon_video";
            KKXiaoShiPingSummaryView *view = [[KKXiaoShiPingSummaryView alloc]initWithSectionItem:item];
            view ;
        });
    }
    return _sumaryView;
}

@end
