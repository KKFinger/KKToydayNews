//
//  KKVideoMergeTool.m
//  KKToydayNews
//
//  Created by finger on 2017/11/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKVideoMergeTool.h"
#import <AVFoundation/AVFoundation.h>
#import "KKVideoManager.h"

@implementation KKVideoMergeTool

/**
 *  多个视频合成为一个视频输出到指定路径
 *
 *  @param urlArray 视频文件NSURL地址
 *  @param storeFolderPath 沙盒目录下的文件夹
 *  @param storeName 合成的文件名字
 *  @param is3d 是否3D视频,YES表示是3D视频
 *  @param successBlock 成功block
 *  @param failureBlcok 失败block
 */
+(void)mergeVideoWithUrlhArray:(NSArray<NSURL *> *)urlArray
                storeFolderPath:(NSString *)storeFolderPath
              storeName:(NSString *)storeName
                    is3d:(BOOL)is3d
                    success:(sucBlock)successBlock
                    failure:(failBlock)failureBlcok{
    AVMutableComposition *mixComposition = [self compositionVideos:urlArray];
    NSURL *outputFileUrl = [self genFilePath:storeFolderPath fileName:storeName];
    [self storeAVMutableComposition:mixComposition
                           storeUrl:outputFileUrl
                            success:successBlock
                            failure:failureBlcok];
}

/**
 *  多个视频合成为一个
 *
 *  @param array 多个视频的NSURL地址
 *
 *  @return 返回AVMutableComposition
 */
+(AVMutableComposition *)compositionVideos:(NSArray<NSURL *> *)array{
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    Float64 tmpDuration =0.0f;
    
    for (NSInteger i = 0 ; i < array.count ; i ++){
        AVURLAsset *videoAsset = [[AVURLAsset alloc]initWithURL:array[i] options:nil];
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
        /**
         *  依次加入每个asset
         *
         *  insertTimeRange 加入的asset持续时间
         *  ofTrack 加入的asset类型,这里都是video
         *  atTime 从哪个时间点加入asset,这里用了CMTime下面的CMTimeMakeWithSeconds(tmpDuration, 0),timesacle为0
         *
         */
        NSError *error = nil;
        [compositionVideoTrack insertTimeRange:timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:CMTimeMakeWithSeconds(tmpDuration, 0) error:&error];
        tmpDuration += CMTimeGetSeconds(videoAsset.duration);
    }
    return mixComposition;
}

/**
 *  生成合并视频文件的地址
 *
 *  @param folderPath 沙盒文件夹名
 *  @param fileName 文件名称
 *
 *  @return 返回拼接好的url地址
 */
+(NSURL *)genFilePath:(NSString *)folderPath fileName:(NSString *)fileName{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:folderPath];
    if(!isExist){
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *realName = [NSString stringWithFormat:@"%@.mp4", fileName];
    NSString *storePath = [folderPath stringByAppendingPathComponent:realName];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:storePath];
    return outputFileUrl;
}
/**
 *  存储合成的视频
 *
 *  @param mixComposition mixComposition参数
 *  @param storeUrl 存储的路径
 *  @param successBlock successBlock
 *  @param failureBlcok failureBlcok
 */
+(void)storeAVMutableComposition:(AVMutableComposition*)mixComposition
                        storeUrl:(NSURL *)storeUrl
                         success:(sucBlock)successBlock
                         failure:(failBlock)failureBlcok{
    AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = @"com.apple.quicktime-movie";
    assetExport.outputURL = storeUrl;
    
    @weakify(assetExport);
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        @strongify(assetExport);
        AVAssetExportSessionStatus status = assetExport.status ;
        if(status == AVAssetExportSessionStatusCompleted){
            NSString *albumId = [[KKVideoManager sharedInstance]getCameraRollAlbumId];
            [[KKVideoManager sharedInstance]addVideoToAlbumWithFilePath:[storeUrl path] albumId:albumId block:^(BOOL suc, KKVideoInfo *videoInfo) {
                if(videoInfo){
                    if(successBlock){
                        successBlock(videoInfo);
                    }
                }else{
                    if(failureBlcok){
                        failureBlcok();
                    }
                }
            }];
        }else{
            if(failureBlcok){
                failureBlcok();
            }
        }
    }];
}

@end
