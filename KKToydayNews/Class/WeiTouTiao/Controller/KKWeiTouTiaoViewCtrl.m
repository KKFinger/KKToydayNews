//
//  KKWeiTouTiaoViewCtrl.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKWeiTouTiaoViewCtrl.h"
#import "KKNewsSummaryView.h"

@interface KKWeiTouTiaoViewCtrl ()
@property(nonatomic)KKNewsSummaryView *sumaryView;
@end

@implementation KKWeiTouTiaoViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"微头条";
    self.navigationController.navigationBar.translucent = NO ;
    self.navigationController.navigationBar.borderType = KKBorderTypeBottom;
#if __IPHONE_11_0//xcode9
    if(IOS11_OR_LATER){
        self.navigationController.navigationBar.borderThickness = 0.3 ;
        self.navigationController.navigationBar.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.3];
    }else{
        self.navigationController.navigationBar.borderThickness = 0.1 ;
        self.navigationController.navigationBar.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.1];
    }
#else
    self.navigationController.navigationBar.borderThickness = 0.1 ;
    self.navigationController.navigationBar.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.1];
#endif
    
    [self.view addSubview:self.sumaryView];
    [self.sumaryView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.sumaryView refreshData:YES shouldShowTips:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -- 加载数据

- (void)refreshData{
    [self.sumaryView beginPullDownUpdate];
}

#pragma mark -- @property

- (KKNewsSummaryView *)sumaryView{
    if(!_sumaryView){
        _sumaryView = ({
            KKSectionItem *item = [KKSectionItem new];
            item.category = @"weitoutiao";
            KKNewsSummaryView *view = [[KKNewsSummaryView alloc]initWithSectionItem:item];
            view ;
        });
    }
    return _sumaryView;
}

@end
