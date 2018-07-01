//
//  KKUserCommentDetail.h
//  KKToydayNews
//  用户个人的评论详情，包括个人评论、点赞信息、全部的回复评论等
//  Created by finger on 2017/9/30.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKCommentModal.h"

/**
 回复信息
 */
@interface KKCommentReplyData:KKModalBase
@property(nonatomic,copy)NSArray<KKCommentObj*> *replyArray;
@property(nonatomic,copy)NSArray<KKCommentObj*> *hot_comments;
@property(nonatomic,copy)NSString *id_;
@property(nonatomic,copy)NSString *offset;
@property(nonatomic,copy)NSString *stick_has_more;
@property(nonatomic,copy)NSString *stick_total_number;
@property(nonatomic,copy)NSString *total_count;
@end

@interface KKCommentReply : KKModalBase
@property(nonatomic,copy)NSString *message;
@property(nonatomic)KKCommentReplyData *replyData;
@property(nonatomic,copy)NSString *ban_face;
@property(nonatomic,copy)NSString *stable;
@end




/**
 点赞信息
 */
@interface KKCommentDiggData : KKModalBase
@property(nonatomic,copy)NSString *anonymous_count;
@property(nonatomic,copy)NSString *total_count;
@property(nonatomic,copy)NSString *has_more;
@property(nonatomic,copy)NSArray<KKUserInfoNew*> *userList;
@property(nonatomic,copy)NSString *id_;
@end

@interface KKCommentDigg : KKModalBase
@property(nonatomic,copy)NSString *message;
@property(nonatomic)KKCommentDiggData *data;
@property(nonatomic,copy)NSString *stable;
@end



/**
 用户个人评论详情
 */
@interface KKUserCommentDetailObj : KKModalBase
@property(nonatomic,copy)NSString *status;
@property(nonatomic,copy)NSString *text;
@property(nonatomic,copy)NSString *is_pgc_author;
@property(nonatomic,copy)NSString *create_time;
@property(nonatomic)KKUserInfoNew *user ;
@property(nonatomic,copy)NSString *user_digg;
@property(nonatomic,copy)NSString *id_;
@property(nonatomic,copy)NSString *cell_type;
@property(nonatomic,copy)NSDictionary *group;
@property(nonatomic,copy)NSString *digg_count;
@property(nonatomic,copy)NSString *share_url;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *comment_count;
@property(nonatomic,copy)NSDictionary *log_param;
@property(nonatomic,copy)NSString *dongtai_id;
@property(nonatomic,copy)NSString *delete_;

@property(nonatomic)TYTextContainer *textContainer;

@end

@interface KKUserCommentDetail : KKModalBase
@property(nonatomic,copy)NSString *ban_face;
@property(nonatomic,copy)NSString *message;
@property(nonatomic,copy)NSString *show_repost_entrance;
@property(nonatomic)KKUserCommentDetailObj *detail;
@property(nonatomic,copy)NSString *stable;
@end
