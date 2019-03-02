//
//  WCLRecordEncoder.m
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKRecordEncoder.h"

@interface KKRecordEncoder ()
@property (nonatomic, strong) AVAssetWriter *writer;//媒体写入对象
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;//视频写入
@property (nonatomic, strong) AVAssetWriterInput *audioWriterInput;//音频写入
@property (nonatomic, strong) NSString *writePath;//写入路径
@end

@implementation KKRecordEncoder

- (void)dealloc {
    self.writer = nil;
    self.videoWriterInput = nil;
    self.audioWriterInput = nil;
    self.writePath = nil;
}

+ (KKRecordEncoder*)encoderForPath:(NSString*)path pixHeight:(NSInteger)pixHeight pixWidth:(NSInteger)pixWidth channels:(NSInteger)ch samples:(Float64)rate {
    KKRecordEncoder *enc = [KKRecordEncoder alloc];
    return [enc initPath:path pixHeight:pixHeight pixWidth:pixWidth channels:ch samples:rate];
}

//初始化方法
- (instancetype)initPath:(NSString*)path pixHeight:(NSInteger)pixHeight pixWidth:(NSInteger)pixWidth channels:(NSInteger)ch samples:(Float64) rate{
    self = [super init];
    if (self) {
        self.writePath = path;
        //先把路径下的文件给删除掉，保证录制的文件是最新的
        [[NSFileManager defaultManager] removeItemAtPath:self.writePath error:nil];
        NSURL* url = [NSURL fileURLWithPath:self.writePath];
        //初始化写入媒体类型为MP4类型
        self.writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:nil];
        //使其更适合在网络上播放
        self.writer.shouldOptimizeForNetworkUse = YES;
        //初始化视频输出
        [self initVideoInputHeight:pixHeight width:pixWidth];
        //确保采集到rate和ch
        if (rate != 0 && ch != 0) {
            //初始化音频输出
            [self initAudioInputChannels:ch samples:rate];
        }
    }
    return self;
}

//初始化视频输入
- (void)initVideoInputHeight:(NSInteger)cy width:(NSInteger)cx {
    //注意：如果宽和高不是16的倍数，则会出现绿边
    cx = ceil(cx / 16) * 16 ;
    cy = ceil(cy / 16) * 16 ;
    
    //写入视频大小
    NSInteger numPixels = cy * cx;
    //每像素比特
    CGFloat bitsPerPixel = 12.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    // 码率和帧率设置
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(15),
                                             AVVideoMaxKeyFrameIntervalKey : @(15),
                                             AVVideoProfileLevelKey :AVVideoProfileLevelH264BaselineAutoLevel
                                             };
    //视频属性
    NSDictionary *videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                                AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                                AVVideoWidthKey : @(cx * 2),
                                                AVVideoHeightKey : @(cy * 2),
                                                AVVideoCompressionPropertiesKey : compressionProperties};
    //初始化视频写入类
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
    //表明输入是否应该调整其处理为实时数据源的数据
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    //将视频输入源加入
    [self.writer addInput:self.videoWriterInput];
}

//初始化音频输入
- (void)initAudioInputChannels:(NSInteger)ch samples:(Float64)rate {
    //音频的一些配置包括音频各种这里为AAC,音频通道、采样率和音频的比特率
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [ NSNumber numberWithInteger:ch], AVNumberOfChannelsKey,
                              [ NSNumber numberWithFloat: rate], AVSampleRateKey,
                              [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                              nil];
    //初始化音频写入类
    self.audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:settings];
    //表明输入是否应该调整其处理为实时数据源的数据
    self.audioWriterInput.expectsMediaDataInRealTime = YES;
    //将音频输入源加入
    [self.writer addInput:self.audioWriterInput];
}

//完成视频录制时调用
- (void)finishWithCompletionHandler:(void (^)(void))handler {
    AVAssetWriterStatus status = self.writer.status ;
    if(status == AVAssetWriterStatusUnknown ||
       status == AVAssetWriterStatusFailed ||
       status == AVAssetWriterStatusCancelled){
        if(handler){
            handler();
        }
        return ;
    }
    [self.writer finishWritingWithCompletionHandler:handler];
}

//通过这个方法写入数据
- (BOOL)writeRecordToLocal:(CMSampleBufferRef) sampleBuffer isVideo:(BOOL)isVideo {
    //数据是否准备写入
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        //写入状态为未知,保证视频先写入
        if (self.writer.status == AVAssetWriterStatusUnknown && isVideo) {
            //获取开始写入的CMTime
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            //开始写入
            [self.writer startWriting];
            [self.writer startSessionAtSourceTime:startTime];
        }
        //写入失败
        AVAssetWriterStatus status = self.writer.status ;
        if(status == AVAssetWriterStatusUnknown ||
           status == AVAssetWriterStatusFailed ||
           status == AVAssetWriterStatusCancelled){
            return NO;
        }
        //判断是否是视频
        if (isVideo) {
            //视频输入是否准备接受更多的媒体数据
            if (self.videoWriterInput.readyForMoreMediaData) {
                //拼接数据
                [self.videoWriterInput appendSampleBuffer:sampleBuffer];
                return YES;
            }
        }else {
            //音频输入是否准备接受更多的媒体数据
            if (self.audioWriterInput.readyForMoreMediaData) {
                //拼接数据
                [self.audioWriterInput appendSampleBuffer:sampleBuffer];
                return YES;
            }
        }
    }
    return NO;
}

@end
