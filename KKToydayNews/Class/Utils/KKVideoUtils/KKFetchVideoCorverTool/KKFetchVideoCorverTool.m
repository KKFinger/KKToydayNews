//
//  KKFetchVideoCorverTool.m
//  KKToydayNews
//
//  Created by finger on 2017/11/8.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKFetchVideoCorverTool.h"
#import <AVFoundation/AVFoundation.h>

@interface KKFetchVideoCorverTool ()
@property(nonatomic)AVAssetImageGenerator *generator;
@property(nonatomic)CGFloat duration ;
@property(nonatomic)NSOperationQueue *fetchQueue;
@property(nonatomic,copy)completeBlock completeBlock;
@end

@implementation KKFetchVideoCorverTool

+ (instancetype)sharedInstance{
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

+ (void)fetchCorverWithFilePath:(NSString *)filePath seconds:(NSTimeInterval)sec callback:(void (^)(UIImage *movieImage))handler{
    if(!filePath.length){
        if (handler) {
            handler(nil);
        }
    }
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(sec, 600);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(thumbImg);
                });
            }
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:
     [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
}

- (void)setupEnvWithFilePath:(NSString *)filePath{
    if(filePath == nil){
        filePath = @"";
    }
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    self.generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    self.generator.appliesPreferredTrackTransform = TRUE;
    self.generator.maximumSize = CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenWidth);
    self.generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    self.generator.requestedTimeToleranceAfter = kCMTimeZero;
    self.generator.requestedTimeToleranceBefore = kCMTimeZero;
    self.duration = asset.duration.value / asset.duration.timescale;
    
    self.fetchQueue = [[NSOperationQueue alloc]init];
    self.fetchQueue.maxConcurrentOperationCount = 1 ;
}

- (void)asyncFetchCorverWithPosition:(CGFloat)position callback:(completeBlock)handler {
    NSTimeInterval seconds = self.duration * position;
    [self asyncFetchCorverWithSeconds:seconds callback:handler];
}

- (void)asyncFetchCorverWithSeconds:(NSTimeInterval)sec callback:(completeBlock)handler {
    self.completeBlock = handler ;
    [self.fetchQueue cancelAllOperations];
    
    @weakify(self);
    NSBlockOperation *blockOpt = [[NSBlockOperation alloc]init];
    [blockOpt addExecutionBlock:^{
        @strongify(self);
        if(!self.generator){
            if(self.completeBlock){
                self.completeBlock(nil);
            }
            return ;
        }
        CMTime thumbTime = CMTimeMakeWithSeconds(sec, 600);
        AVAssetImageGeneratorCompletionHandler generatorHandler =
        ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
            if (result == AVAssetImageGeneratorSucceeded) {
                UIImage *image = [UIImage imageWithCGImage:im];
                if (self.completeBlock) {
                    self.completeBlock(image);
                }
            }
        };
        [self.generator generateCGImagesAsynchronouslyForTimes:
         [NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:generatorHandler];
    }];
    [self.fetchQueue addOperation:blockOpt];
}

- (void)asyncCopyCorverWithPosition:(CGFloat)position callback:(completeBlock)handler{
    NSTimeInterval seconds = self.duration * position;
    [self asyncCopyCorverWithSeconds:seconds callback:handler];
}

- (void)asyncCopyCorverWithSeconds:(NSTimeInterval)sec callback:(completeBlock)handler{
    self.completeBlock = handler ;
    [self.fetchQueue cancelAllOperations];
    
    @weakify(self);
    NSBlockOperation *blockOpt = [[NSBlockOperation alloc]init];
    [blockOpt addExecutionBlock:^{
        @strongify(self);
        if(!self.generator){
            if(self.completeBlock){
                self.completeBlock(nil);
            }
            return ;
        }
        UIImage *image = [self syncCopyCorverWithSeconds:sec];
        if (self.completeBlock) {
            self.completeBlock(image);
        }
    }];
    [self.fetchQueue addOperation:blockOpt];
}

- (UIImage *)syncCopyCorverWithPosition:(CGFloat)position{
    NSTimeInterval seconds = self.duration * position;
    return [self syncCopyCorverWithSeconds:seconds];
}

- (UIImage *)syncCopyCorverWithSeconds:(NSTimeInterval)sec{
    if(!self.generator){
        return nil;
    }
    NSError *error = nil;
    CMTime actualTime;
    CMTime thumbTime = CMTimeMakeWithSeconds(sec, 600);
    CGImageRef imageRef = [self.generator copyCGImageAtTime:thumbTime actualTime:&actualTime error:&error];
    UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return image ;
}

@end
