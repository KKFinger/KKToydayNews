//
//  KKAVPlayerView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/5.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKAVPlayer.h"

@protocol KKAVPlayerViewDelegate <NSObject>
- (void)enterFullScreen;
- (void)quitFullScreen;
- (void)quitVideoDetailView;//退出视频详情页
@end

typedef NS_ENUM(NSInteger, KKSamllVideoType) {
    KKSamllVideoTypeVideoCatagory,//在视频板块播放小窗口视频，则不显示回退按钮
    KKSamllVideoTypeDetail,//在视频详情页小窗口播放，则显示回退按钮，不显示标题和播放次数等
    KKSamllVideoTypeOther,//隐藏回退按钮、标题、播放次数
};

@interface KKAVPlayerView :UIView
@property(nonatomic,weak)id<KKAVPlayerViewDelegate>delegate;
@property(nonatomic,assign)CGRect originalFrame ;//小屏播放视图的frame
@property(nonatomic,weak)UIView *originalView ;//小屏播放时播放器对应的tableview cell
@property(nonatomic,readonly)NSString *videoId;
@property(nonatomic,assign)KKSamllVideoType smallType;
@property(nonatomic,assign)BOOL fullScreen ;
@property(nonatomic,assign)BOOL canHideStatusBar ;
- (instancetype)initWithTitle:(NSString *)title playCount:(NSString *)playCount coverUrl:(NSString *)coverUrl videoId:(NSString *)videoId smallType:(KKSamllVideoType)smallType;
- (void)destoryVideoPlayer;
@end
