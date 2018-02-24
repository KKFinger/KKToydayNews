//
//  KKUserDiggCell.h
//  KKToydayNews
//
//  Created by finger on 2017/10/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKCommentModal.h"

@interface KKUserDiggCell : UITableViewCell
- (void)refreshWithUserInfo:(KKUserInfoNew *)info;
@end
