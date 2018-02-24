//
//  KKProgressView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/4.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKProgressView.h"

@implementation KKProgressView

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setProgressBgColor:(UIColor *)progressBgColor {
    _progressBgColor = progressBgColor;
    [self setNeedsDisplay];
}

- (void)setloadProgressColor:(UIColor *)loadProgressColor {
    _loadProgressColor = loadProgressColor;
    [self setNeedsDisplay];
}

- (void)setLoadProgress:(CGFloat)loadProgress {
    _loadProgress = loadProgress;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [self.progressBgColor set];
    CGContextSetAlpha(context, 1.0);
    CGContextDrawPath(context, kCGPathFill);
    
    CGContextAddRect(context, CGRectMake(0, 0, rect.size.width*self.loadProgress, rect.size.height));
    [self.loadProgressColor set];
    CGContextSetAlpha(context, 1);
    CGContextDrawPath(context, kCGPathFill);
    
    CGContextAddRect(context, CGRectMake(0, 0, rect.size.width*self.progress, rect.size.height));
    [self.progressColor set];
    CGContextSetAlpha(context, 1);
    CGContextDrawPath(context, kCGPathFill);
}

@end
