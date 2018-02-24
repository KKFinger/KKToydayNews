//
//  KKDetialHeadView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/23.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKAuthorInfoView.h"

@interface KKDetialHeadView : UIView
@property(nonatomic)KKAuthorInfoView *authorView;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)void(^shouldAdjustHeight)(CGFloat height);
@end
