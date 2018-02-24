//
//  UIView+GestureRecognizer.h
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(GestureRecognizer)

- (void)addTapGestureWithTarget:(id)target action:(SEL)action;
- (void)addTapGestureWithBlock:(void (^)(UIView *gestureView))aBlock;
- (void)removeTapGesture;
- (void)addTapWithGestureBlock:(void (^)(UITapGestureRecognizer *gesture))aBlock;
- (void)addTapWithDelegate:(id<UIGestureRecognizerDelegate>)delegate gestureBlock:(void (^)(UITapGestureRecognizer *gesture))aBlock;

@end
