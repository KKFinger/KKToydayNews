//
//  KKImageBrowser.h
//  KKToydayNews
//
//  Created by finger on 2017/10/13.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKDragableBaseView.h"

@interface KKImageBrowser : KKDragableBaseView
@property(nonatomic,assign)BOOL showImageWithUrl;//显示方式是url还是UIImage
@property(nonatomic,assign)NSInteger selIndex;
//自由拖拽图片结束时的相片隐藏动画
@property(nonatomic,copy)void(^hideImageAnimate)(UIImage *image,CGRect fromFrame,CGRect toFrame);
//上下左右拖动视图时，恢复相片在原视图中的透明度
@property(nonatomic,copy)void(^alphaViewIfNeed)(BOOL shouldAlphaView,NSInteger index);
//当左右滑动图片时，同时更新图片的原始frame，用于隐藏动画
@property(nonatomic,copy)void(^imageIndexChange)(NSInteger imageIndex,void(^updeteOriFrame)(CGRect oriFrame));
- (instancetype)initWithImageArray:(NSArray<KKImageItem*>*)imageArray oriView:(UIView *)oriView oriFrame:(CGRect)oriFrame;
@end
