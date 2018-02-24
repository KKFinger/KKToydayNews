//
//  KKNavigationController.h
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKNavigationController : UINavigationController

@end


@interface UINavigationController (KKNavigationNavUI)

#pragma mark -- 设置导航栏背景色

- (void)setNavBackgroundColor:(UIColor *)color;

@end
