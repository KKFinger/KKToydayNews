//
//  KKWTTDetailModel.m
//  KKToydayNews
//  微头条详情模型
//  Created by finger on 2017/11/11.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKWTTDetailModel.h"

@implementation KKForumInfo
@end

@implementation KKPositionInfo
@end

@implementation KKThreadInfo
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"digg_list":[KKUserInfoNew class],
             @"large_image_list":[KKImageItem class],
             @"thumb_image_list":[KKImageItem class],
             @"comments":[KKCommentObj class]
             };
}
@end

@implementation KKWTTDetailModel
@end
