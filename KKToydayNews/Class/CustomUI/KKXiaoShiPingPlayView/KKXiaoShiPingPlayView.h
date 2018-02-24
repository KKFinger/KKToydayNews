//
//  KKXiaoShiPingPlayView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKDragableNavBaseView.h"
#import "KKArticleModal.h"

@protocol KKXiaoShiPingPlayViewDelegate <NSObject>
- (void)scrollToIndex:(NSInteger)index callBack:(void(^)(CGRect oriFrame,UIImage *oriImage))callback;
@end

@interface KKXiaoShiPingPlayView : KKDragableNavBaseView
@property(nonatomic,weak)id<KKXiaoShiPingPlayViewDelegate>delegate;
//用于退出播放视图时的动画
@property(nonatomic,assign)CGRect oriFrame;
@property(nonatomic,weak)UIView *oriView;
@property(nonatomic,weak)UIImage *oriImage;
//自由拖拽图片结束时的相片隐藏动画
@property(nonatomic,copy)void(^hideImageAnimate)(UIImage *image,CGRect fromFrame,CGRect toFrame);
//上下左右拖动视图时，恢复相片在原视图中的透明度
@property(nonatomic,copy)void(^alphaViewIfNeed)(BOOL shouldAlphaView);

- (instancetype)initWithNewsBaseInfo:(KKNewsBaseInfo *)newsInfo
                          videoArray:(NSArray *)videoArray
                            selIndex:(NSInteger)selIndex;

@end
