//
//  KKAVPlayer.h
//  KKToydayNews
//
//  Created by finger on 2017/10/1.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, KKMediaType) {
    KKMediaTypeNone = 0,
    KKMediaTypeAudio,
    KKMediaTypeVideo
};

typedef NS_ENUM(NSInteger, KKNetworkType) {
    KKNetworkTypeNet,//网络
    KKNetworkTypeLocal,//本地
};

@class KKAVPlayer;

typedef void(^progressCallback)(KKAVPlayer *player,float progress);//播放进度
typedef void(^seekCompleteCallback)(KKAVPlayer *player,CGFloat prePos,CGFloat curtPos);
typedef void(^willSeekToPosition)(KKAVPlayer *player,CGFloat curtPos,CGFloat toPos);
typedef void(^completeCallback)(KKAVPlayer *player);//播放完成
typedef void(^errorCallback)(KKAVPlayer *player,NSError *error);//播放错误
typedef void(^loadStatusCallback)(KKAVPlayer *player,AVPlayerStatus status);//流媒体加载状态
typedef void(^bufferPercentCallback)(KKAVPlayer *player,float bufferPercent);//流媒体缓冲百分比
typedef void(^bufferingCallback)(KKAVPlayer *player);//正在缓冲
typedef void(^bufferFinishCallback)(KKAVPlayer *player);//缓冲结束

@protocol KKAVPlayerDelegate <NSObject>
- (void)player:(KKAVPlayer *)player progress:(float)progress;
- (void)playerWillSeekToPosition:(KKAVPlayer *)player curtPos:(CGFloat )curtPos toPos:(CGFloat)toPos;
- (void)playerSeekComplete:(KKAVPlayer *)player prePos:(CGFloat)prePos curtPos:(CGFloat)curtPos;
- (void)playerComplete:(KKAVPlayer *)player;
- (void)playerBuffering:(KKAVPlayer *)player;
- (void)playerBufferFinish:(KKAVPlayer *)player;
- (void)player:(KKAVPlayer *)player playerError:(NSError *)error;
- (void)player:(KKAVPlayer *)player loadStatus:(AVPlayerStatus)status;
- (void)player:(KKAVPlayer *)player bufferPercent:(float)bufferPercent;
@end

@interface KKAVPlayer : NSObject
@property (nonatomic,weak)id<KKAVPlayerDelegate>delegate;
@property (nonatomic,assign,readonly)float totalBuffer;//中缓冲的长度
@property (nonatomic,assign,readonly)float currentPlayTime;//当前播放的时间
@property (nonatomic,assign,readonly)float totalTime;//总时长
@property (nonatomic,assign,readonly)float curtPosition;
@property (nonatomic,assign)float seekToPosition;//播放位置，0~1

@property (nonatomic,readonly) AVPlayerLayer *playerLayer;//视频渲染图层

@property (nonatomic,copy) progressCallback progressCallback;
@property (nonatomic,copy) completeCallback completeCallback;
@property (nonatomic,copy) errorCallback errorCallback;
@property (nonatomic,copy) loadStatusCallback loadStatusCallback;
@property (nonatomic,copy) bufferPercentCallback bufferPercentCallback;
@property (nonatomic,copy) willSeekToPosition willSeekToPosition;
@property (nonatomic,copy) seekCompleteCallback seekCompleteCallback;
@property (nonatomic,copy) bufferingCallback bufferingCallback;
@property (nonatomic,copy) bufferFinishCallback bufferFinishCallback;

@property (nonatomic,copy) NSString *mediaUrl;//连接地址
@property (nonatomic,assign) KKMediaType mediaType;
@property (nonatomic,assign) KKNetworkType netType;

+ (instancetype)sharedInstance;

- (void)initPlayInfoWithUrl:(NSString*)url
                  mediaType:(KKMediaType)type
                networkType:(KKNetworkType)netType;

- (void)initPlayInfoWithUrl:(NSString*)url
                  mediaType:(KKMediaType)type
                networkType:(KKNetworkType)netType
                    process:(progressCallback)progressCallback
                  compelete:(completeCallback)completeCallback
                 loadStatus:(loadStatusCallback)loadStatusCallback
              bufferPercent:(bufferPercentCallback)bufferPercentCallback
         willSeekToPosition:(willSeekToPosition)willSeekToPosition
               seekComplete:(seekCompleteCallback)seekCompleteCallback
                  buffering:(bufferingCallback)bufferingCallback
               bufferFinish:(bufferFinishCallback)bufferFinishCallback
                      error:(errorCallback)errorCallback;

#pragma mark -- 重置播放的回调

- (void)resetProcess:(progressCallback)progressCallback
           compelete:(completeCallback)completeCallback
          loadStatus:(loadStatusCallback)loadStatusCallback
       bufferPercent:(bufferPercentCallback)bufferPercentCallback
  willSeekToPosition:(willSeekToPosition)willSeekToPosition
        seekComplete:(seekCompleteCallback)seekCompleteCallback
           buffering:(bufferingCallback)bufferingCallback
        bufferFinish:(bufferFinishCallback)bufferFinishCallback
               error:(errorCallback)errorCallback;

#pragma mark -- 播放控制

- (void)play;
- (bool)isPlay;
- (void)pause;
- (bool)isPause;
- (bool)playFinish;
- (void)releasePlayer;//销毁播放器

@end
