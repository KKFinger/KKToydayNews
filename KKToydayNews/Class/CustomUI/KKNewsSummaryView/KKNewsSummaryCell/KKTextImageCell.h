//
//  KKTextImageCell.h
//  KKToydayNews
//
//  Created by finger on 2017/9/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSummaryDataModel.h"

@interface KKTextImageCell : UITableViewCell
@property(nonatomic,weak)id<KKCommonDelegate>delegate;
@property(nonatomic,weak)NSIndexPath *indexPath;
@property(nonatomic,readonly)UIImageView *contentImageView;
+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item ;
- (void)refreshWithItem:(KKSummaryContent *)item ;
@end
