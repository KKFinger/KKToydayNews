//
//  KKVideoNewsDetail.h
//  KKToydayNews
//
//  Created by finger on 2017/10/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKDragableBaseView.h"
#import "KKAVPlayerView.h"
#import "KKArticleModal.h"

@interface KKVideoNewsDetail : KKDragableBaseView
- (instancetype)initWithNewsBaseInfo:(KKNewsBaseInfo *)newsInfo;
- (void)addVideoPlayView:(KKAVPlayerView *)playView;
@end
