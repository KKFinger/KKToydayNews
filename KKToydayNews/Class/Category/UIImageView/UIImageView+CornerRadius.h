//
//  UIImageView+CornerRadius.h
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView(CornerRadius)

- (void)cornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;

- (void)attachBorderWidth:(CGFloat)width color:(UIColor *)color;

- (void)setCornerImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder;

- (void)setCornerImage:(UIImage *)image;

@end
