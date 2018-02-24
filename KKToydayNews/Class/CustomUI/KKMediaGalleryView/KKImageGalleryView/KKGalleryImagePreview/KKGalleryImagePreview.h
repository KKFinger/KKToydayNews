//
//  KKGalleryImagePreview.h
//  KKToydayNews
//
//  Created by finger on 2017/10/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKDragableBaseView.h"
#import "KKPhotoInfo.h"

@interface KKGalleryImagePreview : KKDragableBaseView
- (instancetype)initWithImageArray:(NSArray<NSString *> *)imageArray selIndex:(NSInteger)selIndex albumId:(NSString *)albumId selCount:(NSInteger)selCount;
@property(nonatomic,assign)CGRect oriFrame;
@property(nonatomic,weak)UIView *oriView;
@property(nonatomic,assign)NSInteger selCount;
@property(nonatomic,assign)BOOL zoomAnimateWhenShowAndHide;//当视图显示、消失时是否使用向内缩小、向外放大动画，默认为YES
//自由拖拽图片结束时的相片隐藏动画
@property(nonatomic,copy)void(^hideImageAnimate)(UIImage *image,CGRect fromFrame,CGRect toFrame);
//上下左右拖动视图时，回复相片在原视图中的透明度
@property(nonatomic,copy)void(^alphaViewIfNeed)(BOOL shouldAlphaView,NSInteger curtSelIndex);
//当左右滑动图片时，同时更新图片的原始frame，用于隐藏动画
@property(nonatomic,copy)void(^imageIndexChange)(NSInteger imageIndex,void(^updeteOriFrame)(CGRect oriFrame));
@property(nonatomic,copy)void(^selectImage)(KKPhotoInfo *photoItem,BOOL isSelect,NSInteger selIndex,void(^selectCallback)(BOOL canSelect,NSInteger selCount));
@end
