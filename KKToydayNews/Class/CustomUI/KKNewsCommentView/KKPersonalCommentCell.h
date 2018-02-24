//
//  KKPersonalCommentCell.h
//  KKToydayNews
//
//  Created by finger on 2017/10/1.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKUserCommentDetail.h"

@interface KKPersonalCommentCell : UITableViewCell
@property(nonatomic,weak)id<KKCommentDelegate>delegate;
- (void)refreshWithUserComment:(KKUserCommentDetail *)userComment userDigg:(KKCommentDigg *)userDigg;
+ (CGFloat)fetchHeightWithUserComment:(KKUserCommentDetail *)userComment;
@end
