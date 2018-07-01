//
//  KKNewsCommonCell.h
//  KKToydayNews
//
//  Created by finger on 2017/9/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSummaryDataModel.h"
#import "TYAttributedLabel.h"

#define newsTipBtnHeight 15
#define descLabelHeight 20
#define leftBtnSize CGSizeMake(20,11)

@interface KKNewsCommonCell : UITableViewCell
@property(nonatomic,strong)UIView *bgView;
@property(nonatomic,strong)TYAttributedLabel *titleLabel;
@property(nonatomic,strong)UIButton *leftBtn;
@property(nonatomic,strong)UIButton *newsTipBtn;
@property(nonatomic,strong)UILabel *descLabel;
@property(nonatomic,strong)UIButton *shieldBtn;
@property(nonatomic,strong)UIView *splitView;
@property(nonatomic,strong)UIButton *playVideoBtn;

@property(nonatomic,weak)KKSummaryContent *item;
@property(nonatomic,weak)id<KKCommonDelegate>delegate;

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item ;
- (void)refreshWithItem:(KKSummaryContent *)item ;
//计算视频时间字符、图片个数字符等宽度
- (CGFloat)fetchNewsTipWidth;

@end
