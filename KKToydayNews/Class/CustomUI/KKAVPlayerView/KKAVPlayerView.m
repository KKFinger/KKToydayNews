//
//  KKAVPlayerView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/5.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKAVPlayerView.h"
#import "KKCacheSliderView.h"
#import "KKAVPlayer.h"
#import "KKFetchNewsTool.h"
#import <MediaPlayer/MediaPlayer.h>
#import "KKForwardRewindView.h"

#define SliderHeight 30

static CGFloat gestureMinimumTranslation = 10.f;

@interface KKAVPlayerView ()<UIGestureRecognizerDelegate>
@property(nonatomic)UIView *operatorView;//操作层
@property(nonatomic)UIImageView *corverView;//视频封面
@property(nonatomic)UIButton *backBtn;
@property(nonatomic)UIButton *backBtnMask;//按钮不灵敏问题
@property(nonatomic)UILabel *titleLabel;
@property(nonatomic)UILabel *playCountLabel;
@property(nonatomic)UIButton *playPauseBtn;
@property(nonatomic)UIButton *replayBtn;
@property(nonatomic)UILabel *startTimeLabel;
@property(nonatomic)KKCacheSliderView *slider;
@property(nonatomic)UILabel *endTimeLabel;
@property(nonatomic)UILabel *resolutionLabel;
@property(nonatomic)UIButton *scalaBtn;
@property(nonatomic)UIButton *scalaBtnMask;//按钮不灵敏问题
@property(nonatomic)KKCacheSliderView *bottomSlider;//底部的进度条
@property(nonatomic)KKForwardRewindView *forwardRewindView;//快进快退视图

@property(nonatomic,strong)CAGradientLayer *operatorGradient;
@property(nonatomic,strong)CAGradientLayer *corverGradient;

@property(nonatomic,strong)NSString *videoId;
@property(nonatomic,assign)BOOL sliderDraging;

@property(nonatomic,weak)UIView *parantView;//进入全屏时的父视图

@property(nonatomic,strong)UIPanGestureRecognizer *panRecognizer;//拖动视图的手势
@property(nonatomic,assign)KKMoveDirection direction;//拖动的方向

@property(nonatomic,assign)UIStatusBarStyle barStyle;

@end

@implementation KKAVPlayerView

- (instancetype)initWithTitle:(NSString *)title playCount:(NSString *)playCount coverUrl:(NSString *)coverUrl videoId:(NSString *)videoId smallType:(KKSamllVideoType)smallType{
    self = [super init];
    if(self){
        self.layer.masksToBounds = YES ;
        self.backgroundColor = [UIColor blackColor];
        self.titleLabel.text = title;
        self.playCountLabel.text = [NSString stringWithFormat:@"%@人观看",[[NSNumber numberWithInteger: [playCount longLongValue]]convert]];
        self.videoId = videoId;
        self.smallType = smallType;
        self.barStyle = [[UIApplication sharedApplication]statusBarStyle];
        self.canHideStatusBar = YES ;
        [self.corverView sd_setImageWithURL:[NSURL URLWithString:coverUrl] placeholderImage:[UIImage imageWithColor:[UIColor blackColor]]];
        [self addGestureRecognizer:self.panRecognizer];
        [self setupUI];
        [self startPlayVideo];
        [self setFullScreen:NO];
    }
    return self ;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    if(iPhoneX){
        if(self.smallType == KKSamllVideoTypeDetail){
            if(self.fullScreen){
                frame = CGRectMake(KKStatusBarHeight, 0, self.bounds.size.width - KKStatusBarHeight, self.bounds.size.height);
            }else{
                frame = CGRectMake(0, KKStatusBarHeight, self.bounds.size.width, self.bounds.size.height - KKStatusBarHeight);
            }
        }else{
            if(self.fullScreen){
                frame = CGRectMake(KKStatusBarHeight, 0, self.bounds.size.width - KKStatusBarHeight, self.bounds.size.height);
            }
        }
    }
    self.corverView.frame = frame;
    self.operatorView.frame = frame;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.operatorGradient.frame = CGRectMake(0, 0, self.operatorView.width, self.operatorView.height);
    self.corverGradient.frame = CGRectMake(0, 0, self.corverView.width, self.corverView.height);
    [KKAVPlayer sharedInstance].playerLayer.frame = frame;
    [CATransaction commit];
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 初始化UI

- (void)setupUI{
    [self addSubview:self.corverView];
    [self addSubview:self.operatorView];
    [self addSubview:self.bottomSlider];
    [self addSubview:self.replayBtn];
    [self addSubview:self.forwardRewindView];
    [self.operatorView addSubview:self.titleLabel];
    [self.operatorView addSubview:self.backBtn];
    [self.operatorView addSubview:self.backBtnMask];
    [self.operatorView addSubview:self.playCountLabel];
    [self.operatorView addSubview:self.playPauseBtn];
    [self.operatorView addSubview:self.startTimeLabel];
    [self.operatorView addSubview:self.slider];
    [self.operatorView addSubview:self.endTimeLabel];
    [self.operatorView addSubview:self.resolutionLabel];
    [self.operatorView addSubview:self.scalaBtn];
    [self.operatorView addSubview:self.scalaBtnMask];
    
    @weakify(self);
    [self addTapGestureWithBlock:^(UIView *gestureView) {
        @strongify(self);
        if([[KKAVPlayer sharedInstance]playFinish]){
            return  ;
        }
        CGFloat alpha = 1 - self.operatorView.alpha;
        if(self.fullScreen || (self.smallType == KKSamllVideoTypeDetail && self.canHideStatusBar)){
            if(iPhoneX){
                [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            }else{
                [[UIApplication sharedApplication]setStatusBarHidden:(alpha == 0) withAnimation:UIStatusBarAnimationFade];
            }
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.operatorView.alpha = alpha;
            self.bottomSlider.alpha = 1 - alpha;
        }completion:^(BOOL finished) {
            if(alpha == 1){
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideoperatorView) object:nil];
                [self performSelector:@selector(autoHideoperatorView) withObject:nil afterDelay:3.0];
            }
        }];
    }];
    
    [self.operatorView.layer insertSublayer:self.operatorGradient atIndex:0];
    [self.corverView.layer insertSublayer:self.corverGradient atIndex:0];
    
    [self.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.operatorView).mas_offset(kkPaddingNormal).priority(998);
        make.top.mas_equalTo(self.operatorView).mas_offset(iPhoneX ? 0 : kkPaddingNormal);
        make.width.mas_equalTo(0);
        make.height.mas_equalTo(20);
    }];
    [self.backBtnMask mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.left.mas_equalTo(self.operatorView);
        make.top.mas_equalTo(self.operatorView).mas_offset(20);
    }];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.operatorView).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self.backBtn.mas_right).mas_offset(5);
        make.right.mas_equalTo(self.operatorView).mas_offset(-kkPaddingNormal);
        make.height.mas_equalTo(20);
    }];
    [self.playCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(self.titleLabel);
        make.width.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(20);
    }];
    [self.playPauseBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.operatorView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.replayBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.scalaBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.operatorView);
        make.bottom.mas_equalTo(self.operatorView).mas_offset(-3);
        make.width.height.mas_equalTo(30);
    }];
    [self.scalaBtnMask mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(44);
        make.right.bottom.mas_equalTo(self.operatorView);
    }];
    [self.resolutionLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.scalaBtn.mas_left).mas_offset(-5);
        make.centerY.mas_equalTo(self.scalaBtn);
        make.height.mas_equalTo(20);
    }];
    [self.endTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.resolutionLabel.mas_left).mas_offset(-5);
        make.centerY.mas_equalTo(self.scalaBtn);
        make.height.mas_equalTo(20);
    }];
    [self.slider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.endTimeLabel.mas_left).mas_offset(-12).priority(998);
        make.centerY.mas_equalTo(self.scalaBtn);
        make.height.mas_equalTo(SliderHeight);
    }];
    [self.startTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.operatorView).mas_offset(kkPaddingNormal).priority(998);
        make.centerY.mas_equalTo(self.scalaBtn);
        make.right.mas_equalTo(self.slider.mas_left).mas_offset(-12).priority(998);
        make.height.mas_equalTo(20);
    }];
    [self.bottomSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.operatorView).mas_offset(0);
        make.left.mas_equalTo(self.operatorView);
        make.right.mas_equalTo(self.operatorView);
        make.height.mas_equalTo(2);
    }];
    [self.forwardRewindView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.operatorView);
        make.width.mas_equalTo(130);
        make.height.mas_equalTo(90);
    }];
}

#pragma mark -- 视频播放

- (void)startPlayVideo{
    self.operatorView.alpha = 0 ;
    self.bottomSlider.alpha = 1.0;
    self.replayBtn.alpha = 0;
    
    [self showActivityViewWithImage:@"loading_fullscreen_30x30_"];
    
    [[KKFetchNewsTool shareInstance]fetchVideoInfoWithVideoId:self.videoId
                                                      success:^(KKVideoPlayInfo *playInfo)
     {
         if(playInfo){
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSString *url = playInfo.poster_url;
                 if(!url.length){
                     url = @"";
                 }
                 @weakify(self);
                 [[KKAVPlayer sharedInstance]initPlayInfoWithUrl:playInfo.video_list.video_1.main_url
                                                       mediaType:KKMediaTypeVideo
                                                     networkType:KKNetworkTypeNet
                                                         process:^(KKAVPlayer *player, float progress)
                  {
                      @strongify(self);
                      if(!self.sliderDraging){
                          self.slider.value = progress;
                          self.startTimeLabel.text =  [NSString getHHMMSSFromSS:[NSString stringWithFormat:@"%f",player.currentPlayTime]];
                          self.bottomSlider.value = progress;
                      }
                  } compelete:^(KKAVPlayer *player) {
                      NSLog(@"compelete");
                      @strongify(self);
                      [[KKAVPlayer sharedInstance].playerLayer removeFromSuperlayer];
                      [[KKAVPlayer sharedInstance] releasePlayer];
                      
                      self.operatorView.alpha = 0;
                      self.bottomSlider.alpha = 1.0 ;
                      self.replayBtn.alpha = 1.0;
                      self.corverView.hidden = NO ;
                      
                      if(self.fullScreen){
                          [self quitFullScreen];
                      }
                  } loadStatus:^(KKAVPlayer *player, AVPlayerStatus status) {
                      NSLog(@"AVPlayerStatus status:%ld",status);
                      @strongify(self);
                      if(status == AVPlayerStatusFailed){
                          [[KKAVPlayer sharedInstance].playerLayer removeFromSuperlayer];
                          [[KKAVPlayer sharedInstance] releasePlayer];
                          self.operatorView.alpha = 0;
                          self.bottomSlider.alpha = 1.0 ;
                          self.replayBtn.alpha = 1.0;
                          self.corverView.hidden = NO ;
                      }else if(status == AVPlayerStatusReadyToPlay){
                          self.playPauseBtn.selected = YES ;
                          self.corverView.hidden = YES ;
                      }
                      
                      self.startTimeLabel.text = @"00:00";
                      self.endTimeLabel.text =  [NSString getHHMMSSFromSS:[NSString stringWithFormat:@"%f",player.totalTime]];
                      
                      [self hiddenActivityWithTitle:nil];
                      
                  } bufferPercent:^(KKAVPlayer *player, float bufferPercent) {
                      NSLog(@"bufferPercent percent:%f",bufferPercent);
                      @strongify(self);
                      self.slider.cachaValue = bufferPercent;
                      self.bottomSlider.cachaValue = bufferPercent;
                  } willSeekToPosition:^(KKAVPlayer *player,CGFloat curtPos,CGFloat toPos) {
                      NSLog(@"willSeekToPosition");
                  } seekComplete:^(KKAVPlayer *player,CGFloat prePos,CGFloat curtPos) {
                      @strongify(self);
                      self.sliderDraging = NO ;
                  } buffering:^(KKAVPlayer *player) {
                      @strongify(self);
                      [self showActivityViewWithImage:@"loading_fullscreen_30x30_"];
                  } bufferFinish:^(KKAVPlayer *player) {
                      @strongify(self);
                      [self hiddenActivityWithTitle:nil];
                  } error:^(KKAVPlayer *player, NSError *error) {
                      @strongify(self);
                      self.operatorView.alpha = 0;
                      self.bottomSlider.alpha = 1.0 ;
                      self.replayBtn.alpha = 1.0;
                      [self hiddenActivityWithTitle:nil];
                  }];
                 
                 [self.layer insertSublayer:[KKAVPlayer sharedInstance].playerLayer above:self.corverView.layer];
                 [[KKAVPlayer sharedInstance]play];
             });
         }else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.operatorView.alpha = 0 ;
                 self.bottomSlider.alpha = 1.0;
                 self.replayBtn.alpha = 1.0;
                 [self hiddenActivityWithTitle:nil];
             });
         }
     } failure:^(NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             self.operatorView.alpha = 0 ;
             self.bottomSlider.alpha = 1.0;
             self.replayBtn.alpha = 1.0;
             [self hiddenActivityWithTitle:nil];
         });
     }];
}

#pragma mark -- 销毁视频播放器

- (void)destoryVideoPlayer{
    [[KKAVPlayer sharedInstance]pause];
    [[KKAVPlayer sharedInstance]releasePlayer];
    self.videoId = nil ;
    [self removeFromSuperview];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoHideoperatorView) object:nil];
}

#pragma mark -- 进入、退出全屏

- (void)enterFullScreen{
    if (self.fullScreen) {
        return;
    }
    self.fullScreen = YES ;
    self.parantView = self.superview;
    
    CGRect rectInWindow = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
    [self removeFromSuperview];
    [self setFrame:rectInWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        self.bounds = CGRectMake(0, 0, CGRectGetHeight(self.superview.bounds), CGRectGetWidth(self.superview.bounds));
        self.center = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds));
    } completion:^(BOOL finished) {
    }];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(enterFullScreen)]){
        [self.delegate enterFullScreen];
    }
}

- (void)quitFullScreen{
    if (!self.fullScreen) {
        return;
    }
    self.fullScreen = NO ;
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
    
    CGRect frame = [self.parantView convertRect:self.originalFrame toView:[UIApplication sharedApplication].keyWindow];
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformIdentity;
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self setFrame:self.originalFrame];
        [self.parantView addSubview:self];
    }];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(quitFullScreen)]){
        [self.delegate quitFullScreen];
    }
}

#pragma mark -- 视频播放暂停

- (void)playOrPauseVideo{
    BOOL isPlay = self.playPauseBtn.selected;
    if(isPlay){
        [[KKAVPlayer sharedInstance]pause];
    }else{
        [[KKAVPlayer sharedInstance]play];
    }
    self.playPauseBtn.selected = !isPlay;
}

#pragma mark -- 拖动手势

- (void)panRecognizer:(UIPanGestureRecognizer *)panRecognizer{
    UIGestureRecognizerState state = panRecognizer.state;
    CGPoint point = [panRecognizer translationInView:self];
    if(state == UIGestureRecognizerStateChanged){
        if([[KKAVPlayer sharedInstance]playFinish]){
            return ;
        }
        if(!self.fullScreen){
            return;
        }
        if(self.direction == KKMoveDirectionNone){
            self.direction = [self determineDirection:point];
        }
        if(self.direction == KKMoveDirectionUp ||
           self.direction == KKMoveDirectionDown){
            CGFloat offsetY = self.centerY + point.y;
            CGFloat volume = [self getSystemVolumValue];
            volume += (self.centerY - offsetY) / self.centerY ;
            [self setSysVolumWith:volume];
            
            [panRecognizer setTranslation:CGPointMake(0, 0) inView:self];
            
        }else if(self.direction == KKMoveDirectionLeft||
                 self.direction == KKMoveDirectionRight){
            self.sliderDraging = YES ;
            
            CGFloat offsetX = self.centerX + point.x;
            CGFloat value = self.bottomSlider.value;
            value += (offsetX - self.centerX) / self.centerX;
            if(value < 0){
                value = 0 ;
            }
            if(value > 1){
                value = 1;
            }
            CGFloat time = value * [[KKAVPlayer sharedInstance]totalTime];
            NSString *timeStr = [NSString getHHMMSSFromSS:[NSString stringWithFormat:@"%f",time]];
            
            self.forwardRewindView.isForward = (value > self.forwardRewindView.percent);
            self.forwardRewindView.percent = value;
            self.forwardRewindView.hidden = NO ;
            self.forwardRewindView.curtTime = [NSString stringWithFormat:@"%@ ",timeStr];
            self.forwardRewindView.totalTime = self.endTimeLabel.text;
            self.slider.value = value;
            self.bottomSlider.value = value;
            self.startTimeLabel.text = timeStr;
            
            [panRecognizer setTranslation:CGPointMake(0, 0) inView:self];
        }
        
    }else if(state == UIGestureRecognizerStateEnded ||
             state == UIGestureRecognizerStateFailed ||
             state == UIGestureRecognizerStateCancelled){
        if(self.direction == KKMoveDirectionUp ||
           self.direction == KKMoveDirectionDown){
        }else if(self.direction == KKMoveDirectionLeft ||
                 self.direction == KKMoveDirectionRight){
            self.forwardRewindView.hidden = YES;
            self.sliderDraging = NO ;
            [KKAVPlayer sharedInstance].seekToPosition = self.slider.value;
        }
    }else if(state == UIGestureRecognizerStateBegan){
        self.direction = KKMoveDirectionNone;
    }
}

- (KKMoveDirection)determineDirection:(CGPoint)translation{
    if (self.direction != KKMoveDirectionNone){
        return self.direction;
    }
    if (fabs(translation.x) > gestureMinimumTranslation){
        BOOL gestureHorizontal = NO;
        if (translation.y ==0.0){
            gestureHorizontal = YES;
        }else{
            gestureHorizontal = (fabs(translation.x / translation.y) >5.0);
        }
        if (gestureHorizontal){
            if (translation.x >0.0){
                return KKMoveDirectionRight;
            }else{
                return KKMoveDirectionLeft;
            }
        }
    }else if (fabs(translation.y) > gestureMinimumTranslation){
        BOOL gestureVertical = NO;
        if (translation.x ==0.0){
            gestureVertical = YES;
        }else{
            gestureVertical = (fabs(translation.y / translation.x) >5.0);
        }
        if (gestureVertical){
            if (translation.y >0.0){
                return KKMoveDirectionDown;
            }else{
                return KKMoveDirectionUp;
            }
        }
    }
    return self.direction;
}

#pragma mark -- 音量控制

/*
 *获取系统音量滑块
 */
-(UISlider*)getSystemVolumSlider{
    static UISlider * volumeViewSlider = nil;
    
    if (volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-1000, -1000, 200, 4)];
        volumeView.hidden = NO ;
        for (UIView* newView in volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)newView;
                break;
            }
        }
    }
    
    return volumeViewSlider;
}
/*
 *获取系统音量大小
 */
-(CGFloat)getSystemVolumValue{
    return [[self getSystemVolumSlider] value];
}
/*
 *设置系统音量大小
 */
-(void)setSysVolumWith:(double)value{
    [self getSystemVolumSlider].value = value;
}

#pragma mark -- 滑块事件

- (void)sliderValueChanged:(UISlider *)slider{
    self.sliderDraging = YES ;
    CGFloat curtPlayTime = slider.value * [KKAVPlayer sharedInstance].totalTime ;
    self.startTimeLabel.text =  [NSString getHHMMSSFromSS:[NSString stringWithFormat:@"%f",curtPlayTime]];
}

- (void)sliderTouchDown:(UISlider *)slider{
}

- (void)sliderTouchUpInSide:(UISlider *)slider{
    if(slider.value != self.bottomSlider.value){//进度发生了改变
        [KKAVPlayer sharedInstance].seekToPosition = slider.value;
    }
}

#pragma mark -- 全屏或者竖屏按钮事件

- (void)scalaView{
    if(self.fullScreen){
        [self quitFullScreen];
    }else{
        [self enterFullScreen];
    }
}

#pragma mark -- 回退按钮

- (void)backBtnClicked{
    if(self.smallType == KKSamllVideoTypeDetail){
        if(self.fullScreen){
            [self quitFullScreen];
        }else{
            [self destoryVideoPlayer];
            if(self.delegate && [self.delegate respondsToSelector:@selector(quitVideoDetailView)]){
                [self.delegate quitVideoDetailView];
            }
        }
    }else{
        [self quitFullScreen];
    }
}

#pragma mark -- 重新播放

- (void)replayVideo{
    [self startPlayVideo];
}

#pragma mark -- 分享视频

- (void)shareVideo{
    
}

#pragma mark -- 自动隐藏操作图层

- (void)autoHideoperatorView{
    if(!self.sliderDraging && self.videoId.length){
        self.operatorView.alpha = 0.0;
        self.bottomSlider.alpha = 1.0;
        if(self.fullScreen || (self.smallType == KKSamllVideoTypeDetail && self.canHideStatusBar)){
            if(iPhoneX){
                [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            }else{
                [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            }
        }
    }
}

#pragma mark -- @property setter

- (void)setFullScreen:(BOOL)fullScreen{
    _fullScreen = fullScreen;
    if(_fullScreen){
        [self.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(12);
            make.top.mas_equalTo(self.operatorView).mas_offset(20);
        }];
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.operatorView).mas_offset(20);
            make.left.mas_equalTo(self.backBtn.mas_right).mas_offset(5);
            make.height.mas_equalTo(20);
        }];
        
        [self.bottomSlider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.operatorView).mas_offset(-1);
        }];
        
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.hidden = NO ;
        self.playCountLabel.hidden = NO ;
        self.backBtn.hidden = NO ;
        
    }else{
        [self.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            if(self.smallType == KKSamllVideoTypeDetail){
                make.width.mas_equalTo(12);
                make.top.mas_equalTo(self.operatorView).mas_offset(iPhoneX ? 0 : 20);
            }else{
                make.width.mas_equalTo(0);
                make.top.mas_equalTo(self.operatorView).mas_offset(kkPaddingNormal);
            }
        }];
        
        [self.bottomSlider mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.operatorView).mas_offset(0);
        }];
        
        CGFloat width = MIN(UIDeviceScreenWidth,UIDeviceScreenHeight);
        NSDictionary *dic = @{NSFontAttributeName:self.titleLabel.font};
        CGSize size = [self.titleLabel.text boundingRectWithSize:CGSizeMake(width - 2 * kkPaddingNormal, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
        if(size.height >= 2 * self.titleLabel.font.lineHeight){
            size.height = 2 * self.titleLabel.font.lineHeight + 5;
        }else{
            size.height = 20 ;
        }
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            if(self.smallType == KKSamllVideoTypeDetail){
                make.top.mas_equalTo(self.operatorView).mas_offset(iPhoneX ? 0 : 20);
            }else{
                make.top.mas_equalTo(self.operatorView).mas_offset(kkPaddingNormal);
            }
            make.height.mas_equalTo(size.height);
            make.left.mas_equalTo(self.backBtn.mas_right).mas_offset(0);
        }];
        
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        if(self.smallType == KKSamllVideoTypeVideoCatagory){
            self.titleLabel.hidden = NO ;
            self.backBtn.hidden = YES ;
            self.playCountLabel.hidden = NO ;
        }else if(self.smallType == KKSamllVideoTypeDetail){
            self.titleLabel.hidden = YES ;
            self.backBtn.hidden = NO ;
            self.playCountLabel.hidden = YES ;
        }else{
            self.titleLabel.hidden = YES ;
            self.backBtn.hidden = YES;
            self.playCountLabel.hidden = YES ;
        }
    }
    
    self.scalaBtn.selected = _fullScreen;
    self.panRecognizer.enabled = self.fullScreen;//避免小屏播放时和tableview的手势冲突
}

- (void)setOriginalFrame:(CGRect)originalFrame{
    _originalFrame = originalFrame;
    [self setFrame:originalFrame];
}

- (void)setSmallType:(KKSamllVideoType)smallType{
    _smallType = smallType;
    if(self.fullScreen){
        return ;
    }
    if(self.smallType == KKSamllVideoTypeVideoCatagory){
        self.titleLabel.hidden = NO ;
        self.backBtn.hidden = YES ;
        self.playCountLabel.hidden = NO ;
    }else if(self.smallType == KKSamllVideoTypeDetail){
        self.titleLabel.hidden = YES ;
        self.backBtn.hidden = NO ;
        self.playCountLabel.hidden = YES ;
    }else{
        self.titleLabel.hidden = YES ;
        self.backBtn.hidden = YES;
        self.playCountLabel.hidden = YES ;
    }
}

- (void)setCanHideStatusBar:(BOOL)canHideStatusBar{
    _canHideStatusBar = canHideStatusBar;
    if(canHideStatusBar){
        if(self.fullScreen || (self.smallType == KKSamllVideoTypeDetail)){
            [[UIApplication sharedApplication]setStatusBarHidden:(self.operatorView.alpha == 0) withAnimation:NO];
        }
    }else{
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    }
}

#pragma mark -- @property getter

- (UIView *)operatorView{
    if(!_operatorView){
        _operatorView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor clearColor];
            view.alpha = 0.0 ;
            view;
        });
    }
    return _operatorView;
}

- (UIImageView *)corverView{
    if(!_corverView){
        _corverView = ({
            UIImageView *view = [UIImageView new];
            view.userInteractionEnabled = NO ;
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _corverView;
}

- (UIButton *)backBtn{
    if(!_backBtn){
        _backBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"backItem"] forState:UIControlStateNormal];
            [view setImage:[[UIImage imageNamed:@"backItem"] imageWithAlpha:0.5] forState:UIControlStateHighlighted];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
            [view addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _backBtn;
}

- (UIButton *)backBtnMask{
    if(!_backBtnMask){
        _backBtnMask = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _backBtnMask;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor whiteColor];
            view.font = KKTitleFont;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.numberOfLines = 0 ;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _titleLabel;
}

- (UILabel *)playCountLabel{
    if(!_playCountLabel){
        _playCountLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor whiteColor];
            view.font = KKDescFont;
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _playCountLabel;
}

- (UIButton *)playPauseBtn{
    if(!_playPauseBtn){
        _playPauseBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"new_play_video_60x60_"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"new_pause_video_60x60_"] forState:UIControlStateSelected];
            [view addTarget:self action:@selector(playOrPauseVideo) forControlEvents:UIControlEventTouchUpInside];
            [view setSelected:NO];
            view ;
        });
    }
    return _playPauseBtn;
}

- (UIButton *)replayBtn{
    if(!_replayBtn){
        _replayBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"new_play_video_60x60_"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(startPlayVideo) forControlEvents:UIControlEventTouchUpInside];
            [view setSelected:NO];
            view ;
        });
    }
    return _replayBtn;
}

- (UILabel *)startTimeLabel{
    if(!_startTimeLabel){
        _startTimeLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:11];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view ;
        });
    }
    return _startTimeLabel;
}

- (KKCacheSliderView *)slider{
    if(!_slider){
        _slider = ({
            KKCacheSliderView *view = [ [ KKCacheSliderView alloc ] initWithFrame:CGRectZero];
            view.minimumValue = 0.0;
            view.maximumValue = 1.0;
            view.value = 0.0;
            view.cacheColor = [UIColor clearColor];
            view.cachaValue = 0.0;
            view.minimumTrackTintColor = [UIColor redColor];
            view.maximumTrackTintColor = [UIColor whiteColor];
            [view addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [view addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
            [view addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchUpInside];
            [view addTarget:self action:@selector(sliderTouchUpInSide:) forControlEvents:UIControlEventTouchCancel];
            [view setThumbImage:[UIImage imageNamed:@"dot"] forState:UIControlStateNormal];
            view;
        });
    }
    return _slider;
}

- (UILabel *)endTimeLabel{
    if(!_endTimeLabel){
        _endTimeLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:11];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view ;
        });
    }
    return _endTimeLabel;
}

- (UILabel *)resolutionLabel{
    if(!_resolutionLabel){
        _resolutionLabel = ({
            UILabel *view  = [UILabel new];
            view.text = @"标清";
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:11];
            view.textAlignment = NSTextAlignmentCenter;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view;
        });
    }
    return _resolutionLabel;
}

- (UIButton *)scalaBtn{
    if(!_scalaBtn){
        _scalaBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"player_fullscreen"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"player_portialscreen"] forState:UIControlStateSelected];
            [view addTarget:self action:@selector(scalaView) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _scalaBtn;
}

- (UIButton *)scalaBtnMask{
    if(!_scalaBtnMask){
        _scalaBtnMask = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view addTarget:self action:@selector(scalaView) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _scalaBtnMask;
}

- (KKCacheSliderView *)bottomSlider{
    if(!_bottomSlider){
        _bottomSlider = ({
            KKCacheSliderView *view = [ [ KKCacheSliderView alloc ] initWithFrame:CGRectZero];
            view.minimumValue = 0.0;
            view.maximumValue = 1.0;
            view.value = 0.0;
            view.cacheColor = [UIColor clearColor];
            view.minimumTrackTintColor = [UIColor redColor];
            view.maximumTrackTintColor = [UIColor whiteColor];
            [view setThumbImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
            view.alpha = 1.0 ;
            view;
        });
    }
    return _bottomSlider;
}

- (CAGradientLayer *)operatorGradient{
    if(!_operatorGradient){
        _operatorGradient = [CAGradientLayer layer];
        _operatorGradient.colors = @[(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.5].CGColor, (__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.3].CGColor,(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.1].CGColor,(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.3].CGColor,(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.5].CGColor];
        _operatorGradient.startPoint = CGPointMake(0, 0);
        _operatorGradient.endPoint = CGPointMake(0.0, 1.0);
    }
    return _operatorGradient;
}

- (CAGradientLayer *)corverGradient{
    if(!_corverGradient){
        _corverGradient = [CAGradientLayer layer];
        _corverGradient.colors = @[(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.5].CGColor, (__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.3].CGColor,(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.1].CGColor,(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.3].CGColor,(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.5].CGColor];
        _corverGradient.startPoint = CGPointMake(0, 0);
        _corverGradient.endPoint = CGPointMake(0.0, 1.0);
    }
    return _corverGradient;
}

- (UIPanGestureRecognizer *)panRecognizer{
    if(!_panRecognizer){
        _panRecognizer = ({
            UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
            recognizer.delegate = self ;
            recognizer;
        });
    }
    return _panRecognizer;
}

- (KKForwardRewindView *)forwardRewindView{
    if(!_forwardRewindView){
        _forwardRewindView = ({
            KKForwardRewindView *view = [KKForwardRewindView new];
            view.hidden = YES;
            view.layer.cornerRadius = 5 ;
            view ;
        });
    }
    return _forwardRewindView;
}

@end
