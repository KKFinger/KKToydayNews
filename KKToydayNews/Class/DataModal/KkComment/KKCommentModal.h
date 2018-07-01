//
//  KKCommentModal.h
//  KKToydayNews
//
//  Created by finger on 2017/9/20.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYTextContainer.h"

@interface KKCommentObj : KKModalBase
@property(nonatomic,copy)NSString *Id;
@property(nonatomic,copy)NSString *text;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *reply_count;
@property(nonatomic,copy)NSArray<KKCommentObj*> *reply_list;
@property(nonatomic)KKCommentObj *reply_to_comment;
@property(nonatomic,copy)NSString *digg_count;
@property(nonatomic,copy)NSString *bury_count;
@property(nonatomic,copy)NSString *create_time;
@property(nonatomic,copy)NSString *score;
@property(nonatomic,copy)NSString *user_id;
@property(nonatomic,copy)NSString *user_name;
@property(nonatomic,copy)NSString *user_profile_image_url;
@property(nonatomic,copy)NSString *user_verified;
@property(nonatomic,copy)NSString *is_following;
@property(nonatomic,copy)NSString *is_followed;
@property(nonatomic,copy)NSString *is_blocking;
@property(nonatomic,copy)NSString *is_blocked;
@property(nonatomic,copy)NSString *is_pgc_author;
@property(nonatomic,copy)NSString *is_owner;
@property(nonatomic,copy)NSArray *author_badge;
@property(nonatomic,copy)NSString *verified_reason;
@property(nonatomic,copy)NSString *user_bury;
@property(nonatomic,copy)NSString *user_digg;
@property(nonatomic,copy)NSString *user_relation;
@property(nonatomic,copy)NSString *user_auth_info;
@property(nonatomic)KKMediaInfo *media_info;
@property(nonatomic)KKUserInfoNew *user;
@property(nonatomic,copy)NSString *platform;

@property(nonatomic)TYTextContainer *textContainer;

@end

@interface KKCommentItem : KKModalBase
@property(nonatomic)KKCommentObj *comment;
@property(nonatomic,copy)NSString *cell_type;
@property(nonatomic,assign)BOOL isShowAll;
@end

@interface KKCommentModal : KKModalBase
@property(nonatomic,copy)NSString *message;
@property(nonatomic,copy)NSArray<KKCommentItem*> *commentArray;
@property(nonatomic,copy)NSString *total_number;
@property(nonatomic,copy)NSString *has_more;
@property(nonatomic,copy)NSString *fold_comment_count;
@property(nonatomic,copy)NSString *detail_no_comment;
@property(nonatomic,copy)NSString *ban_comment;
@property(nonatomic,copy)NSString *ban_face;
@property(nonatomic,copy)NSString *go_topic_detail;
@property(nonatomic,copy)NSString *show_add_forum;
@property(nonatomic,copy)NSArray *stick_comments;
@property(nonatomic,copy)NSString *stick_total_number;
@property(nonatomic,copy)NSString *stick_has_more;
@property(nonatomic,copy)NSDictionary *tab_info;
@property(nonatomic,copy)NSString *stable;
@end
