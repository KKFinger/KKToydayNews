//
//  KKImageGalleryView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/22.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKDragableNavBaseView.h"
#import "KKPhotoInfo.h"
#import "KKMediaGralleryNavView.h"
#import "KKTextImageShareHeader.h"

@interface KKImageGalleryView : KKDragableNavBaseView
@property(nonatomic)KKMediaGralleryNavView *navView;
@property(nonatomic)NSInteger limitSelCount;//最多能选择几个
@property(nonatomic)NSInteger curtSelCount;//当前选择了几个
@property(nonatomic,copy)void(^selectImageCallback)(KKPhotoInfo *item,BOOL isSelect,void(^canSelect)(BOOL canSelect,NSInteger selCount));
@property(nonatomic)NSArray *(^getCurtSelArray)();
@property(nonatomic)void(^showShareCtrlWhenDismiss)();
@end
