//
//  KKProgressView.h
//  KKToydayNews
//
//  Created by finger on 2017/11/4.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKProgressView : UIView
@property(assign,nonatomic)CGFloat progress;//当前进度
@property(assign,nonatomic)CGFloat loadProgress;//加载好的进度
@property(strong,nonatomic)UIColor *progressBgColor;//进度条背景颜色
@property(strong,nonatomic)UIColor *progressColor;//进度条颜色
@property(strong,nonatomic)UIColor *loadProgressColor;//已经加载好的进度颜色
@end
