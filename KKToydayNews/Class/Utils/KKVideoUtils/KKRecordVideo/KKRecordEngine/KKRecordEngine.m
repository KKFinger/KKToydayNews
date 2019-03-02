//
//  KKRecordEngine.m
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKRecordEngine.h"
#import "KKRecordEncoder.h"
#import <AVFoundation/AVFoundation.h>
#import "KKAppTools.h"

@interface KKRecordEngine ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate, CAAnimationDelegate>
@property(strong,nonatomic)KKRecordEncoder *recordEncoder;//录制编码
@property(strong,nonatomic)AVCaptureSession *recordSession;//捕获视频的会话
@property(strong,nonatomic)AVCaptureDeviceInput *backCameraInput;//后置摄像头输入
@property(strong,nonatomic)AVCaptureDeviceInput *frontCameraInput;//前置摄像头输入
@property(strong,nonatomic)AVCaptureDeviceInput *audioMicInput;//麦克风输入
@property(copy,nonatomic)dispatch_queue_t captureQueue;//录制的队列
@property(strong,nonatomic)AVCaptureConnection *audioConnection;//音频录制连接
@property(strong,nonatomic)AVCaptureConnection *videoConnection;//视频录制连接
@property(strong,nonatomic)AVCaptureVideoDataOutput *videoOutput;//视频输出
@property(strong,nonatomic)AVCaptureAudioDataOutput *audioOutput;//音频输出

//录制控制
@property(nonatomic,assign)BOOL isCapturing;//正在录制
@property(nonatomic,assign)BOOL isPaused;//是否暂停
@property(nonatomic,assign)BOOL writeRecordToLocal;//是否将录像文件写入沙盒，默认NO
@property(nonatomic,assign)BOOL previewWithOpenGL;//使用opengl预览
@property(nonatomic,assign)BOOL discont;//是否中断
@property(nonatomic,assign)CMTime startTime;//开始录制的时间
@property(nonatomic,assign)CGFloat currentRecordTime;//当前录制时间

//数据写入相关
@property(nonatomic,assign)CMTime timeOffset;//录制的偏移CMTime
@property(nonatomic,assign)CMTime lastVideo;//记录上一次视频数据文件的CMTime
@property(nonatomic,assign)CMTime lastAudio;//记录上一次音频数据文件的CMTime
@property(nonatomic,assign)NSInteger channels;//音频通道
@property(nonatomic,assign)Float64 samplerate;//音频采样率

@property (nonatomic,strong) NSString *recordFilePath;//视频路径
@property (nonatomic,strong) NSString *recordFolderPath;//视频所在的文件夹

//预览视图使用opengles绘制
@property(nonatomic,readwrite)KKGLKRenderView *glkView;
//使用系统自带的预览视图
@property(nonatomic,readwrite)AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation KKRecordEngine

- (void)dealloc {
    [self.recordSession stopRunning];
    self.captureQueue = nil;
    self.recordSession = nil;
    self.backCameraInput = nil;
    self.frontCameraInput = nil;
    self.audioOutput = nil;
    self.videoOutput = nil;
    self.audioConnection = nil;
    self.videoConnection = nil;
    self.recordEncoder = nil;
    
    [self.previewLayer removeFromSuperlayer];
    self.previewLayer = nil;
    
    [KKAppTools clearFileAtFolder:self.recordFolderPath];
}

- (instancetype)initWithRecFileFolder:(NSString *)fileFolder previewWithOpenGL:(BOOL)previewWithOpenGL writeRecordToLocal:(BOOL)writeRecordToLocal{
    self = [super init];
    if (self) {
        self.maxRecordTime = 60.0f;
        self.pixWidth = UIDeviceScreenWidth;
        self.pixHeight = UIDeviceScreenWidth;
        self.recordFolderPath = fileFolder;
        self.writeRecordToLocal = writeRecordToLocal;
        self.previewWithOpenGL = previewWithOpenGL;
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if(self){
        self.maxRecordTime = 60.0f;
        self.pixWidth = UIDeviceScreenWidth;
        self.pixHeight = UIDeviceScreenWidth;
        self.recordFolderPath = NSTemporaryDirectory();
        self.writeRecordToLocal = NO;
        self.previewWithOpenGL = NO;
    }
    return self ;
}

#pragma mark -- 启动录制功能

- (void)setupRecord {
    self.startTime = CMTimeMake(0, 0);
    self.isCapturing = NO;
    self.isPaused = NO;
    self.discont = NO;
    [self.recordSession startRunning];
    [KKAppTools clearFileAtFolder:self.recordFolderPath];
}

#pragma mark -- 关闭录制功能

- (void)shutdownRecord {
    self.startTime = CMTimeMake(0, 0);
    [self.recordSession stopRunning];
    [self.recordEncoder finishWithCompletionHandler:^{
    }];
}

#pragma mark -- 开始录制

- (void) startCapture {
    @synchronized(self) {
        if (!self.isCapturing) {
            self.recordEncoder = nil;
            self.isPaused = NO;
            self.discont = NO;
            self.timeOffset = CMTimeMake(0, 0);
            self.isCapturing = YES;
        }
    }
}

#pragma mark -- 暂停录制

- (void) pauseCapture {
    @synchronized(self) {
        if (self.isCapturing) {
            self.isPaused = YES;
            self.discont = YES;
        }
    }
}

#pragma mark -- 继续录制

- (void) resumeCapture {
    @synchronized(self) {
        if (self.isPaused) {
            self.isPaused = NO;
        }
    }
}

#pragma mark -- 停止录制

- (void)stopCaptureHandler:(void (^)(NSString *recordPath))handler {
    @synchronized(self) {
        if (self.isCapturing) {
            NSString* path = self.recordEncoder.writePath;
            self.isCapturing = NO;
            @weakify(self);
            dispatch_async(self.captureQueue, ^{
                @strongify(self);
                @weakify(self);
                [self.recordEncoder finishWithCompletionHandler:^{
                    @strongify(self);
                    self.isCapturing = NO;
                    self.recordEncoder = nil;
                    self.currentRecordTime = 0;
                    self.discont = NO ;
                    self.lastAudio = CMTimeMake(0, 0);
                    self.lastVideo = CMTimeMake(0, 0);
                    self.startTime = CMTimeMake(0, 0);
                    self.timeOffset = CMTimeMake(0, 0);
                    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
                        });
                    }
                    if(handler){
                        handler(path);
                    }
                }];
            });
        }
    }
}

#pragma mark -- 删除录像文件

- (void)deleteRecord{
    @synchronized(self) {
        @weakify(self);
        dispatch_async(self.captureQueue, ^{
            @strongify(self);
            @weakify(self);
            [self.recordEncoder finishWithCompletionHandler:^{
                @strongify(self);
                self.isCapturing = NO;
                self.recordEncoder = nil;
                self.currentRecordTime = 0;
                self.discont = NO ;
                self.lastAudio = CMTimeMake(0, 0);
                self.lastVideo = CMTimeMake(0, 0);
                self.startTime = CMTimeMake(0, 0);
                self.timeOffset = CMTimeMake(0, 0);
            }];
        });
        [KKAppTools clearFileAtFolder:KKVideoRecordFileFolder];
    }
}

#pragma mark -- 摄像头切换动画

- (void)changeCameraAnimation {
    CATransition *changeAnimation = [CATransition animation];
    changeAnimation.delegate = self;
    changeAnimation.duration = 0.45;
    changeAnimation.type = @"oglFlip";
    changeAnimation.subtype = kCATransitionFromRight;
    changeAnimation.timingFunction = UIViewAnimationCurveEaseInOut;
    [self.previewLayer addAnimation:changeAnimation forKey:@"changeAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim {
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.recordSession startRunning];
}

#pragma mark -- 摄像头相关

//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront {
    if (isFront) {
        [self.recordSession stopRunning];
        [self.recordSession removeInput:self.backCameraInput];
        if ([self.recordSession canAddInput:self.frontCameraInput]) {
            [self changeCameraAnimation];
            [self.recordSession addInput:self.frontCameraInput];
        }
    }else {
        [self.recordSession stopRunning];
        [self.recordSession removeInput:self.frontCameraInput];
        if ([self.recordSession canAddInput:self.backCameraInput]) {
            [self changeCameraAnimation];
            [self.recordSession addInput:self.backCameraInput];
        }
    }
}

//用来返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//开启闪光灯
- (void)openFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOff) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOn;
        backCamera.flashMode = AVCaptureFlashModeOn;
        [backCamera unlockForConfiguration];
    }
}

//关闭闪光灯
- (void)closeFlashLight {
    AVCaptureDevice *backCamera = [self backCamera];
    if (backCamera.torchMode == AVCaptureTorchModeOn) {
        [backCamera lockForConfiguration:nil];
        backCamera.torchMode = AVCaptureTorchModeOff;
        backCamera.flashMode = AVCaptureTorchModeOff;
        [backCamera unlockForConfiguration];
    }
}

#pragma mark -- 数据回调

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    BOOL isVideo = YES;
    @synchronized(self) {
        if (captureOutput != self.videoOutput) {
            isVideo = NO;
        }
        if(self.previewWithOpenGL && isVideo){
            UIImage *image = [UIImage imageFromSampleBuffer:sampleBuffer];
            CIImage *ciimage = [[CIImage alloc] initWithImage:image];
            [self.glkView drawCIImage:ciimage];
        }
        if (!self.isCapturing  || self.isPaused) {
            return;
        }
        //初始化编码器，当有音频和视频参数时创建编码器
        if ((self.recordEncoder == nil) && !isVideo) {
            CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
            [self setAudioFormat:fmt];
            NSString *videoName = [KKAppTools formartFileName:@"video" fileType:@"mp4"];
            self.recordFilePath = [[KKAppTools createFolderIfNeed:self.recordFolderPath] stringByAppendingPathComponent:videoName];
            self.recordEncoder = [KKRecordEncoder encoderForPath:self.recordFilePath pixHeight:self.pixHeight pixWidth:self.pixWidth channels:self.channels samples:self.samplerate];
        }
        //判断是否中断录制过
        if (self.discont) {
            if (isVideo) {
                return;
            }
            self.discont = NO;
            // 计算暂停的时间
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            CMTime last = isVideo ? self.lastVideo : self.lastAudio;
            if (last.flags & kCMTimeFlags_Valid) {
                if (self.timeOffset.flags & kCMTimeFlags_Valid) {
                    pts = CMTimeSubtract(pts, self.timeOffset);
                }
                CMTime offset = CMTimeSubtract(pts, last);
                if (self.timeOffset.value == 0) {
                    self.timeOffset = offset;
                }else {
                    self.timeOffset = CMTimeAdd(self.timeOffset, offset);
                }
            }
            _lastVideo.flags = 0;
            _lastAudio.flags = 0;
        }
        // 增加sampleBuffer的引用计时,这样我们可以释放这个或修改这个数据，防止在修改时被释放
        CFRetain(sampleBuffer);
        if (self.timeOffset.value > 0) {
            CFRelease(sampleBuffer);
            //根据得到的timeOffset调整
            sampleBuffer = [self adjustTime:sampleBuffer by:self.timeOffset];
        }
        // 记录暂停上一次录制的时间
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
        if (dur.value > 0) {
            pts = CMTimeAdd(pts, dur);
        }
        if (isVideo) {
            self.lastVideo = pts;
        }else {
            self.lastAudio = pts;
        }
    }
    CMTime dur = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (self.startTime.value == 0) {
        self.startTime = dur;
    }
    CMTime sub = CMTimeSubtract(dur, self.startTime);
    self.currentRecordTime = CMTimeGetSeconds(sub);
    if (self.currentRecordTime > self.maxRecordTime) {
        if (self.currentRecordTime - self.maxRecordTime < 0.1) {
            if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
                });
            }
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
        });
    }
    
    //数据保存
    if(self.writeRecordToLocal){
        [self.recordEncoder writeRecordToLocal:sampleBuffer isVideo:isVideo];
    }
    
    CFRelease(sampleBuffer);
}

//设置音频格式
- (void)setAudioFormat:(CMFormatDescriptionRef)fmt {
    const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(fmt);
    self.samplerate = asbd->mSampleRate;
    self.channels = asbd->mChannelsPerFrame;
}

//调整媒体数据的时间
- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

#pragma mark -- 麦克风权限

- (AVAuthorizationStatus)checkAudioAuthorization {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return authStatus;
}

- (void)requireAudioAuthorization:(void(^)(BOOL granted))callback{
    AVAuthorizationStatus authStatus = [self checkAudioAuthorization];
    if(authStatus != AVAuthorizationStatusAuthorized){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            if(callback){
                callback(granted);
            }
        }];
    }
}

#pragma mark -- 相机权限

- (AVAuthorizationStatus)checkCameraAuthorization{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    return authStatus ;
}

//授权相机
- (void)requireCameraAuthorization:(void(^)(BOOL granted))callback{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if(callback){
            callback(granted);
        }
    }];
}

#pragma mark -- 相机和麦克风的权限

- (void)requireAuthorization:(void(^)(AVAuthorizationStatus audioState,AVAuthorizationStatus videoState))complete{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        __block AVAuthorizationStatus audioAuth = [self checkAudioAuthorization];
        __block AVAuthorizationStatus videoAuth = [self checkCameraAuthorization];
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        if(audioAuth == AVAuthorizationStatusNotDetermined){
            @weakify(self);
            [self requireAudioAuthorization:^(BOOL granted) {
                @strongify(self);
                audioAuth = [self checkAudioAuthorization];
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        if(videoAuth == AVAuthorizationStatusNotDetermined){
            @weakify(self);
            [self requireCameraAuthorization:^(BOOL granted) {
                @strongify(self);
                videoAuth = [self checkCameraAuthorization];
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if(complete){
                complete(audioAuth,videoAuth);
            }
        });
    });
}

#pragma mark -- @property set、get方法

//捕获视频的会话
- (AVCaptureSession *)recordSession {
    if (_recordSession == nil) {
        _recordSession = [[AVCaptureSession alloc] init];
        //添加后置摄像头的输出
        if ([_recordSession canAddInput:self.backCameraInput]) {
            [_recordSession addInput:self.backCameraInput];
        }
        //添加后置麦克风的输出
        if ([_recordSession canAddInput:self.audioMicInput]) {
            [_recordSession addInput:self.audioMicInput];
        }
        //添加视频输出
        if ([_recordSession canAddOutput:self.videoOutput]) {
            [_recordSession addOutput:self.videoOutput];
        }
        //添加音频输出
        if ([_recordSession canAddOutput:self.audioOutput]) {
            [_recordSession addOutput:self.audioOutput];
        }
        //设置视频录制的方向
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return _recordSession;
}

//后置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"获取后置摄像头失败~");
        }
    }
    return _backCameraInput;
}

//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            NSLog(@"获取前置摄像头失败~");
        }
    }
    return _frontCameraInput;
}

//麦克风输入
- (AVCaptureDeviceInput *)audioMicInput {
    if (_audioMicInput == nil) {
       AVCaptureDevice *mic = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        NSError *error;
        _audioMicInput = [AVCaptureDeviceInput deviceInputWithDevice:mic error:&error];
        if (error) {
            NSLog(@"获取麦克风失败~");
        }
    }
    return _audioMicInput;
}

//视频输出
- (AVCaptureVideoDataOutput *)videoOutput {
    if (_videoOutput == nil) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoOutput setSampleBufferDelegate:self queue:self.captureQueue];
        NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt: kCVPixelFormatType_32BGRA],kCVPixelBufferPixelFormatTypeKey,
                                        nil];
        _videoOutput.videoSettings = setcapSettings;
    }
    return _videoOutput;
}

//音频输出
- (AVCaptureAudioDataOutput *)audioOutput {
    if (_audioOutput == nil) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioOutput setSampleBufferDelegate:self queue:self.captureQueue];
    }
    return _audioOutput;
}

//视频连接
- (AVCaptureConnection *)videoConnection {
    if(!_videoConnection){
        _videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
    }
    return _videoConnection;
}

//音频连接
- (AVCaptureConnection *)audioConnection {
    if (_audioConnection == nil) {
        _audioConnection = [self.audioOutput connectionWithMediaType:AVMediaTypeAudio];
    }
    return _audioConnection;
}

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        //通过AVCaptureSession初始化
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.recordSession];
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = preview;
    }
    return _previewLayer;
}

- (KKGLKRenderView *)glkView{
    if(!_glkView){
        _glkView = ({
            KKGLKRenderView *view = [KKGLKRenderView new];
            view ;
        });
    }
    return _glkView;
}

//录制的队列
- (dispatch_queue_t)captureQueue {
    if (_captureQueue == nil) {
        _captureQueue = dispatch_queue_create("kktodaynews.video.recard", DISPATCH_QUEUE_SERIAL);
    }
    return _captureQueue;
}

@end
