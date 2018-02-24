//
//  KKRecordCorverSlider.h
//  KKToydayNews
//
//  Created by finger on 2017/11/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKVideoInfo.h"

@protocol KKRecordCorverSliderDelegate <NSObject>
- (void)seekToPosition:(CGFloat)position;
@end

@interface KKRecordCorverSlider : UIView
@property(nonatomic,weak)id<KKRecordCorverSliderDelegate>delegate;
@property(nonatomic,weak)UIImage *selImage;
- (instancetype)initWithVideoInfo:(KKVideoInfo *)videoInfo;
@end
