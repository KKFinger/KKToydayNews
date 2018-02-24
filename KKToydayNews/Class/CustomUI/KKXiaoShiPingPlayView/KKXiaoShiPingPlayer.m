//
//  KKXiaoShiPingPlayer.m
//  KKToydayNews
//
//  Created by finger on 2017/10/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKXiaoShiPingPlayer.h"

@interface KKXiaoShiPingPlayer ()
@property(nonatomic)UIImageView *corverView;//视频封面
@end

@implementation KKXiaoShiPingPlayer

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self ;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [KKAVPlayer sharedInstance].playerLayer.frame = self.bounds;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 初始化UI

- (void)setupUI{
    [self addSubview:self.corverView];
    [self.corverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark -- 视频播放

- (void)startPlayVideo{
    
    [self destoryVideoPlayer];
    
    [self showActivityViewWithImage:@"liveroom_rotate_55x55_"];
    
    @weakify(self);
    [[KKAVPlayer sharedInstance]initPlayInfoWithUrl:self.playUrl
                                          mediaType:KKMediaTypeVideo
                                        networkType:self.netType
                                            process:^(KKAVPlayer *player,float progress)
     {
     }compelete:^(KKAVPlayer *player){
         NSLog(@"compelete");
         @strongify(self);
         [[KKAVPlayer sharedInstance].playerLayer removeFromSuperlayer];
         [[KKAVPlayer sharedInstance] releasePlayer];
         [self startPlayVideo];
     } loadStatus:^(KKAVPlayer *player, AVPlayerStatus status) {
         NSLog(@"AVPlayerStatus status:%ld",status);
         @strongify(self);
         [self hiddenActivity];
         if(self.delegate && [self.delegate respondsToSelector:@selector(videoDidPlaying)]){
             [self.delegate videoDidPlaying];
         }
     } bufferPercent:^(KKAVPlayer *player, float bufferPercent) {
         NSLog(@"bufferPercent percent:%f",bufferPercent);
     } willSeekToPosition:^(KKAVPlayer *player,CGFloat curtPos,CGFloat toPos) {
         NSLog(@"willSeekToPosition");
     } seekComplete:^(KKAVPlayer *player,CGFloat prePos,CGFloat curtPos) {
     } buffering:^(KKAVPlayer *player) {
         @strongify(self);
         [self showActivityViewWithImage:@"liveroom_rotate_55x55_"];
     } bufferFinish:^(KKAVPlayer *player) {
         @strongify(self);
         [self hiddenActivity];
     } error:^(KKAVPlayer *player, NSError *error) {
         @strongify(self);
         [self hiddenActivity];
     }];
    
    [KKAVPlayer sharedInstance].playerLayer.frame = self.bounds;
    [self.layer insertSublayer:[KKAVPlayer sharedInstance].playerLayer above:self.corverView.layer];
    [[KKAVPlayer sharedInstance]play];
}

#pragma mark -- 播放控制

- (void)pause{
    [[KKAVPlayer sharedInstance]pause];
}

- (void)resume{
    if(![KKAVPlayer sharedInstance].playerLayer.superlayer){
        [self startPlayVideo];
    }else{
        [[KKAVPlayer sharedInstance]play];
    }
}

#pragma mark -- 销毁视频播放器

- (void)destoryVideoPlayer{
    [[KKAVPlayer sharedInstance]pause];
    [[KKAVPlayer sharedInstance]releasePlayer];
}

#pragma mark -- @property setter

- (void)setPlayUrl:(NSString *)playUrl{
    if(playUrl == nil){
        _playUrl = @"";
    }else{
        _playUrl = playUrl;
    }
}

- (void)setCorverUrl:(NSString *)corverUrl{
    if(corverUrl == nil){
        corverUrl = @"";
    }
    [self.corverView sd_setImageWithURL:[NSURL URLWithString:corverUrl] placeholderImage:self.corverImage];
}

- (void)setCorverImage:(UIImage *)corverImage{
    self.corverView.image = corverImage;
}

- (UIImage *)corverImage{
    return self.corverView.image;
}

#pragma mark -- @property getter

- (UIImageView *)corverView{
    if(!_corverView){
        _corverView = ({
            UIImageView *view = [UIImageView new];
            view.userInteractionEnabled = NO ;
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _corverView;
}

@end
