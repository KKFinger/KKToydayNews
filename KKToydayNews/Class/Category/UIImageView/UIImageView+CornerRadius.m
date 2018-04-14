//
//  UIImageView+CornerRadius.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "UIImageView+CornerRadius.h"
#import <objc/runtime.h>

const char kRadius;
const char kRoundingCorners;
const char kProcessedImage;

const char kBorderWidth;
const char kBorderColor;

@interface UIImageView ()
@property (assign, nonatomic) CGFloat radius;
@property (assign, nonatomic) UIRectCorner roundingCorners;
@property (assign, nonatomic) CGFloat borderWidth;
@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) BOOL firstReader;
@end


@implementation UIImageView (CornerRadius)

/**
 * @brief attach border for UIImageView with width & color
 */
- (void)attachBorderWidth:(CGFloat)width color:(UIColor *)color {
    self.borderWidth = width;
    self.borderColor = color;
}

/**
 * @brief set cornerRadius for UIImageView, no off-screen-rendered
 */
- (void)cornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType {
    self.radius = cornerRadius;
    self.roundingCorners = rectCornerType;
}

#pragma mark - Kernel
/**
 * @brief clip the cornerRadius with image, UIImageView must be setFrame before, no off-screen-rendered
 */
- (void)cornerRadiusWithImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType {
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cornerRadii = CGSizeMake(cornerRadius, cornerRadius);

    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    if (nil == UIGraphicsGetCurrentContext()) {
        return ;
    }

    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCornerType cornerRadii:cornerRadii];
    [cornerPath addClip];
    [image drawInRect:self.bounds];
    if (image != nil) {
        [self drawBorder:cornerPath];
    }
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    objc_setAssociatedObject(processedImage, &kProcessedImage, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.image = processedImage;
}

/**
 * @brief clip the cornerRadius with image, draw the backgroundColor you want, UIImageView must be setFrame before, no off-screen-rendered, no Color Blended layers
 */
- (void)cornerRadiusWithImage:(UIImage *)image cornerRadius:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType backgroundColor:(UIColor *)backgroundColor {
    CGSize size = self.bounds.size;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cornerRadii = CGSizeMake(cornerRadius, cornerRadius);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    if (nil == UIGraphicsGetCurrentContext()) {
        return;
    }
    
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCornerType cornerRadii:cornerRadii];
    UIBezierPath *backgroundRect = [UIBezierPath bezierPathWithRect:self.bounds];
    [backgroundColor setFill];
    [backgroundRect fill];
    [cornerPath addClip];
    [image drawInRect:self.bounds];
    [self drawBorder:cornerPath];
    
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    objc_setAssociatedObject(processedImage, &kProcessedImage, @(1), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.image = processedImage;
}

#pragma mark -- 绘制边框

- (void)drawBorder:(UIBezierPath *)path {
    if (0 != self.borderWidth && nil != self.borderColor) {
        [path setLineWidth:2 * self.borderWidth];
        [self.borderColor setStroke];
        [path stroke];
    }
}

#pragma mark -- 加载图片

- (void)setCornerImageWithURL:(NSURL *)url placeholder:(UIImage *)placeholder {
    @weakify(self);
    [self sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        @strongify(self);
        //self.radius = (MIN(self.size.width,self.size.height)) / 2.0 ;
        UIImage *rstImage = image ;
        if(!rstImage){
            rstImage = placeholder;
        }
        //[self cornerRadiusWithImage:rstImage cornerRadius:self.radius rectCornerType:UIRectCornerAllCorners];
        rstImage = [rstImage circleImage];
        [[SDImageCache sharedImageCache]storeImage:rstImage forKey:url.absoluteString completion:nil];
        self.image = rstImage ;
    }];
}

- (void)setCornerImage:(UIImage *)image{
    //self.radius = (MIN(self.size.width,self.size.height)) / 2.0 ;
    //[self cornerRadiusWithImage:image cornerRadius:self.radius rectCornerType:UIRectCornerAllCorners];
    self.image = [image circleImage];
}

#pragma mark -- property

- (CGFloat)borderWidth {
    return [objc_getAssociatedObject(self, &kBorderWidth) floatValue];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    objc_setAssociatedObject(self, &kBorderWidth, @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)borderColor {
    return objc_getAssociatedObject(self, &kBorderColor);
}

- (void)setBorderColor:(UIColor *)borderColor {
    objc_setAssociatedObject(self, &kBorderColor, borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIRectCorner)roundingCorners {
    return [objc_getAssociatedObject(self, &kRoundingCorners) unsignedLongValue];
}

- (void)setRoundingCorners:(UIRectCorner)roundingCorners {
    objc_setAssociatedObject(self, &kRoundingCorners, @(roundingCorners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)radius {
    return [objc_getAssociatedObject(self, &kRadius) floatValue];
}

- (void)setRadius:(CGFloat)radius {
    objc_setAssociatedObject(self, &kRadius, @(radius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
