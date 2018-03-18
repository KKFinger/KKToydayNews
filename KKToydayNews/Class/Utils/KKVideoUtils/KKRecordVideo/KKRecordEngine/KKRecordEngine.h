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
#import "KKGLKRenderView.h"

@protocol KKRecordEngineDelegate <NSObject>
- (void)recordProgress:(CGFloat)progress;
@end

@interface KKRecordEngine : NSObject
@property(nonatomic,assign,readonly)BOOL isCapturing;//正在录制
@property(nonatomic,assign,readonly)BOOL isPaused;//是否暂停
@property(nonatomic,assign,readonly)BOOL writeRecordToLocal;//是否将录像文件写入沙盒，默认NO
@property(nonatomic,assign,readonly)BOOL previewWithOpenGL;//使用opengl预览
@property(nonatomic,assign,readonly)CGFloat currentRecordTime;//当前录制时间
@property(nonatomic,assign)CGFloat maxRecordTime;//录制最长时间
@property(nonatomic,assign)NSInteger pixWidth;//视频宽度
@property(nonatomic,assign)NSInteger pixHeight;//视频高度
@property(weak,nonatomic) id<KKRecordEngineDelegate>delegate;
@property(nonatomic,strong,readonly) NSString *recordFilePath;//视频路径
@property(nonatomic,strong,readonly) NSString *recordFolderPath;//视频所在的文件夹

//预览视图使用opengles绘制
@property(nonatomic,readonly)KKGLKRenderView *glkView;
//使用系统自带的预览视图
@property(nonatomic,readonly)AVCaptureVideoPreviewLayer *previewLayer;

/**
 初始化录像引擎

 @param fileFolder 录像保存路径
 @param previewWithOpenGL 是否使用opengl绘制，YES，使用KKGLKRenderView绘制，NO，使用AVCaptureVideoPreviewLayer绘制
 @param writeRecordToLocal 是否保存录像到本地
 @return 录像引擎
 */
- (instancetype)initWithRecFileFolder:(NSString *)fileFolder previewWithOpenGL:(BOOL)previewWithOpenGL writeRecordToLocal:(BOOL)writeRecordToLocal;
//启动录制功能
- (void)setupRecord;
//关闭录制功能
- (void)shutdownRecord;
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

#pragma mark -- 相机和麦克风的权限

- (void)requireAuthorization:(void(^)(AVAuthorizationStatus audioState,AVAuthorizationStatus videoState))complete;

@end
