//
//  KKVideoInfo.h
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKVideoInfo : NSObject
@property(nonatomic)UIImage *videoCorver;//视频封面
@property(nonatomic,copy)NSString *filePath; // 本地路径
@property(nonatomic,copy)NSString *fileName; // 文件名
@property(nonatomic,copy)NSString *albumName;//
@property(nonatomic,copy)NSString *localIdentifier;
@property(nonatomic,copy)NSString *formatSize;//文件大小的文字描述
@property(nonatomic,copy)NSString *formatDuration;//时长的文字描述
@property(nonatomic,copy)NSDate *createDate;
@property(nonatomic,copy)NSDate *modifyDate;
@property(nonatomic,assign)NSTimeInterval duration ;
@property(nonatomic,assign)NSInteger itemIndex ;//视频在系统库中的索引
@property(nonatomic,assign)long long fileSize;
@property(nonatomic,assign)UIImageOrientation orientation;
@end
