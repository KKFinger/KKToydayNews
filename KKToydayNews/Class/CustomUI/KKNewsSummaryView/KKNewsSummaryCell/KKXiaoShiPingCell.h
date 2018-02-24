//
//  KKXiaoShiPingCell.h
//  KKToydayNews
//
//  Created by finger on 2017/10/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKXiaoShiPingCell : UICollectionViewCell
@property(nonatomic,readonly)UIView *contentBgView;
@property(nonatomic,readonly)UIImageView *corverView;
- (void)refreshWith:(KKSummaryContent *)item;
@end
