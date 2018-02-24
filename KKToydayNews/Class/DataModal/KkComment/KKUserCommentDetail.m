//
//  KKUserCommentDetail.m
//  KKToydayNews
//
//  Created by finger on 2017/9/30.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKUserCommentDetail.h"

@implementation KKCommentReplyData

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"id_":@"id",@"replyArray":@"data"};
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"replyArray":[KKCommentObj class],@"hot_comments":[KKCommentObj class]};
}

@end

@implementation KKCommentReply

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"replyData":@"data"};
}

@end


/**
 点赞信息
 */
@implementation KKCommentDiggData

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"id_":@"id",@"userList":@"data"};
}

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"userList":[KKUserInfoNew class]};
}

@end

@implementation KKCommentDigg

@end


/**
 用户个人评论详情
 */
@implementation KKUserCommentDetailObj

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"id_":@"id",@"delete_":@"delete"};
}

@end

@implementation KKUserCommentDetail

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"detail":@"data"};
}

@end
