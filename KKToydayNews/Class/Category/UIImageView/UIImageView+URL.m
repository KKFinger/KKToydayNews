//
//  UIImageView+URL.m
//  TXMedicalCircle
//
//  Created by kkfinger on 2018/5/15.
//  Copyright © 2018年 kkfinger. All rights reserved.
//

#import "UIImageView+URL.h"

@implementation UIImageView(URL)

- (void)setImageWithUrl:(NSString *)url placeholder:(UIImage *)placeholder circleImage:(BOOL)circleImage completed:(nullable SDExternalCompletionBlock)completedBlock{
    if(!url.length){
        url = @"";
    }
    SDImageCache *imageCache = [[SDWebImageManager sharedManager]imageCache];
    [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            if(completedBlock){
                if(circleImage){
                    image = [image circleImage];
                }
                completedBlock(image,nil,cacheType,[NSURL URLWithString:url]);
            }else{
                if(circleImage){
                    self.image = [image circleImage];
                }else{
                    self.image = image;
                }
            }
        }else{
            [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder completed:completedBlock];
        }
    }];
}
        

@end
