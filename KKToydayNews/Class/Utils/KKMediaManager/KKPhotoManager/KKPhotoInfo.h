//
//  KKPhotoInfo.h
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface KKPhotoInfo : NSObject
@property(nonatomic,copy)NSString *identifier;
@property(nonatomic,copy)NSString *imageName;
@property(nonatomic,assign)NSInteger imageIndex;
@property(nonatomic,copy)NSString *albumId;//相片所在的相册
@property(nonatomic,copy)NSString *createDate;
@property(nonatomic,copy)NSString *modifyDate;
@property(nonatomic,assign)CGFloat imageWidth;
@property(nonatomic,assign)CGFloat imageHeight;
@property(nonatomic,assign)CGFloat dataSize;
@property(nonatomic)UIImage *image;
@property(nonatomic)NSData *imageData;
@property(nonatomic,assign)UIImageOrientation orientation;
@property(nonatomic,assign)BOOL isPlaceholderImage;
@property(nonatomic,assign)BOOL isSelected;
@end
