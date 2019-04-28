//
//  UIImageView+URL.m
//  TXMedicalCircle
//
//  Created by kkfinger on 2018/5/15.
//  Copyright © 2018年 kkfinger. All rights reserved.
//

#import "UIImageView+URL.h"

@implementation UIImageView(YYURL)

- (void)YYSetImageWithUrl:(NSString *)url placeholder:(UIImage *)placeholder circleImage:(BOOL)circleImage completed:(YYWebImageCompletionBlock)completedBlock{
    if(!url.length){
        url = @"";
    }
    YYImageCache *imageCache = [YYImageCache sharedCache];
    [imageCache getImageForKey:url withType:YYImageCacheTypeMemory|YYImageCacheTypeDisk withBlock:^(UIImage * _Nullable image, YYImageCacheType type) {
        if(image){
            if(completedBlock){
                if(circleImage){
                    image = [image circleImage];
                }
                completedBlock(image,[NSURL URLWithString:url],YYWebImageFromNone,YYWebImageStageFinished,nil);
            }else{
                if(circleImage){
                    image = [image circleImage];
                }
                [self setImage:image];
            }
        }else{
            [self yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageWithColor:[UIColor grayColor]] options:YYWebImageOptionShowNetworkActivity completion:completedBlock];
        }
    }];
}

@end
