//
//  KKPersonalModel.m
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPersonalModel.h"

@implementation KKPersonalTopic
@end

@implementation KKPersonalInfo

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"topic":[KKPersonalTopic class]};
}

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"topic":@"top_tab",
             @"desc":@"description"
             };
}

@end


@implementation KKPersonalModel

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"info":@"data"};
}

@end
