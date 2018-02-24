//
//  KKBaseSummaryView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKNoDataView.h"

@interface KKBaseSummaryView : UIView
@property(nonatomic,weak)UIViewController *parentCtrl;
@property(nonatomic)KKSectionItem *sectionItem ;
@property(nonatomic,readonly)NSMutableArray<KKSummaryContent *> *dataArray;
@property(nonatomic)KKNoDataView *noDataView;
- (id)initWithSectionItem:(KKSectionItem *)item;
- (void)beginPullDownUpdate;//开始下拉刷新
- (void)stopVideoIfNeed;//是否需要移除视频播放
- (void)refreshData:(BOOL)header shouldShowTips:(BOOL)showTip;
@end
