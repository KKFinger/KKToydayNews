//
//  UIImage+Extend.h
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage(UIImage)

#pragma mark -- 图片透明度

- (UIImage *)imageWithAlpha:(float)theAlpha;

#pragma mark -- 图片填充颜色

+ (UIImage *)imageWithColor:(UIColor *)color;

#pragma mark -- 图片圆角

- (UIImage*)imageWithCornerRadius:(CGFloat)radius;

#pragma mark -- 圆角图片

- (UIImage *)circleImage;

//图片压缩
- (UIImage *)scaleWithFactor:(float)scaleFloat quality:(CGFloat)compressionQuality;

// Create a UIImage from sample buffer data
+ (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end
