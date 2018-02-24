//
//  KKTabBar.h
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKTabBar;
@protocol KKTabBarDelegate <NSObject>
@optional
- (void)tabBarMidBtnClick:(KKTabBar *)tabBar;
@end

@interface KKTabBar : UITabBar
@property (nonatomic, weak) id<KKTabBarDelegate> kkTabDelegate ;
@end
