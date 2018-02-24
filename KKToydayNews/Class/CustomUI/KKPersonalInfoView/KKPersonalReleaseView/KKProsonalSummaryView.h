//
//  KKProsonalSummaryView.h
//  KKToydayNews
//
//  Created by finger on 2017/11/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPersonalModel.h"

@interface KKProsonalSummaryView : UIView
@property(nonatomic)BOOL canScroll;
@property(nonatomic,copy)void(^canScrollCallback)(BOOL canScroll);
- (instancetype)initWithTopic:(KKPersonalTopic *)topic userId:(NSString *)userId mediaId:(NSString *)mediaId;
@end
