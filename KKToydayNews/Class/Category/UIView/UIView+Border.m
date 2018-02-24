//
//  UIView+Border.m
//  KKToydayNews
//
//  Created by finger on 2017/10/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "UIView+Border.h"
#import <objc/runtime.h>

static char borderColorKey;
static char borderTypeKey;
static char borderThicknessKey;
static char topBorderKey;
static char leftBorderKey;
static char rightBorderKey;
static char bottomBorderKey;

@interface UIView()
@property(nonatomic,strong)UIView *topBorder;
@property(nonatomic,strong)UIView *leftBorder;
@property(nonatomic,strong)UIView *rightBorder;
@property(nonatomic,strong)UIView *bottomBorder;
@end

@implementation UIView(Border)

- (void)layoutSubviews{
    if (self.borderType == KKBorderTypeAll) {
        self.layer.borderWidth = self.borderThickness;
        self.layer.borderColor = self.borderColor.CGColor;
        return;
    }
    
    //left
    if (self.borderType & KKBorderTypeLeft) {
        if(self.leftBorder ==nil || self.leftBorder.superview == nil){
            self.leftBorder = [UIView new];
            [self addSubview:self.leftBorder];
        }
        self.leftBorder.frame = CGRectMake(0, 0, self.borderThickness, self.frame.size.height);
        self.leftBorder.backgroundColor = self.borderColor;
        [self bringSubviewToFront:self.leftBorder];
    }
    //right
    if (self.borderType & KKBorderTypeRight) {
        if(self.rightBorder ==nil || self.rightBorder.superview == nil){
            self.rightBorder = [UIView new];
            [self addSubview:self.rightBorder];
        }
        self.rightBorder.frame = CGRectMake(self.frame.size.width - self.borderThickness, 0, self.borderThickness, self.frame.size.height);
        self.rightBorder.backgroundColor = self.borderColor;
        [self bringSubviewToFront:self.rightBorder];
    }
    //top
    if (self.borderType & KKBorderTypeTop) {
        if(self.topBorder ==nil || self.topBorder.superview == nil){
            self.topBorder = [UIView new];
            [self addSubview:self.topBorder];
        }
        self.topBorder.frame = CGRectMake(0, 0, self.frame.size.width, self.borderThickness);
        self.topBorder.backgroundColor = self.borderColor;
        [self bringSubviewToFront:self.topBorder];
    }
    //bottom
    if (self.borderType & KKBorderTypeBottom) {
        if(self.bottomBorder ==nil || self.bottomBorder.superview == nil){
            self.bottomBorder = [UIView new];
            [self addSubview:self.bottomBorder];
        }
        self.bottomBorder.frame = CGRectMake(0, self.frame.size.height - self.borderThickness, self.frame.size.width, self.borderThickness);
        self.bottomBorder.backgroundColor = self.borderColor;
        [self bringSubviewToFront:self.bottomBorder];
    }
}

#pragma mark -- rumtime

-(void)setBorderColor:(UIColor *)borderColor{
    if (borderColor) {
        objc_setAssociatedObject(self, &borderColorKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &borderColorKey, borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(UIColor *)borderColor{
    UIColor *color = objc_getAssociatedObject(self, &borderColorKey);
    if(!color){
       self.borderColor = [UIColor clearColor];
    }
    return color;
}

- (void)setBorderType:(KKBorderType)borderType{
    objc_setAssociatedObject(self, &borderTypeKey, [NSNumber numberWithInteger:borderType], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KKBorderType)borderType{
    return (KKBorderType)[(NSNumber *)objc_getAssociatedObject(self, &borderTypeKey) integerValue];
}

- (void)setBorderThickness:(CGFloat)borderThickness{
    objc_setAssociatedObject(self, &borderThicknessKey, [NSNumber numberWithFloat:borderThickness], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)borderThickness{
    return [(NSNumber *)objc_getAssociatedObject(self, &borderThicknessKey) floatValue];
}

-(void)setTopBorder:(UIView *)topBorder{
    if (topBorder) {
        objc_setAssociatedObject(self, &topBorderKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &topBorderKey, topBorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(UIView *)topBorder{
    return objc_getAssociatedObject(self, &topBorderKey);
}

-(void)setLeftBorder:(UIView *)leftBorder{
    if (leftBorder) {
        objc_setAssociatedObject(self, &leftBorderKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &leftBorderKey, leftBorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(UIView *)leftBorder{
    return objc_getAssociatedObject(self, &leftBorderKey);
}

-(void)setRightBorder:(UIView *)rightBorder{
    if (rightBorder) {
        objc_setAssociatedObject(self, &rightBorderKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &rightBorderKey, rightBorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(UIView *)rightBorder{
    return objc_getAssociatedObject(self, &rightBorderKey);
}

-(void)setBottomBorder:(UIView *)bottomBorder{
    if (bottomBorder) {
        objc_setAssociatedObject(self, &bottomBorderKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &bottomBorderKey, bottomBorder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(UIView *)bottomBorder{
    return objc_getAssociatedObject(self, &bottomBorderKey);
}

@end
