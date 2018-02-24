//
//  UIImageView+Animate.m
//  KKToydayNews
//
//  Created by finger on 2017/9/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "UIImageView+Animate.h"
#import "NSData+ImageContentType.h"
#import "UIImage+GIF.h"
#import <ImageIO/ImageIO.h>
#import "UIView+WebCacheOperation.h"

static NSString *downTokenKey;

@interface UIImageView ()
@property(nonatomic,retain)SDWebImageDownloadToken *downToken;
@end

@implementation UIImageView(Animate)

- (void)dealloc{
}

- (void)kk_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   animate:(BOOL)animate{
    [self sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(animate){
            self.alpha = 0.0;
            [UIView transitionWithView:self
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                self.alpha = 1.0;
                            }completion:^(BOOL finished) {
                                
                            }];
        }
    }];
}

//加载gif图内存过高，已弃用，换为YYImage框架
- (void)kk_setGifImageWithURL:(nullable NSURL *)url
             placeholderImage:(nullable UIImage *)placeholder
                      animate:(BOOL)animate{
    self.image = placeholder;
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    SDImageCache *imgCache = [mgr imageCache];
    
    @weakify(mgr);
    @weakify(imgCache);
    @weakify(self);
    [mgr cachedImageExistsForURL:url completion:^(BOOL isInCache) {
        @strongify(mgr);
        @strongify(imgCache);
        @strongify(self);
        if(isInCache){
            NSString *key = [mgr cacheKeyForURL:url];
            UIImage *image = [imgCache imageFromCacheForKey:key];
            self.image = image ;
            return  ;
        }
        
        NSString *validOperationKey = NSStringFromClass([self class]);
        [self sd_cancelImageLoadOperationWithKey:validOperationKey];
        
        id <SDWebImageOperation> operation = [mgr loadImageWithURL:url options:SDWebImageContinueInBackground progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                if (error) {
                    NSLog(@"下载错误%@",error);
                    return;
                }
                if(!finished){
                    NSLog(@"image download unfinish");
                    return ;
                }
                UIImage *rstImage = image ;
                SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:data];
                if (imageFormat == SDImageFormatGIF) {
                    rstImage = [UIImage animatedImageWithAnimatedGIFData:data scaleFactor:0.5 quality:0.5];
                }else{
                    rstImage = [UIImage imageWithData:data];
                    rstImage = [image scaleWithFactor:1.0 quality:0.3];
                }
                
                [mgr saveImageToCache:rstImage forURL:url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.image = rstImage;
                    if(animate){
                        self.alpha = 0.0;
                        [UIView transitionWithView:self
                                          duration:0.5
                                           options:UIViewAnimationOptionTransitionCrossDissolve
                                        animations:^{
                                            self.alpha = 1.0;
                                        }completion:^(BOOL finished) {
                                            
                                        }];
                    }
                });
            });
        }];
        [self sd_setImageLoadOperation:operation forKey:validOperationKey];
    }];
}

- (void)setDownToken:(SDWebImageDownloadToken *)downToken{
    objc_setAssociatedObject(self, &downTokenKey, nil, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self, &downTokenKey, downToken, OBJC_ASSOCIATION_RETAIN);
}

- (SDWebImageDownloadToken *)downToken{
    return objc_getAssociatedObject(self, &downTokenKey);
}

@end
