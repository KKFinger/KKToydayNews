//
//  KKPersonalArticalModel.m
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPersonalArticalModel.h"

@implementation KKPersonalVideoInfo

@end

@implementation KKPersonalSummary

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"image_list":[KKImageItem class],
             @"video_infos":[KKPersonalVideoInfo class]
             };
}

@end

@implementation KKNextKey
@end

@implementation KKPersonalArticalModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"summaryArray":[KKPersonalSummary class]};
}

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"summaryArray":@"data"};
}

@end
