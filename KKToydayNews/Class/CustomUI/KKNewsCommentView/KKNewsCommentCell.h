//
//  KKNewsCommentCell.h
//  KKToydayNews
//
//  Created by finger on 2017/9/21.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKCommentModal.h"

@interface KKNewsCommentCell : UITableViewCell
@property(nonatomic,weak)id<KKCommentDelegate>delegate;
- (void)refreshWithItem:(KKCommentItem *)item;
- (void)refreshWithObj:(KKCommentObj *)obj;
+ (CGFloat)fetchHeightWithItem:(KKCommentItem *)item;
+ (CGFloat)fetchHeightWithObj:(KKCommentObj *)obj;
@end
