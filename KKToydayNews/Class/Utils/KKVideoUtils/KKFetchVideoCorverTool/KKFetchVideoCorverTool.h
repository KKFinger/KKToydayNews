//
//  KKFetchVideoCorverTool.h
//  KKToydayNews
//
//  Created by finger on 2017/11/8.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completeBlock)(UIImage *image);

@interface KKFetchVideoCorverTool : NSObject
+ (instancetype)sharedInstance;
+ (void)fetchCorverWithFilePath:(NSString *)filePath seconds:(NSTimeInterval)sec callback:(void (^)(UIImage *movieImage))handler;
- (void)setupEnvWithFilePath:(NSString *)filePath;
- (void)asyncFetchCorverWithPosition:(CGFloat)position callback:(completeBlock)handler;
- (void)asyncFetchCorverWithSeconds:(NSTimeInterval)sec callback:(completeBlock)handler;
- (void)asyncCopyCorverWithPosition:(CGFloat)position callback:(completeBlock)handler;
- (void)asyncCopyCorverWithSeconds:(NSTimeInterval)sec callback:(completeBlock)handler;
- (UIImage *)syncCopyCorverWithPosition:(CGFloat)position;
- (UIImage *)syncCopyCorverWithSeconds:(NSTimeInterval)sec;
@end
