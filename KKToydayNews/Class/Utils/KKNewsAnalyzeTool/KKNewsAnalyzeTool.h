//
//  KKNewsAnalyzeTool.h
//  KKToydayNews
//
//  Created by finger on 2017/10/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKNewsAnalyzeTool : NSObject

+ (void)fetchHtmlStringWithUrl:(NSString *)urlStr complete:(void(^)(NSString *htmlString))complete;

+ (void)fetchImageItemWithUrl:(NSString *)urlStr complete:(void(^)(NSArray<KKImageItem *> *imageArray))complete;

@end
