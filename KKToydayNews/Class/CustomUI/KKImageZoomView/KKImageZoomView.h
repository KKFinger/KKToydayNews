//
//  WXScrollView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/27.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKImageZoomView;
@protocol KKImageZoomViewDelegate <NSObject>
- (void)tapImageZoomView;
- (void)imageViewDidZoom:(KKImageZoomView *)zoomView;
@end

@interface KKImageZoomView : UIScrollView
@property(nonatomic,weak)id<KKImageZoomViewDelegate>zoomViewDelegate;
@property(nonatomic,readonly)YYAnimatedImageView *imageView;
@property(nonatomic,readwrite)UIImage *image;
@property(nonatomic,readwrite,copy)NSString *imageUrl;
- (void)showImageWithUrl:(NSString *)imageUrl placeHolder:(UIImage *)image;
- (void)clear;
@end
