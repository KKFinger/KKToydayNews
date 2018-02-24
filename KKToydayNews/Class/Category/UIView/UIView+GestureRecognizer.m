//
//  UIView+GestureRecognizer.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "UIView+GestureRecognizer.h"
#import <objc/runtime.h>

#define UIView_key_tapBlock       "UIView.tapBlock"
#define UITapGesture_key_tapBlock   @"UITapGesture_key_tapBlock"

@implementation UIView(GestureRecognizer)

- (void)addTapGestureWithTarget:(id)target action:(SEL)action{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
}

- (void)removeTapGesture{
    for (UIGestureRecognizer *gesture in self.gestureRecognizers){
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]){
            [self removeGestureRecognizer:gesture];
        }
    }
}

- (void)addTapGestureWithBlock:(void (^)(UIView *gestureView))aBlock;{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
    [self addGestureRecognizer:tap];
    
    objc_setAssociatedObject(self, UIView_key_tapBlock, aBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)actionTap{
    void (^block)(UIView *)  = objc_getAssociatedObject(self, UIView_key_tapBlock);
    if (block){
        block(self);
    }
}

- (void)addTapWithGestureBlock:(void (^)(UITapGestureRecognizer *gesture))aBlock{
    [self addTapWithDelegate:nil gestureBlock:aBlock];
}

- (void)addTapWithDelegate:(id<UIGestureRecognizerDelegate>)delegate gestureBlock:(void (^)(UITapGestureRecognizer *))aBlock {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    tap.delegate = delegate;
    [self addGestureRecognizer:tap];
    objc_setAssociatedObject(self, UITapGesture_key_tapBlock, aBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)actionTap:(UITapGestureRecognizer *)aGesture{
    __weak UITapGestureRecognizer *weakGesture = aGesture;
    void (^block)(UITapGestureRecognizer *)  = objc_getAssociatedObject(self, UITapGesture_key_tapBlock);
    if (block){
        block(weakGesture);
    }
}
@end
