//
//  KKImageZoomView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/27.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKImageZoomView.h"

@interface KKImageZoomView ()<UIScrollViewDelegate>
@property(nonatomic,readwrite)YYAnimatedImageView *imageView;
@property(nonatomic,assign)CGSize imageSize;
@property(nonatomic,assign)CGPoint pointToCenterAfterResize;
@property(nonatomic,assign)CGFloat scaleToRestoreAfterResize;
@end

@implementation KKImageZoomView

- (void)dealloc{
    if (self.imageView != nil){
        [self.imageView setImage:nil];
        [self.imageView removeFromSuperview];
        self.imageView = nil ;
    }
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self _init];
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self){
        [self _init];
    }
    return self;
}

- (void)_init{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.delegate = self;
    self.bounces = YES ;
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 2.0;
    self.backgroundColor = [UIColor clearColor];
    self.frame = CGRectMake(0, 0, UIDeviceScreenWidth, UIDeviceScreenHeight);
}

- (void)clear{
    if (self.imageView != nil){
        [self.imageView removeFromSuperview];
        self.imageView = nil ;
    }
}

#pragma mark -- 设置图片

- (void)setImage:(UIImage *)image{
    if (image == nil){
        [self displayImage:[UIImage imageWithColor:[UIColor blackColor]]];
    }else{
        [self displayImage:image];
    }
}

- (void)setImageUrl:(NSString *)imageUrl{
    [self showImageWithUrl:imageUrl placeHolder:[UIImage imageWithColor:[UIColor blackColor]]];
}

- (void)showImageWithUrl:(NSString *)imageUrl placeHolder:(UIImage *)placeholder {
    _imageUrl = imageUrl;
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [[SDWebImageManager sharedManager]cachedImageExistsForURL:[NSURL URLWithString:_imageUrl] completion:^(BOOL isInCache) {
//            if(isInCache){
//                NSString *key = [[SDWebImageManager sharedManager]cacheKeyForURL:[NSURL URLWithString:_imageUrl]];
//                UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:key];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self displayImage:image];
//                });
//            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self loadImageWithUrl:_imageUrl placeHolder:placeholder];
//                });
//            }
//        }];
//    });
    [[SDImageCache sharedImageCache]queryCacheOperationForKey:_imageUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            [self displayImage:image];
        }else{
            [self loadImageWithUrl:_imageUrl placeHolder:placeholder];
        }
    }];
}

#pragma mark -- 显示相片

- (void)displayImage:(UIImage *)image{
    if (self.imageView != nil){
        [self.imageView removeFromSuperview];
        self.imageView.image = nil ;
        self.imageView = nil ;
    }
    
    self.imageView = [[YYAnimatedImageView alloc] initWithImage:image];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.layer.masksToBounds = YES ;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.imageView];
    
    CGFloat imageW = self.width;
    CGFloat rotaion = (image.size.width/(image.size.height > 0 ? image.size.height : imageW)) ;
    if(rotaion <= 0.0f){
        rotaion = 1.0 ;
    }
    CGFloat imageH = imageW/rotaion;
    
    self.contentSize = CGSizeMake(imageW, imageH);
    
    self.imageView.frame = CGRectMake(0, (imageH > self.height) ? 0 : (self.height - imageH) / 2.0, imageW, imageH);
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.imageView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingalTap:)];
    [singalTap requireGestureRecognizerToFail:doubleTap]; // 加上这句话可以阻止双击事件被单击事件拦截
    [singalTap setNumberOfTapsRequired:1];
    [self addGestureRecognizer:singalTap];
}

- (void)loadImageWithUrl:(NSString *)url placeHolder:(UIImage *)placeHolder{
    if (self.imageView != nil){
        [self.imageView removeFromSuperview];
        self.imageView.image = nil ;
        self.imageView = nil ;
    }
    
    self.imageView = [YYAnimatedImageView new];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.layer.masksToBounds = YES ;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.frame = CGRectMake(0, 0, placeHolder.size.width, placeHolder.size.height);
    self.imageView.image = placeHolder;
    [self addSubview:self.imageView];
    
    [self centerImageView:self.imageView];
    [self showActivityViewWithImage:@"liveroom_rotate_55x55_"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [[SDWebImageManager sharedManager]loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageScaleDownLargeImages progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hiddenActivity];
                
                self.imageView.image = image ;
                
                CGFloat imageW = self.width;
                CGFloat rotaion = (image.size.width/(image.size.height > 0 ? image.size.height : imageW)) ;
                if(rotaion <= 0.0f){
                    rotaion = 1.0 ;
                }
                CGFloat imageH = imageW/rotaion;
                
                self.contentSize = CGSizeMake(imageW, imageH);
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.imageView.frame = CGRectMake(0, (imageH > self.height) ? 0 : (self.height - imageH) / 2.0, imageW, imageH);
                }completion:^(BOOL finished) {
                }];
                
                UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
                [doubleTap setNumberOfTapsRequired:2];
                [self.imageView addGestureRecognizer:doubleTap];
                
                UITapGestureRecognizer *singalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingalTap:)];
                [singalTap requireGestureRecognizerToFail:doubleTap]; // 加上这句话可以阻止双击事件被单击事件拦截
                [singalTap setNumberOfTapsRequired:1];
                [self addGestureRecognizer:singalTap];
            });
        }];
    });
}

#pragma mark -- 图片居中显示

- (void)centerImageView:(YYAnimatedImageView *)imageView{
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width){
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2 ;
    }else{
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height){
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }else{
        frameToCenter.origin.y = 0;
    }
    imageView.frame = frameToCenter;
}

#pragma mark -- 双击

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture{
    float newScale = self.zoomScale;
    if ([[NSString stringWithFormat:@"%f",newScale] isEqualToString:[NSString stringWithFormat:@"%f",self.minimumZoomScale]]){
        newScale = self.maximumZoomScale;
    }else{
        newScale = self.minimumZoomScale;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGSize size = CGSizeMake(self.bounds.size.width / scale,
                             self.bounds.size.height / scale);
    CGRect rect = CGRectMake(center.x - (size.width / 2.0), center.y - (size.height / 2.0), size.width, size.height);
    return rect;
}

#pragma mark -- 单击事件

- (void)handleSingalTap:(UIGestureRecognizer *)theGesture{
    if(self.zoomViewDelegate && [self.zoomViewDelegate respondsToSelector:@selector(tapImageZoomView)]){
        [self.zoomViewDelegate tapImageZoomView];
    }
}

#pragma mark -- UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width){
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2 ;
    }else{
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height){
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }else{
        frameToCenter.origin.y = 0;
    }
    
    self.imageView.frame = frameToCenter;
    
    if(self.zoomViewDelegate && [self.zoomViewDelegate respondsToSelector:@selector(imageViewDidZoom:)]){
        [self.zoomViewDelegate imageViewDidZoom:self];
    }
}

@end
