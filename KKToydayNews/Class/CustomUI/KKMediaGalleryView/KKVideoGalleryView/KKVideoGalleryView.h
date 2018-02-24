//
//  KKVideoGalleryView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/29.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDragableNavBaseView.h"
#import "KKVideoInfo.h"

@interface KKVideoGalleryView : KKDragableNavBaseView
@property(nonatomic,copy)void(^selectVideoCallback)(KKVideoInfo *item);
@end
