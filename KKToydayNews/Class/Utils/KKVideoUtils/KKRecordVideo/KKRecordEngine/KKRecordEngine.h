//
//  KKRecordEngine.h
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVCaptureVideoPreviewLayer.h>
#import "KKVideoManager.h"

@protocol KKRecordEngineDelegate <NSObject>
- (void)recordProgress:(CGFloat)progress;
@end

@interface KKRecordEngine : NSObject
@property (atomic, assign, readonly) BOOL isCapturing;//正在录制
@property (atomic, assign, readonly) BOOL isPaused;//是否暂停
@property (atomic, assign, readonly) CGFloat currentRecordTime;//当前录制时间
@property (atomic, assign) CGFloat maxRecordTime;//录制最长时间
@property(nonatomic,assign)NSInteger pixWidth;//视频宽度
@property(nonatomic,assign)NSInteger pixHeight;//视频高度
@property (weak,nonatomic) id<KKRecordEngineDelegate>delegate;
@property (atomic,strong,readonly) NSString *recordFilePath;//视频路径
@property (atomic,strong,readonly) NSString *recordFolderPath;//视频所在的文件夹

- (instancetype)initWithRecFileFolder:(NSString *)fileFolder;

//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;
//启动录制功能
- (void)startUp;
//关闭录制功能
- (void)shutdown;
//开始录制
- (void) startCapture;
//暂停录制
- (void) pauseCapture;
//停止录制
- (void)stopCaptureHandler:(void (^)(NSString *recordPath))handler;
//继续录制
- (void) resumeCapture;
//开启闪光灯
- (void)openFlashLight;
//关闭闪光灯
- (void)closeFlashLight;
//切换前后置摄像头
- (void)changeCameraInputDeviceisFront:(BOOL)isFront;
//删除录像文件
- (void)deleteRecord;

#pragma mark -- 麦克风权限

- (AVAuthorizationStatus)checkAudioAuthorization;
- (void)requireAudioAuthorization:(void(^)(BOOL granted))callback;

#pragma mark -- 相机权限

- (AVAuthorizationStatus)checkCameraAuthorization;
- (void)requireCameraAuthorization:(void(^)(BOOL granted))callback;

@end
