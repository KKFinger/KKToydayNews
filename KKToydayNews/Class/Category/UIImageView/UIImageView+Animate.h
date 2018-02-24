//
//  UIImageView+Animate.h
//  KKToydayNews
//
//  Created by finger on 2017/9/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView(Animate)
- (void)kk_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   animate:(BOOL)animate;
- (void)kk_setGifImageWithURL:(nullable NSURL *)url
             placeholderImage:(nullable UIImage *)placeholder
                      animate:(BOOL)animate;
@end
