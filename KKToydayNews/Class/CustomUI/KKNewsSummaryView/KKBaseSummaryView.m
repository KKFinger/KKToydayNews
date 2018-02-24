//
//  KKBaseSummaryView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKBaseSummaryView.h"

@interface KKBaseSummaryView ()
@property(nonatomic,readwrite)NSMutableArray<KKSummaryContent *> *dataArray;
@end

@implementation KKBaseSummaryView

- (id)initWithSectionItem:(KKSectionItem *)item{
    self = [super init];
    if(self){
    }
    return self ;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

- (void)beginPullDownUpdate{
    
}

- (void)stopVideoIfNeed{
    
}

- (void)refreshData:(BOOL)header shouldShowTips:(BOOL)showTip{
    
}

- (NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (KKNoDataView *)noDataView{
    if(!_noDataView){
        _noDataView = ({
            KKNoDataView *view = [KKNoDataView new];
            view.tipImage = [UIImage imageNamed:@"not_found_loading_226x119_"];
            view.tipText = @"在这个星球找不到你需要的信息";
            view.hidden = YES ;
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _noDataView;
}

@end
