//
//  KKRecordPreview.m
//  KKToydayNews
//
//  Created by finger on 2017/11/5.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKRecordPreview.h"
#import "KKTextView.h"
#import "KKAVPlayer.h"
#import "KKEditRecordCorverView.h"
#import "KKVideoCompressTool.h"

static CGFloat topViewHeight = 55 ;

@interface KKRecordPreview()
@property(nonatomic)UIButton *backBtn;
@property(nonatomic)UILabel *titleLabel;
@property(nonatomic)UIButton *pushBtn;
@property(nonatomic)UIView *recPlayView;
@property(nonatomic)UIImageView *recCorverView;
@property(nonatomic)UIButton *playBtn;
@property(nonatomic)UILabel *detailLabel;
@property(nonatomic)UIButton *editCorverBtn;
@property(nonatomic)KKTextView *recTitleView;
@property(nonatomic)CAGradientLayer *bottomGradient;
@property(nonatomic)UIView *keyboardMaskView;
@property(nonatomic)KKVideoInfo *videoInfo;
@end

@implementation KKRecordPreview

- (instancetype)initWithVideoInfo:(KKVideoInfo *)videoInfo{
    self = [super init];
    if(self){
        self.enableFreedomDrag = NO ;
        self.enableHorizonDrag = YES ;
        self.enableVerticalDrag = YES ;
        self.videoInfo = videoInfo;
    }
    return self ;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[KKAVPlayer sharedInstance]releasePlayer];
}

- (void)viewWillAppear{
    [super viewWillAppear];
    [self setupUI];
    // 添加对键盘的监控
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [KKAppTools clearFileAtFolder:KKVideoCompressFileFolder];
    if(self.viewWillDisapear){
        self.viewWillDisapear();
    }
}

- (void)viewDidAppear{
    [super viewDidAppear];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.recPlayView animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"正在压缩";
    
    @weakify(self);
    [[KKVideoCompressTool sharedInstance]compressVideoWithFilePath:self.videoInfo.filePath
                                                       storeFolder:KKVideoCompressFileFolder
                                                          fileName:[NSString getNowTimeTimestamp]
                                                   compressQuality:AVAssetExportPresetMediumQuality
                                                  progressCallback:^(CGFloat progress)
    {
        hud.progress = progress;
    } completeCallback:^(KKVideoInfo *videoInfo) {
        @strongify(self);
        [hud hideAnimated:YES];
        self.videoInfo = videoInfo ;
        self.detailLabel.text = [NSString stringWithFormat:@"%@  %@",self.videoInfo.formatDuration,self.videoInfo.formatSize];
        self.recCorverView.image = self.videoInfo.videoCorver;
        [self startPlayVideo];
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [UIView performWithoutAnimation:^{
        self.bottomGradient.frame = CGRectMake(0, self.recPlayView.height - 100, self.recPlayView.width, 100);
        [KKAVPlayer sharedInstance].playerLayer.frame = self.recPlayView.bounds;
    }];
}

#pragma mark -- UI

- (void)setupUI{
    [self.dragContentView setBackgroundColor:[UIColor whiteColor]];
    [self.dragContentView addSubview:self.backBtn];
    [self.dragContentView addSubview:self.titleLabel];
    [self.dragContentView addSubview:self.pushBtn];
    [self.dragContentView addSubview:self.recPlayView];
    [self.dragContentView addSubview:self.recTitleView];
    [self.dragContentView addSubview:self.keyboardMaskView];
    [self.recPlayView addSubview:self.recCorverView];
    [self.recPlayView addSubview:self.playBtn];
    [self.recPlayView addSubview:self.detailLabel];
    [self.recPlayView addSubview:self.editCorverBtn];
    [self.recCorverView.layer insertSublayer:self.bottomGradient below:self.detailLabel.layer];
    
    [self.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView).mas_offset(5);
        make.centerY.mas_equalTo(self.dragContentView.mas_top).mas_offset(topViewHeight / 2.0 + 8);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.dragContentView);
        make.centerY.mas_equalTo(self.backBtn);
    }];
    
    [self.pushBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.dragContentView).mas_offset(-kkPaddingNormal);
        make.centerY.mas_equalTo(self.backBtn);
    }];
    
    [self.recPlayView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView);
        make.top.mas_equalTo(self.dragContentView).mas_offset(topViewHeight);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenWidth));
    }];
    
    [self.recCorverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.recPlayView);
    }];
    
    [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.recPlayView);
    }];
    
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.editCorverBtn);
        make.left.mas_equalTo(self.recPlayView).mas_offset(kkPaddingNormal);
    }];
    
    [self.editCorverBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.recPlayView).mas_offset(-kkPaddingNormal);
        make.bottom.mas_equalTo(self.recPlayView).mas_offset(-kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(65, 30));
    }];
    
    [self.recTitleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.recPlayView.mas_bottom);
        make.left.mas_equalTo(self.recPlayView);
        make.width.mas_equalTo(self.recPlayView);
        make.height.mas_equalTo(40);
    }];
    
    [self.keyboardMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.recTitleView.mas_top);
    }];
    
    [self layoutIfNeeded];
}

#pragma mark -- 视频播放

- (void)startPlayVideo{
    
    [self destoryVideoPlayer];
    
    [self.recPlayView showActivityViewWithImage:@"liveroom_rotate_55x55_"];
    
    @weakify(self);
    [[KKAVPlayer sharedInstance]initPlayInfoWithUrl:self.videoInfo.filePath
                                          mediaType:KKMediaTypeVideo
                                        networkType:KKNetworkTypeLocal
                                            process:^(KKAVPlayer *player,float progress)
     {
     }compelete:^(KKAVPlayer *player){
         NSLog(@"compelete");
         @strongify(self);
         [[KKAVPlayer sharedInstance].playerLayer removeFromSuperlayer];
         [[KKAVPlayer sharedInstance] releasePlayer];
         [self.playBtn setHidden:NO];
     } loadStatus:^(KKAVPlayer *player, AVPlayerStatus status) {
         NSLog(@"AVPlayerStatus status:%ld",status);
         @strongify(self);
         [self.recPlayView hiddenActivity];
         if(status != AVPlayerStatusReadyToPlay){
             [self.playBtn setHidden:NO];
         }
     } bufferPercent:^(KKAVPlayer *player, float bufferPercent) {
         NSLog(@"bufferPercent percent:%f",bufferPercent);
     } willSeekToPosition:^(KKAVPlayer *player,CGFloat curtPos,CGFloat toPos) {
         NSLog(@"willSeekToPosition");
     } seekComplete:^(KKAVPlayer *player,CGFloat prePos,CGFloat curtPos) {
     } buffering:^(KKAVPlayer *player) {
         @strongify(self);
         [self.recPlayView showActivityViewWithImage:@"liveroom_rotate_55x55_"];
     } bufferFinish:^(KKAVPlayer *player) {
         @strongify(self);
         [self.recPlayView hiddenActivity];
     } error:^(KKAVPlayer *player, NSError *error) {
         @strongify(self);
         [self.recPlayView hiddenActivity];
         [self.playBtn setHidden:NO];
     }];
    
    [KKAVPlayer sharedInstance].playerLayer.frame = self.recPlayView.bounds;
    [self.recPlayView.layer insertSublayer:[KKAVPlayer sharedInstance].playerLayer above:self.recCorverView.layer];
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

#pragma mark -- 返回按钮

- (void)backBtnClicked{
    [self pushOutToRight:YES];
}

#pragma mark -- 发布按钮

- (void)pushBtnClicked{
    
}

#pragma mark -- 编辑封面

- (void)editCorverBtnClicked{
    [[KKAVPlayer sharedInstance]releasePlayer];
    
    KKEditRecordCorverView *view = [[KKEditRecordCorverView alloc]initWithVideoInfo:self.videoInfo];
    view.topSpace = 0 ;
    view.contentViewCornerRadius = 0 ;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [view pushIn];
}

#pragma mark -- 键盘的显示和隐藏

- (void)keyBoardWillShow:(NSNotification *) note {
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    self.keyboardMaskView.hidden = NO ;
    
    CGFloat offsetY = keyboardHeight - (self.dragContentView.height - self.recTitleView.bottom);
    if(offsetY <= 0 ){
        offsetY = 0 ;
    }
    void (^animation)(void) = ^void(void) {
        self.dragContentView.transform = CGAffineTransformMakeTranslation(0, -offsetY);
    };
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation];
    } else {
        animation();
    }
}

- (void)keyBoardWillHide:(NSNotification *) note {
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    void (^animation)(void) = ^void(void) {
        self.dragContentView.transform = CGAffineTransformIdentity;
    };
    
    self.keyboardMaskView.hidden = YES ;
    
    if (animationTime > 0) {
        [UIView animateWithDuration:animationTime animations:animation completion:^(BOOL finished) {
        }];
    } else {
        animation();
    }
}

#pragma mark -- @property

- (UIButton *)backBtn{
    if(!_backBtn){
        _backBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"lefterbackicon_titlebar_24x24_"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _backBtn;
}

- (UIButton *)pushBtn{
    if(!_pushBtn){
        _pushBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"发布" forState:UIControlStateNormal];
            [view setTitleColor:KKColor(0, 128, 216, 1) forState:UIControlStateNormal];
            [view addTarget:self action:@selector(pushBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _pushBtn;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.text = @"完善视频信息";
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentCenter;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view ;
        });
    }
    return _titleLabel;
}

- (UIView *)recPlayView{
    if(!_recPlayView){
        _recPlayView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor blackColor];
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                BOOL isPlay = !self.playBtn.hidden;//YES 播放 NO 暂停
                if(isPlay){
                    [self resume];
                }else{
                    [self pause];
                }
                self.playBtn.hidden = isPlay;
            }];
            
            view ;
        });
    }
    return _recPlayView;
}

- (UIImageView *)recCorverView{
    if(!_recCorverView){
        _recCorverView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _recCorverView;
}

- (UIButton *)playBtn{
    if(!_playBtn){
        _playBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"new_play_video_44x44_"] forState:UIControlStateNormal];
            [view setUserInteractionEnabled:NO];
            [view setHidden:YES];
            view;
        });
    }
    return _playBtn;
}

- (UILabel *)detailLabel{
    if(!_detailLabel){
        _detailLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:13];
            view.textColor = [UIColor whiteColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view ;
        });
    }
    return _detailLabel;
}

- (UIButton *)editCorverBtn{
    if(!_editCorverBtn){
        _editCorverBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"编辑封面" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [view setBackgroundImage:[UIImage imageWithColor:KKColor(0, 128, 216, 1)] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(editCorverBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [view.layer setCornerRadius:5];
            [view.layer setMasksToBounds:YES];
            [view.titleLabel setFont:[UIFont systemFontOfSize:14]];
            view;
        });
    }
    return _editCorverBtn;
}

- (KKTextView *)recTitleView{
    if(!_recTitleView){
        _recTitleView = ({
            KKTextView *view = [KKTextView new];
            view.placeholder = @"请输入标题(30字以内)";
            view.borderType = KKBorderTypeBottom;
            view.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.3];
            view.borderThickness = 0.3;
            view ;
        });
    }
    return _recTitleView;
}

- (CAGradientLayer *)bottomGradient{
    if(!_bottomGradient){
        _bottomGradient = [CAGradientLayer layer];
        _bottomGradient.colors = @[(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.3].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        _bottomGradient.startPoint = CGPointMake(0, 1.0);
        _bottomGradient.endPoint = CGPointMake(0.0, 0.0);
    }
    return _bottomGradient;
}

- (UIView *)keyboardMaskView{
    if(!_keyboardMaskView){
        _keyboardMaskView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor clearColor];
            view.hidden = YES ;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            @weakify(view);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                @strongify(view);
                [self.recTitleView resignFirstResponder];
                [view setHidden:YES];
            }];
            
            view ;
        });
    }
    return _keyboardMaskView;
}

@end
