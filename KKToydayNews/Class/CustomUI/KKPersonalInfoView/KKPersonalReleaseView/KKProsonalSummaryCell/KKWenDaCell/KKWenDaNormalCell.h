//
//  KKWenDaNormalCell.h
//  KKToydayNews
//
//  Created by finger on 2017/12/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPersonalWenDaModel.h"

@interface KKWenDaNormalCell : UITableViewCell
+ (CGFloat)fetchHeightWithQAModal:(KKPersonalQAModel *)modal;
- (void)refreshWithQAModal:(KKPersonalQAModel *)modal;
@end
