//
//  KKTextImageShareHeader.h
//  KKToydayNews
//
//  Created by finger on 2017/10/22.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPhotoInfo.h"

@protocol KKTextImageShareHeaderDelegate <NSObject>
- (void)needAdjustHeaderHeight;
@end

@interface KKTextImageShareHeader : UIView
@property(nonatomic,weak)id<KKTextImageShareHeaderDelegate>delegate;
@property(nonatomic,copy)NSArray *imageArray;
- (CGFloat)fetchHeaderHeight;
- (void)hideKeyboard;
@end
