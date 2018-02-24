//
//  KKWeiTouTiaoDetailHeader.h
//  KKToydayNews
//
//  Created by finger on 2017/11/11.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKAuthorInfoView.h"

@interface KKWeiTouTiaoDetailHeader : UIView
@property(nonatomic)KKAuthorInfoView *authorView;
- (void)refreshWithItem:(KKSummaryContent *)item callback:(void(^)(CGFloat viewHeight))callback;
@end
