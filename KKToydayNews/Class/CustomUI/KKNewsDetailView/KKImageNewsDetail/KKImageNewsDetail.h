//
//  KKImageNewsDetail.h
//  KKToydayNews
//
//  Created by finger on 2017/9/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKDragableNavBaseView.h"
#import "KKArticleModal.h"

@interface KKImageNewsDetail : KKDragableNavBaseView

- (instancetype)initWithNewsBaseInfo:(KKNewsBaseInfo *)newsInfo;

@property(nonatomic,copy)NSArray<KKImageItem *> *imageArray;
@property(nonatomic,assign)CGRect oriFrame;
@property(nonatomic,weak)UIView *oriView;
@property(nonatomic,weak)UIImage *oriImage;
//自由拖拽图片结束时的相片隐藏动画
@property(nonatomic,copy)void(^hideImageAnimate)(UIImage *image,CGRect fromFrame,CGRect toFrame);
//上下左右拖动视图时，回复相片在原视图中的透明度
@property(nonatomic,copy)void(^alphaViewIfNeed)(BOOL shouldAlphaView);
@end
