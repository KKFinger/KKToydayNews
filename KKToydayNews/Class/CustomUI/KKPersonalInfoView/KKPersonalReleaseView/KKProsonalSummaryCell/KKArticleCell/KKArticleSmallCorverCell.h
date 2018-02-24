//
//  KKArticleSmallCorverCell.h
//  KKToydayNews
//
//  Created by finger on 2017/9/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKNewsCommonCell.h"
#import "KKPersonalArticalModel.h"

@interface KKArticleSmallCorverCell : KKNewsCommonCell
- (void)refreshWithSummary:(KKPersonalSummary *)item;
+ (CGFloat)fetchHeightWithSummary:(KKPersonalSummary *)item;
@end
