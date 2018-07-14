//
//  UIImageView+URL.m
//  TXMedicalCircle
//
//  Created by kkfinger on 2018/5/15.
//  Copyright © 2018年 kkfinger. All rights reserved.
//

#import "UIImageView+URL.h"

@implementation UIImageView(URL)

- (void)setImageWithUrl:(NSString *)url placeholder:(UIImage *)placeholder circleImage:(BOOL)circleImage completed:(SDExternalCompletionBlock)completedBlock{
    if(!url.length){
        self.image = placeholder;
        return ;
    }
    SDImageCache *imageCache = [[SDWebImageManager sharedManager]imageCache];
    [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            if(completedBlock){
                completedBlock(image,nil,cacheType,[NSURL URLWithString:url]);
            }else{
                self.image = image ;
            }
        }else{
            @weakify(self);
            [self sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:placeholder completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                @strongify(self);
                UIImage *rstImage = image ;
                if(!rstImage){
                    rstImage = placeholder;
                }
                if(circleImage){
                    rstImage = [rstImage circleImage];
                }
                [[SDImageCache sharedImageCache]storeImage:rstImage forKey:imageURL.absoluteString completion:nil];
                self.image = rstImage ;
            }];
        }
    }];
}
        
@end
