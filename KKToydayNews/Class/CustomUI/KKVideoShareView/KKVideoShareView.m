//
//  KKVideoShareView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/4.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKVideoShareView.h"
#import "KKProgressView.h"
#import "KKVideoGalleryView.h"
#import "KKRecordEngine.h"
#import "KKBlockAlertView.h"
#import "KKGalleryVideoPreview.h"
#import "KKRecordPreview.h"
#import "KKVideoCompressTool.h"
#import "KKFetchVideoCorverTool.h"

#define redDotWH 10

static CGFloat maxRecordVideoTime = 5 * 60 ;

@interface KKVideoShareView()<KKRecordEngineDelegate>
@property(nonatomic)UIButton *cancelBtn;
@property(nonatomic)UIButton *beautyBtn;
@property(nonatomic)UIButton *changeCameraBtn;
@property(nonatomic)UIView *videoCaptureView;
@property(nonatomic)KKProgressView *progressView;
@property(nonatomic)KKBlockAlertView *alertView;
@property(nonatomic)UIView *redDotView;
@property(nonatomic)UILabel *recTimeLabel;
@property(nonatomic)UIButton *importVideoBtn;
@property(nonatomic)UIButton *deleteBtn;
@property(nonatomic)UIButton *startPauseBtn;
@property(nonatomic)UIButton *doneBtn;

@property(nonatomic,assign)BOOL allowRecord;
@property(nonatomic,assign)BOOL isFrontCamera;
@property(nonatomic)KKRecordEngine *recordEngine;
@property(nonatomic)dispatch_source_t timer;

@property(nonatomic,assign)UIStatusBarStyle barStyle;

@end

@implementation KKVideoShareView

- (instancetype)init{
    self = [super init];
    if(self){
        self.enableFreedomDrag = NO ;
        self.enableHorizonDrag = YES ;
        self.enableVerticalDrag = YES ;
        self.isFrontCamera = NO ;
        self.barStyle = [[UIApplication sharedApplication]statusBarStyle];
    }
    return self ;
}

- (void)viewWillAppear{
    [super viewWillAppear];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    [self setupUI];
    [self checkAuthoriztion];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [self.recordEngine shutdownRecord];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
}

#pragma mark -- 设置UI

- (void)setupUI{
    self.dragContentView.backgroundColor = [UIColor whiteColor];
    [self.dragContentView addSubview:self.cancelBtn];
    [self.dragContentView addSubview:self.beautyBtn];
    [self.dragContentView addSubview:self.changeCameraBtn];
    [self.dragContentView addSubview:self.videoCaptureView];
    [self.dragContentView addSubview:self.progressView];
    [self.dragContentView addSubview:self.redDotView];
    [self.dragContentView addSubview:self.recTimeLabel];
    [self.dragContentView addSubview:self.importVideoBtn];
    [self.dragContentView addSubview:self.deleteBtn];
    [self.dragContentView addSubview:self.startPauseBtn];
    [self.dragContentView addSubview:self.doneBtn];
    
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dragContentView).mas_offset(20);
        make.left.mas_equalTo(self.dragContentView).mas_offset(kkPaddingNormal);
    }];
    
    [self.beautyBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.cancelBtn);
        make.right.mas_equalTo(self.changeCameraBtn.mas_left).mas_offset(-10).priority(998);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.changeCameraBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.cancelBtn);
        make.right.mas_equalTo(self.dragContentView).mas_offset(-kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.videoCaptureView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dragContentView).mas_offset(60);
        make.left.mas_equalTo(self.dragContentView);
        make.width.height.mas_equalTo(UIDeviceScreenWidth);
    }];
    
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.videoCaptureView.mas_bottom);
        make.left.right.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(5);
    }];
    
    [self.redDotView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.recTimeLabel);
        make.right.mas_equalTo(self.recTimeLabel.mas_left).mas_offset(-3);
        make.size.mas_equalTo(CGSizeMake(redDotWH, redDotWH));
    }];
    
    [self.recTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.progressView.mas_bottom).mas_offset(5).priority(998);
        make.centerX.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(55);
    }];
    
    [self.importVideoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView);
        make.right.mas_equalTo(self.startPauseBtn.mas_left).mas_offset(-5).priority(998);
        make.centerY.mas_equalTo(self.startPauseBtn);
    }];
    
    [self.deleteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.importVideoBtn);
    }];
    
    [self.startPauseBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.dragContentView);
        make.centerY.mas_equalTo(self.videoCaptureView.mas_bottom).mas_offset((UIDeviceScreenHeight - UIDeviceScreenWidth - 60)/2.0);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self.doneBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.startPauseBtn.mas_right).mas_offset(5).priority(998);
        make.right.mas_equalTo(self.dragContentView);
        make.centerY.mas_equalTo(self.startPauseBtn);
    }];
    
    [self.recordEngine.previewLayer setFrame:CGRectMake(0, 0, UIDeviceScreenWidth, UIDeviceScreenWidth)];
    [self.videoCaptureView.layer insertSublayer:self.recordEngine.previewLayer atIndex:0];
    //[self.videoCaptureView addSubview:self.recordEngine.glkView];
    //[self.recordEngine.glkView mas_updateConstraints:^(MASConstraintMaker *make) {
        //make.edges.mas_equalTo(self.videoCaptureView);
    //}];
}

#pragma mark -- 检测相机和麦克风权限

- (void)checkAuthoriztion{
    @weakify(self);
    [self.recordEngine requireAuthorization:^(AVAuthorizationStatus audioState, AVAuthorizationStatus videoState) {
        @strongify(self);
        if(audioState == AVAuthorizationStatusAuthorized &&
           videoState == AVAuthorizationStatusAuthorized){
            self.allowRecord = YES ;
            [self.recordEngine setupRecord];
            //[self.recordEngine startCapture];
            [self captureViewAnimate];
        }else{
            KKBlockAlertView *view = [KKBlockAlertView new];
            [view showWithTitle:@"相机或者麦克风" message:@"KK头条没有相机或者麦克风" cancelButtonTitle:@"知道了" otherButtonTitles:@"去设置" block:^(NSInteger re_code, NSDictionary *userInfo) {
                if(re_code == 1){
                    [KKAppTools jumpToSetting];
                }
            }];
            self.alertView = view ;
            [self captureViewAnimate];
        }
    }];
}

#pragma mark -- 录像预览视图动画

- (void)captureViewAnimate{
    self.videoCaptureView.hidden = NO ;
    self.videoCaptureView.transform = CGAffineTransformMakeScale(1.0f, 0.0f);
    [UIView animateWithDuration:0.3 animations:^{
        self.videoCaptureView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
}

#pragma mark -- 取消按钮

- (void)cancelBtnClicked{
    [self stopTimer];
    [self startHide];
}

#pragma mark -- 美颜按钮

- (void)beautyBtnClicked{
    
}

#pragma mark -- 更改相机

- (void)changeCameraBtnClicked{
    self.isFrontCamera = !self.isFrontCamera;
    [self.recordEngine changeCameraInputDeviceisFront:self.isFrontCamera];
}

#pragma mark -- 删除

- (void)deleteBtnClicked{
    self.startPauseBtn.selected = NO;
    self.redDotView.hidden = YES;
    self.progressView.hidden = YES;
    self.recTimeLabel.hidden = YES;
    self.deleteBtn.hidden = YES;
    self.doneBtn.hidden = YES;
    self.importVideoBtn.hidden = NO;
    self.cancelBtn.enabled = YES;
    self.beautyBtn.enabled = YES;
    self.changeCameraBtn.enabled = YES;
    
    [self stopTimer];
    [self.recordEngine deleteRecord];
}

#pragma mark -- 开始暂停

- (void)startPauseBtnClicked{
    if (self.allowRecord) {
        BOOL isCapture = !self.startPauseBtn.selected;
        if (isCapture) {
            if (self.recordEngine.isCapturing) {
                [self.recordEngine resumeCapture];
            }else {
                [self.recordEngine startCapture];
            }
            [self startTimer];
        }else {
            [self.recordEngine pauseCapture];
            [self stopTimer];
        }
        self.startPauseBtn.selected = isCapture;
        self.redDotView.hidden = !isCapture;
        self.progressView.hidden = NO;
        self.recTimeLabel.hidden = NO;
        self.deleteBtn.hidden = NO;
        self.deleteBtn.enabled = !isCapture;
        self.doneBtn.hidden = NO;
        self.doneBtn.enabled = !isCapture;
        self.importVideoBtn.hidden = YES;
        self.cancelBtn.enabled = !isCapture;
        self.beautyBtn.enabled = !isCapture;
        self.changeCameraBtn.enabled = !isCapture;
    }
}

#pragma mark -- 完成

- (void)doneBtnClicked{
    @weakify(self);
    [self.recordEngine stopCaptureHandler:^(NSString *recordPath) {
        @strongify(self);
        [self.recordEngine shutdownRecord];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication].keyWindow showActivityViewWithTitle:nil];
            self.startPauseBtn.selected = NO;
            self.redDotView.hidden = YES;
            self.progressView.hidden = YES;
            self.recTimeLabel.hidden = YES;
            self.deleteBtn.hidden = YES;
            self.doneBtn.hidden = YES;
            self.importVideoBtn.hidden = NO;
            self.cancelBtn.enabled = YES;
            self.beautyBtn.enabled = YES;
            self.changeCameraBtn.enabled = YES;
        });
        
        [[KKVideoManager sharedInstance]addVideoToAlbumWithFilePath:recordPath albumId:[[KKVideoManager sharedInstance]getCameraRollAlbumId] block:^(BOOL suc, KKVideoInfo *videoInfo) {
            if(videoInfo){
                [KKFetchVideoCorverTool fetchCorverWithFilePath:videoInfo.filePath seconds:0 callback:^(UIImage *movieImage) {
                    videoInfo.videoCorver = movieImage;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showRecordPreview:videoInfo];
                    });
                }];
            }
            [KKAppTools clearFileAtFolder:KKVideoRecordFileFolder];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow hiddenActivity];
                [[UIApplication sharedApplication].keyWindow promptMessage:videoInfo?@"成功保存至相册":@"保存失败"];
            });
        }];
    }];
    
    [self stopTimer];
}

#pragma mark -- KKRecordEngineDelegate

- (void)recordProgress:(CGFloat)progress{
    self.progressView.progress = progress;
    NSTimeInterval duration = self.recordEngine.currentRecordTime;
    self.recTimeLabel.text = [NSString getHHMMSSMMFromSS:duration];
}

#pragma mark -- 导入视频

- (void)importVideoBtnClicked{
    [self.recordEngine shutdownRecord];
    [self stopTimer];
    
    KKVideoGalleryView *view = [KKVideoGalleryView new];
    view.topSpace = 20 ;
    view.navContentOffsetY = 0 ;
    view.navTitleHeight = 50 ;
    view.contentViewCornerRadius = 10 ;
    view.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    
    @weakify(self);
    [view setSelectVideoCallback:^(KKVideoInfo *item) {
        @strongify(self);
        if(item){
            [KKFetchVideoCorverTool fetchCorverWithFilePath:item.filePath seconds:0 callback:^(UIImage *movieImage) {
                item.videoCorver = movieImage;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showRecordPreview:item];
                });
            }];
        }else{
            [self.recordEngine setupRecord];
        }
    }];
    
    [view startShow];
}

#pragma mark -- 预览录像

- (void)showRecordPreview:(KKVideoInfo *)videoInfo{
    KKRecordPreview *view = [[KKRecordPreview alloc]initWithVideoInfo:videoInfo];
    view.topSpace = 0 ;
    view.contentViewCornerRadius = 0 ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    
    [view setViewWillDisapear:^{
        [self.recordEngine setupRecord];
    }];
    
    [view pushIn];
}

#pragma mark -- 计时

- (void)startTimer{
    NSTimeInterval period = 1.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{ //在这里执行事件
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTimeInterval duration = self.recordEngine.currentRecordTime;
            self.redDotView.hidden = !self.redDotView.hidden;
            if(duration > 4.0){//大于5秒
                self.doneBtn.hidden = NO;
            }else{
                self.doneBtn.hidden = YES;
            }
        });
    });
    dispatch_source_set_cancel_handler(_timer, ^{
        _timer = nil ;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSTimeInterval duration = self.recordEngine.currentRecordTime;
            self.recTimeLabel.text = [NSString getHHMMSSMMFromSS:duration];
            self.redDotView.hidden = YES;
            if(duration > 4.0){//大于5秒
                self.doneBtn.hidden = NO;
            }else{
                self.doneBtn.hidden = YES;
            }
        });
    });
    dispatch_resume(_timer);
}

- (void)stopTimer{
    if(_timer){
        dispatch_cancel(_timer);
    }
}

#pragma mark -- @property

- (UIButton *)cancelBtn{
    if(!_cancelBtn){
        _cancelBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"取消" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor grayColor]colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
            [view addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _cancelBtn;
}

- (UIButton *)beautyBtn{
    if(!_beautyBtn){
        _beautyBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"king_openbeauty_n"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(beautyBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _beautyBtn;
}

- (UIButton *)changeCameraBtn{
    if(!_changeCameraBtn){
        _changeCameraBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"king_camera_n"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(changeCameraBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _changeCameraBtn;
}

- (UIView *)videoCaptureView{
    if(!_videoCaptureView){
        _videoCaptureView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor blackColor];
            view.hidden = YES ;
            view ;
        });
    }
    return _videoCaptureView;
}

- (KKProgressView *)progressView{
    if(!_progressView){
        _progressView = ({
            KKProgressView *view = [KKProgressView new];
            view.progressBgColor = [UIColor whiteColor];
            view.progressColor = [UIColor blackColor];
            view.loadProgressColor = [UIColor whiteColor];
            view.progress = 0 ;
            view.loadProgress = 0 ;
            view.hidden = YES ;
            view ;
        });
    }
    return _progressView;
}

- (UIView *)redDotView{
    if(!_redDotView){
        _redDotView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor redColor];
            view.layer.cornerRadius = redDotWH / 2.0;
            view.layer.masksToBounds = YES ;
            view.hidden = YES ;
            view;
        });
    }
    return _redDotView;
}

- (UILabel *)recTimeLabel{
    if(!_recTimeLabel){
        _recTimeLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:15];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.hidden = YES ;
            view ;
        });
    }
    return _recTimeLabel;
}

- (UIButton *)deleteBtn{
    if(!_deleteBtn){
        _deleteBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"<删除" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor grayColor]colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
            [view addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [view setHidden:YES];
            view;
        });
    }
    return _deleteBtn;
}

- (UIButton *)importVideoBtn{
    if(!_importVideoBtn){
        _importVideoBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"导入视频" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(importVideoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _importVideoBtn;
}

- (UIButton *)startPauseBtn{
    if(!_startPauseBtn){
        _startPauseBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"recordStart"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"recordPause"] forState:UIControlStateSelected];
            [view addTarget:self action:@selector(startPauseBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _startPauseBtn;
}

- (UIButton *)doneBtn{
    if(!_doneBtn){
        _doneBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"完成 >" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor grayColor]colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
            [view addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [view setHidden:YES];
            view;
        });
    }
    return _doneBtn;
}

- (KKRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[KKRecordEngine alloc] initWithRecFileFolder:KKVideoRecordFileFolder previewWithOpenGL:NO writeRecordToLocal:YES];
        _recordEngine.maxRecordTime = maxRecordVideoTime ;
        _recordEngine.pixWidth = UIDeviceScreenWidth;
        _recordEngine.pixHeight = UIDeviceScreenWidth;
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}

@end
