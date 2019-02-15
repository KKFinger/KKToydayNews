//
//  KKAVPlayer.m
//  KKToydayNews
//
//  Created by finger on 2017/10/1.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKAVPlayer.h"

@interface KKAVPlayer()
@property (nonatomic) AVPlayer *player;//播放器对象
@property (nonatomic,readwrite) AVPlayerLayer *playerLayer;//视频渲染图层
@property (nonatomic) AVPlayerItem *curtPlayerItem;
@property (nonatomic) id playTimeObserverObject;

@property (nonatomic,assign,readwrite)float totalBuffer;//缓冲的长度
@property (nonatomic,assign,readwrite)float currentPlayTime;//当前播放的时间
@property (nonatomic,assign,readwrite)float totalTime;//总时长
@property (nonatomic,assign,readwrite)float curtPosition;//当前播放的位置

@end

@implementation KKAVPlayer

@synthesize mediaUrl = _mediaUrl ;

+ (instancetype)sharedInstance{
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init{
    self = [super init] ;
    if(self){
        [self initPlayEnv];
    }
    return self ;
}

- (void)dealloc{
    [self releasePlayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)initPlayEnv{
    //app进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    //app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
    //中断处理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback/*允许后台*/ withOptions:AVAudioSessionCategoryOptionMixWithOthers/*混合播放，不独占*/ error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)clearData{
    self.progressCallback = nil ;
    self.completeCallback = nil ;
    self.errorCallback = nil ;
    self.loadStatusCallback = nil ;
    self.bufferPercentCallback = nil ;
    self.willSeekToPosition = nil ;
    self.seekCompleteCallback = nil ;
    self.bufferingCallback = nil;
    self.bufferFinishCallback = nil ;
}

- (void)releasePlayer{
    [self clearData];
    [self removeNotification];
    [self removeProgressObserver];
    [self removeObserverFromPlayerItem:self.curtPlayerItem];
    
    self.player = nil ;
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil ;
    
    self.curtPlayerItem = nil ;
    self.playTimeObserverObject = nil ;
}

- (void)initPlayInfoWithUrl:(NSString*)url
                  mediaType:(KKMediaType)type
                networkType:(KKNetworkType)netType{
    self.mediaUrl = [url copy];
    self.mediaType = type;
    self.netType = netType;
    
    [self preparePlayer];
}

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
                      error:(errorCallback)errorCallback{
    [self clearData];
    
    self.mediaUrl = [url copy];
    self.progressCallback = [progressCallback copy];
    self.completeCallback = [completeCallback copy];
    self.errorCallback = [errorCallback copy];
    self.loadStatusCallback = [loadStatusCallback copy];
    self.bufferPercentCallback = [bufferPercentCallback copy];
    self.willSeekToPosition = [willSeekToPosition copy];
    self.seekCompleteCallback = [seekCompleteCallback copy];
    self.bufferingCallback = [bufferingCallback copy];
    self.bufferFinishCallback = [bufferFinishCallback copy];
    self.mediaType = type;
    self.netType = netType;
    
    [self preparePlayer];
}

- (void)preparePlayer{
    if(self.player){
        [self removeNotification];
        [self removeObserverFromPlayerItem:self.curtPlayerItem];
        [self removeProgressObserver];
    }
    
    self.currentPlayTime = 0;
    self.totalTime = 0 ;
    
    NSURL *url = nil ;
    if(self.netType == KKNetworkTypeNet){
        url = [NSURL URLWithString:self.mediaUrl];
    }else{
        url = [NSURL fileURLWithPath:self.mediaUrl];
    }
    self.curtPlayerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.curtPlayerItem];
    
    if(self.mediaType == KKMediaTypeVideo){
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        //设置模式
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.playerLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    
    [self addProgressObserver];
    [self addObserverToPlayerItem:self.curtPlayerItem];
    [self addNotification];
}

#pragma mark -- 重置播放的回调

- (void)resetProcess:(progressCallback)progressCallback
           compelete:(completeCallback)completeCallback
          loadStatus:(loadStatusCallback)loadStatusCallback
       bufferPercent:(bufferPercentCallback)bufferPercentCallback
  willSeekToPosition:(willSeekToPosition)willSeekToPosition
        seekComplete:(seekCompleteCallback)seekCompleteCallback
           buffering:(bufferingCallback)bufferingCallback
        bufferFinish:(bufferFinishCallback)bufferFinishCallback
               error:(errorCallback)errorCallback{
    self.progressCallback = [progressCallback copy];
    self.completeCallback = [completeCallback copy];
    self.errorCallback = [errorCallback copy];
    self.loadStatusCallback = [loadStatusCallback copy];
    self.bufferPercentCallback = [bufferPercentCallback copy];
    self.willSeekToPosition = [willSeekToPosition copy];
    self.seekCompleteCallback = [seekCompleteCallback copy];
    self.bufferingCallback = [bufferingCallback copy];
    self.bufferFinishCallback = [bufferFinishCallback copy];
}

#pragma mark -- 添加播放完成、错误通知

-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    //给AVPlayerItem添加播放错误通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFail:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:self.player.currentItem];
}

-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  播放完成通知
 *
 *  @param notification 通知对象
 */
-(void)playbackFinished:(NSNotification *)notification{
    self.curtPosition = 0 ;
    self.currentPlayTime = self.totalTime = 0 ;
    if(self.completeCallback){
        self.completeCallback(self);
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(playerComplete:)]){
        [self.delegate playerComplete:self];
    }
}

/**
 *  播放错误通知
 *
 *  @param notification 通知对象
 */
- (void)playbackFail:(NSNotification *)notification{
    self.curtPosition = 0 ;
    self.currentPlayTime = self.totalTime = 0 ;
    if(self.errorCallback){
        self.errorCallback(self,self.player.error);
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(player:playerError:)]){
        [self.delegate player:self playerError:self.player.error];
    }
}

#pragma mark -- 播放进度监控
/**
 *  给播放器添加进度更新
 */
-(void)addProgressObserver{
    
    //这里设置每秒执行一次
    AVPlayerItem *playerItem = self.curtPlayerItem;
    
    @weakify(self);
    self.playTimeObserverObject = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self);
        self.currentPlayTime = CMTimeGetSeconds(time);
        self.totalTime = CMTimeGetSeconds([playerItem duration]);
        self.curtPosition = self.currentPlayTime/self.totalTime ;
        
        if(self.progressCallback){
            self.progressCallback(self,self.curtPosition);
        }
        if(self.delegate && [self.delegate respondsToSelector:@selector(player:progress:)]){
            [self.delegate player:self progress:self.curtPosition];
        }
    }];
}

- (void)removeProgressObserver{
    if(self.playTimeObserverObject){
        [self.player removeTimeObserver:self.playTimeObserverObject];
    }
}

#pragma mark -- 播放对象的状态

/**
 *  给AVPlayerItem添加监控
 *
 *  @param playerItem AVPlayerItem对象
 */
-(void)addObserverToPlayerItem:(AVPlayerItem *)playerItem{
    if(playerItem){
        //监控播放状态
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        //监控网络加载情况
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        //正在缓冲
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        //缓冲结束
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeObserverFromPlayerItem:(AVPlayerItem *)playerItem{
    if(playerItem){
        [playerItem removeObserver:self forKeyPath:@"status"];
        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        playerItem = nil ;
    }
}

#pragma mark -- KVO

/**
 *  通过KVO监控播放器状态
 *
 *  @param keyPath 监控属性
 *  @param object  监视器
 *  @param change  状态改变
 *  @param context 上下文
 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([object isKindOfClass:[AVPlayerItem class]]){
        
        AVPlayerItem *playerItem = object;
        
        if ([keyPath isEqualToString:@"status"]) {
            
            AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
            
            switch (status){
                case AVPlayerStatusUnknown:{
                    NSLog(@"加载状态：未知状态，此时不能播放");
                    break;
                }
                case AVPlayerStatusReadyToPlay:{
                    self.totalTime = CMTimeGetSeconds([playerItem duration]);
                    NSLog(@"加载状态：准备完毕，可以播放,总时长:%.2f",self.totalTime);
                    break;
                }
                case AVPlayerStatusFailed:{
                    NSLog(@"加载状态：加载失败，网络或者服务器出现问题");
                    break;
                }
                default:break;
            }
            
            if(self.loadStatusCallback){
                self.loadStatusCallback(self,status);
            }
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(player:loadStatus:)]){
                [self.delegate player:self loadStatus:status];
            }
            
        }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
            
            NSArray *array = playerItem.loadedTimeRanges;
            CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
            
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            
            self.totalBuffer = startSeconds + durationSeconds;//缓冲总长度
            if(self.bufferPercentCallback){
                self.bufferPercentCallback(self,self.totalBuffer/self.totalTime);
            }
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(player:bufferPercent:)]){
                [self.delegate player:self bufferPercent:self.totalBuffer/self.totalTime];
            }
        }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]){
            if(self.bufferingCallback){
                self.bufferingCallback(self);
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(playerBuffering:)]){
                [self.delegate playerBuffering:self];
            }
        }else if([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
            if(self.bufferFinishCallback){
                self.bufferFinishCallback(self);
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(playerBufferFinish:)]){
                [self.delegate playerBufferFinish:self];
            }
        }
    }
}

#pragma mark -- 播放控制

- (void)play{
    if(self.player.rate == 1.0){
        return ;
    }
    [self.player play];
}

- (bool)isPlay{
    return self.player.rate == 1.0 ;
}

- (void)pause{
    if(self.player.rate == 0.0){
        return ;
    }
    [self.player pause];
}

- (bool)isPause{
    return self.player.rate == 0.0 ;
}

- (bool)playFinish{
    return self.currentPlayTime == self.totalTime;
}

- (void)setSeekToPosition:(float)seekToPosition{
    _seekToPosition = seekToPosition * _totalTime ;
    
    if(_seekToPosition < 0){
        _seekToPosition = 0 ;
    }
    if(_seekToPosition > _totalTime){
        _seekToPosition = _totalTime ;
    }
    
    CMTime time = CMTimeMakeWithSeconds(_seekToPosition, 600);
    
    //是否正在播放，YES ，则在seek完成之后恢复播放
    BOOL isPlay = [self isPlay];
    
    [self pause];
    
    if(self.willSeekToPosition){
        self.willSeekToPosition(self, self.curtPosition, seekToPosition);
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(playerWillSeekToPosition:curtPos:toPos:)]){
        [self.delegate playerWillSeekToPosition:self curtPos:self.curtPosition toPos:seekToPosition];
    }
    
    @weakify(self);
    [self.player seekToTime:time completionHandler:^(BOOL finish){
        @strongify(self);
        if(finish){
            if(isPlay){
                [self play];
            }
            self.currentPlayTime = time.value;
            if(self.seekCompleteCallback){
                self.seekCompleteCallback(self, self.curtPosition, seekToPosition);
            }
            if(self.delegate && [self.delegate respondsToSelector:@selector(playerSeekComplete:prePos:curtPos:)]){
                [self.delegate playerSeekComplete:self prePos:self.curtPosition curtPos:seekToPosition];
            }
        }
    }];
}

#pragma mark -- app键入前台后台

- (void)appResignActive:(NSNotification *)notification{
    if(![self playFinish]){
        [self pause];
    }
}

- (void)appBecomeActive:(NSNotification *)notification{
    if(![self playFinish]){
        [self play];
    }
}

#pragma mark -- 中断处理

- (void)handleInterruption:(NSNotification*)notification{
    NSDictionary *interruptionDictionary = [notification userInfo];
    
    AVAudioSessionInterruptionType type = [interruptionDictionary [AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    if (type == AVAudioSessionInterruptionTypeEnded){
        if([UIApplication sharedApplication].applicationState== UIApplicationStateActive) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                if(![self playFinish]){
                    [self play];
                }
            });
        }
    }else if(type == AVAudioSessionInterruptionTypeBegan){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            if(![self playFinish]){
                [self pause];
            }
        });
    }
}

/**
 *  耳机插入、拔出事件
 */
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:{
        }
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:{
            //获取上一线路描述信息并获取上一线路的输出设备类型
            AVAudioSessionRouteDescription *previousRoute = interuptionDict[AVAudioSessionRouteChangePreviousRouteKey];
            AVAudioSessionPortDescription *previousOutput = previousRoute.outputs[0];
            NSString *portType = previousOutput.portType;
            if ([portType isEqualToString:AVAudioSessionPortHeadphones]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
                    if(![self playFinish]){
                        [self play];
                    }
                });
            }
        }
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            break;
    }
}

#pragma mark -- property

- (void)setMediaUrl:(NSString *)mediaUrl{
    _mediaUrl = [mediaUrl copy];
}

- (NSString*)mediaUrl{
    if(!_mediaUrl.length){
        return @"";
    }
    return _mediaUrl;
}

@end
