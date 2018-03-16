//
//  KKVideoCompressTool.h
//  KKToydayNews
//
//  Created by finger on 2017/11/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKVideoInfo.h"

typedef void(^compressProgressCallback)(CGFloat progress);
typedef void(^compressCompleteCallback)(KKVideoInfo *videoInfo);

@interface KKVideoCompressTool : NSObject
+ (instancetype)sharedInstance;

//compressQuality的取值
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

- (void)compressVideoWithFilePath:(NSString *)filePath storeFolder:(NSString *)storeFolder fileName:(NSString *)fileName compressQuality:(NSString *)compressQuality progressCallback:(compressProgressCallback)progressCallback completeCallback:(compressCompleteCallback)completeCallback;
@end
