//
//  KKVideoCell.h
//  KKToydayNews
//
//  Created by finger on 2017/9/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSummaryDataModel.h"

@interface KKVideoCell : UITableViewCell

@property(nonatomic,weak)id<KKCommonDelegate>delegate;
@property(nonatomic,strong,readonly)UIView *contentMaskView;
@property(nonatomic,assign,readonly)CGRect imageViewFrame;

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item ;
- (void)refreshWithItem:(KKSummaryContent *)item ;
//计算视频时间字符、图片个数字符等宽度
- (CGFloat)fetchNewsTipWidth;

@end
