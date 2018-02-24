//
//  KKDongTaiModel.m
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDongTaiModel.h"

@implementation KKDongTaiGroup

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"isDelete":@"delete"};
}

@end

@implementation KKDongTaiObject

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"thumb_image_list":[KKImageItem class],
             @"large_image_list":[KKImageItem class],
             @"ugc_cut_image_list":[KKImageItem class]};
}

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"isDelete":@"delete",
             @"idStr":@"id"
             };
}

@end

@implementation KKDongTaiData

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"dtObjectArray":[KKDongTaiObject class]};
}

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"dtObjectArray":@"data"};
}

@end

@implementation KKDongTaiModel

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"dtData":@"data"};
}

@end
