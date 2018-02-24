//
//  KKCacheSliderView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/5.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKCacheSliderView : UISlider
@property(nonatomic,assign)CGFloat cachaValue;//缓冲条的当前位置
@property(nonatomic)UIColor *cacheColor;//缓冲条的颜色
@end
