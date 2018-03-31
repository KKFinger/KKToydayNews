//
//  UITableViewCell+Animate.m
//  KKToydayNews
//
//  Created by KKFinger on 2018/3/31.
//  Copyright © 2018年 finger. All rights reserved.
//

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

#import "UITableViewCell+Animate.h"

@implementation UITableViewCell(Animate)

//cell飞进飞出效果
- (void)flyInOutAnimateForIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    float radians = (120 + row*30)%360;
    radians = 20;
    CALayer *layer = [[self.layer sublayers] objectAtIndex:0];
    
    // Rotation Animation
    CABasicAnimation *animation  = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    animation.fromValue =@DEGREES_TO_RADIANS(radians);
    animation.toValue = @DEGREES_TO_RADIANS(0);
    
    // Opacity Animation;
    CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @0.1f;
    fadeAnimation.toValue = @1.f;
    
    // Translation Animation
    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    ;
    translationAnimation.fromValue = @(-300.f * ((indexPath.row%2 == 0) ? -1: 1));
    translationAnimation.toValue = @0.f;
    
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 0.4f;
    animationGroup.animations = @[animation,fadeAnimation,translationAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [layer addAnimation:animationGroup forKey:@"spinAnimation"];
}

@end
