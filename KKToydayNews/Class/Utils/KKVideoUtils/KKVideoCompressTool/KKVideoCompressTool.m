//
//  KKVideoCompressTool.m
//  KKToydayNews
//
//  Created by finger on 2017/11/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKVideoCompressTool.h"
#import <AVFoundation/AVFoundation.h>

@interface KKVideoCompressTool ()
@property(nonatomic,copy)compressProgressCallback progressCallback;
@property(nonatomic,copy)compressCompleteCallback completeCallback;
@property(nonatomic)dispatch_source_t timer;
@property(nonatomic)AVAssetExportSession * exportSession;
@end

@implementation KKVideoCompressTool

+ (instancetype)sharedInstance{
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

//AVF_EXPORT NSString *const AVAssetExportPresetLowQuality        NS_AVAILABLE(10_11, 4_0);
//AVF_EXPORT NSString *const AVAssetExportPresetMediumQuality     NS_AVAILABLE(10_11, 4_0);
//AVF_EXPORT NSString *const AVAssetExportPresetHighestQuality    NS_AVAILABLE(10_11, 4_0);
//AVF_EXPORT NSString *const AVAssetExportPreset640x480			NS_AVAILABLE(10_7, 4_0);
//AVF_EXPORT NSString *const AVAssetExportPreset960x540   		NS_AVAILABLE(10_7, 4_0);
//AVF_EXPORT NSString *const AVAssetExportPreset1280x720  		NS_AVAILABLE(10_7, 4_0);
//AVF_EXPORT NSString *const AVAssetExportPreset1920x1080			NS_AVAILABLE(10_7, 5_0);
//AVF_EXPORT NSString *const AVAssetExportPreset3840x2160			NS_AVAILABLE(10_10, 9_0);
//AVF_EXPORT NSString *const AVAssetExportPresetAppleM4A			NS_AVAILABLE(10_7, 4_0);
//AVF_EXPORT NSString *const AVAssetExportPresetPassthrough		NS_AVAILABLE(10_7, 4_0);
//AVF_EXPORT NSString *const AVAssetExportPresetAppleM4VCellular	NS_AVAILABLE(10_7, NA);
//AVF_EXPORT NSString *const AVAssetExportPresetAppleM4ViPod		NS_AVAILABLE(10_7, NA);
//AVF_EXPORT NSString *const AVAssetExportPresetAppleM4V480pSD	NS_AVAILABLE(10_7, NA);
//AVF_EXPORT NSString *const AVAssetExportPresetAppleM4VAppleTV	NS_AVAILABLE(10_7, NA);
//AVF_EXPORT NSString *const AVAssetExportPresetAppleM4VWiFi		NS_AVAILABLE(10_7, NA);
//AVF_EXPORT NSString *const AVAssetExportPresetAppleM4V720pHD	NS_AVAILABLE(10_7, NA);
//AVF_EXPORT NSString *const AVAssetExportPresetAppleM4V1080pHD	NS_AVAILABLE(10_8, NA);
//AVF_EXPORT NSString *const AVAssetExportPresetAppleProRes422LPCM	NS_AVAILABLE(10_7, NA);

- (void)compressVideoWithFilePath:(NSString *)filePath
                      storeFolder:(NSString *)storeFolder
                         fileName:(NSString *)fileName
                  compressQuality:(NSString *)compressQuality
                 progressCallback:(compressProgressCallback)progressCallback
                 completeCallback:(compressCompleteCallback)completeCallback{
    self.completeCallback = completeCallback;
    self.progressCallback = progressCallback;
    
    if(!filePath.length){
        if(self.completeCallback){
            self.completeCallback(nil);
        }
        return;
    }
    
    [self startTimer];
    
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:storeFolder isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:storeFolder withIntermediateDirectories:YES attributes:nil error:nil];
    };
    NSString *outFilePath  = [storeFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",fileName]];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    AVURLAsset * urlAsset = [[AVURLAsset alloc] initWithURL:fileUrl options:nil];
    self.exportSession = [AVAssetExportSession exportSessionWithAsset:urlAsset presetName:compressQuality];
    self.exportSession.shouldOptimizeForNetworkUse = YES;
    self.exportSession.outputFileType = AVFileTypeMPEG4;
    self.exportSession.outputURL = [NSURL fileURLWithPath:outFilePath];
    
    @weakify(self);
    [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
        @strongify(self);
        AVAssetExportSessionStatus status = self.exportSession.status ;
        if(status == AVAssetExportSessionStatusCompleted){
            AVURLAsset * urlAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:outFilePath] options:nil];
            KKVideoInfo *videoInfo = [self getVideoInfoAsset:urlAsset];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.completeCallback){
                    self.completeCallback(videoInfo);
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(self.completeCallback){
                    self.completeCallback(nil);
                }
            });
            
        }
        [self stopTimer];
    }];
}

#pragma mark -- 监听压缩进度

- (void)startTimer{
    [self stopTimer];
    NSTimeInterval period = 1.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{ //在这里执行事件
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_progressCallback){
                _progressCallback(_exportSession.progress);
            }
        });
    });
    dispatch_source_set_cancel_handler(_timer, ^{
        _timer = nil ;
        //这里写取消后的操作
    });
    dispatch_resume(_timer);
}

- (void)stopTimer{
    if(_timer){
        dispatch_cancel(_timer);
    }
}

- (KKVideoInfo *)getVideoInfoAsset:(AVURLAsset *)asset{
    KKVideoInfo *videoInfo = [KKVideoInfo new];
    NSString *filePath = [[asset URL] path];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSError *error = nil;
        NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        if (fileDic != nil){
            long long size = [fileDic fileSize];
            NSString *fileSize = [KKAppTools formatSizeFromByte:size];
            NSTimeInterval seconds = asset.duration.value / asset.duration.timescale;
            NSString *duration = [NSString getHHMMSSFromSS:[NSString stringWithFormat:@"%f",seconds]];
            
            videoInfo.filePath = filePath;
            videoInfo.fileName = [filePath lastPathComponent];
            videoInfo.fileSize = size ;
            videoInfo.formatSize = fileSize;
            videoInfo.duration = seconds;
            videoInfo.formatDuration = duration;
        }
    }
    return videoInfo;
}

@end
