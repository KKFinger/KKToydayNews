//
//  KKXiaoShiPingPlayer.h
//  KKToydayNews
//
//  Created by finger on 2017/10/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKAVPlayer.h"

@protocol KKXiaoShiPingPlayerDelegate <NSObject>
- (void)videoDidPlaying;
@end

@interface KKXiaoShiPingPlayer : UIView
@property(nonatomic,weak)id<KKXiaoShiPingPlayerDelegate>delegate;
@property(nonatomic,assign)KKNetworkType netType;
@property(nonatomic)NSString *playUrl;
@property(nonatomic)NSString *corverUrl;
@property(nonatomic)UIImage *corverImage;
- (void)destoryVideoPlayer;
- (void)startPlayVideo;
- (void)pause;
- (void)resume;
@end
