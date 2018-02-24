//
//  KKCommentModal.m
//  KKToydayNews
//
//  Created by finger on 2017/9/20.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKCommentModal.h"

@implementation KKCommentObj

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"Id":@"id"};
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"reply_list":[KKCommentObj class]};
}

@end

@implementation KKCommentItem

@end

@implementation KKCommentModal

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"commentArray":@"data"};
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"commentArray":[KKCommentItem class]};
}

@end
