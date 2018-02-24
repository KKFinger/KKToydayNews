//
//  UIScrollView+KKFinger.m
//  KKToydayNews
//
//  Created by finger on 2017/10/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "UIScrollView+KKFinger.h"

@implementation UIScrollView(KKFinger)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if([view isKindOfClass:[UISlider class]]){
        //如果响应view是UISlider,则scrollview禁止滑动
        self.scrollEnabled = NO;
    }else{   //如果不是,则恢复滑动
        self.scrollEnabled = YES;
    }
    return view;
}

@end
