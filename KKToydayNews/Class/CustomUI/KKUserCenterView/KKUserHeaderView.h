//
//  KKUserHeaderView.h
//  KKToydayNews
//
//  Created by finger on 2017/12/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKUserHeaderViewDelegate <NSObject>
@optional
- (void)backController;
@end

@interface KKUserHeaderView : UIView
@property(nonatomic,weak)id<KKUserHeaderViewDelegate>delegate;
@end
