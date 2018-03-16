//
//  KKVideoMergeTool.h
//  KKToydayNews
//
//  Created by finger on 2017/11/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKVideoInfo.h"

typedef void(^sucBlock)(KKVideoInfo *videoInfo);
typedef void(^failBlock)();

@interface KKVideoMergeTool : NSObject
+(void)mergeVideoWithUrlhArray:(NSArray<NSURL *> *)urlArray
               storeFolderPath:(NSString *)storeFolderPath
                     storeName:(NSString *)storeName
                          is3d:(BOOL)is3d
                       success:(sucBlock)successBlock
                       failure:(failBlock)failureBlcok;
@end
