//
//  UIImage+Extend.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "UIImage+Extend.h"

@implementation UIImage(Extend)

#pragma mark -- 图片透明度

- (UIImage *)imageWithAlpha:(float)theAlpha
{
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height) blendMode:kCGBlendModeNormal alpha:theAlpha];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark -- 图片填充颜色

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark -- 图片圆角

- (UIImage*)imageWithCornerRadius:(CGFloat)radius{
    
    CGRect rect = (CGRect){0.f,0.f,self.size};

    // void UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale);
    //size——同UIGraphicsBeginImageContext,参数size为新创建的位图上下文的大小
    //    opaque—透明开关，如果图形完全不用透明，设置为YES以优化位图的存储。
    //    scale—–缩放因子
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);

    //根据矩形画带圆角的曲线
    CGContextAddPath(UIGraphicsGetCurrentContext(), [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath);

    [self drawInRect:rect];

    //图片缩放，是非线程安全的
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();

    //关闭上下文
    UIGraphicsEndImageContext();

    return image;
}

- (UIImage *)scaleWithFactor:(float)scaleFloat quality:(CGFloat)compressionQuality
{
    CGSize size = CGSizeMake(self.size.width * scaleFloat, self.size.height * scaleFloat);
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    transform = CGAffineTransformScale(transform, scaleFloat, scaleFloat);
    CGContextConcatCTM(context, transform);
    
    [self drawAtPoint:CGPointMake(0.0f, 0.0f)];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imagedata = UIImageJPEGRepresentation(newimg,compressionQuality);
    
    return [UIImage imageWithData:imagedata] ;
}

- (UIImage *)circleImage{
    CGFloat imageWH = MIN(self.size.width,self.size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageWH, imageWH), NO, 0.0);
    CGContextRef ctr = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, imageWH, imageWH);
    CGContextAddEllipseInRect(ctr, rect);
    CGContextClip(ctr);
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// Create a UIImage from sample buffer data
+ (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //锁定像素缓冲区的起始地址
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    //获取每行像素的字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    //获取像素缓冲区的宽度和高度
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    //创建基于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace){
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
    //获取像素缓冲区的起始地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    //获取像素缓冲区的数据大小
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    //使用提供的数据创建CGDataProviderRef
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,NULL);
    
    //通过CGDataProviderRef，创建CGImageRef
    CGImageRef cgImage =
    CGImageCreate(width,
                  height,
                  8,
                  32,
                  bytesPerRow,
                  colorSpace,
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  provider,
                  NULL,
                  true,
                  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    //创建UIImage
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    //解锁像素缓冲区起始地址
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

@end
