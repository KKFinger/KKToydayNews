//
//  KKWTTDetailModel.h
//  KKToydayNews
//  微头条详情模型
//  Created by finger on 2017/11/11.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKModalBase.h"

@interface KKForumInfo :KKModalBase
@property(nonatomic,copy)NSString *forum_id;
@property(nonatomic,copy)NSString *forum_name;
@property(nonatomic,copy)NSString *status;
@property(nonatomic,copy)NSString *show_et_status;
@property(nonatomic,copy)NSString *share_url;
@property(nonatomic,copy)NSString *banner_url;
@property(nonatomic,copy)NSString *desc;
@property(nonatomic,copy)NSString *talk_count;
@property(nonatomic,copy)NSString *onlookers_count;
@property(nonatomic,copy)NSString *follower_count;
@property(nonatomic,copy)NSString *participant_count;
@property(nonatomic,copy)NSString *avatar_url;
@property(nonatomic,copy)NSString *introdution_url;
@property(nonatomic,copy)NSString *like_time;
@end

@interface KKPositionInfo:KKModalBase
@property(nonatomic,copy)NSString *latitude;
@property(nonatomic,copy)NSString *longitude;
@property(nonatomic,copy)NSString *position;
@property(nonatomic,copy)NSString *city;
@end

@interface KKThreadInfo :KKModalBase
@property(nonatomic,copy)NSString *thread_id;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *create_time;
@property(nonatomic,copy)NSString *modify_time;
@property(nonatomic,copy)NSString *forum_id;
@property(nonatomic,copy)NSString *status;
@property(nonatomic,copy)NSString *reason;
@property(nonatomic,copy)NSString *share_url;
@property(nonatomic,copy)NSString *digg_count;
@property(nonatomic,copy)NSString *read_count;
@property(nonatomic,copy)NSString *comment_count;
@property(nonatomic,copy)NSString *user_digg;
@property(nonatomic,copy)NSString *user_repin;
@property(nonatomic)KKPositionInfo *position;
@property(nonatomic)KKForumInfo *talk_item;
@property(nonatomic)KKUserInfoNew *user;
@property(nonatomic,copy)NSArray<KKUserInfoNew *> *digg_list;
@property(nonatomic,copy)NSArray<KKImageItem *> *large_image_list;
@property(nonatomic,copy)NSArray<KKImageItem *> *thumb_image_list;
@property(nonatomic,copy)NSArray<KKCommentObj *> *comments;
@property(nonatomic,copy)NSString *user_role;
@property(nonatomic,copy)NSString *talk_type;
@property(nonatomic,copy)NSString *show_comments_num;
@property(nonatomic,copy)NSString *cursor;
@property(nonatomic,copy)NSString *digg_limit;
@property(nonatomic,copy)NSString *show_origin;
@property(nonatomic,copy)NSString *show_tips;
@property(nonatomic,copy)NSString *forward_num;
@property(nonatomic,copy)NSDictionary *repost_params;
@end

@interface KKWTTDetailModel : KKModalBase
@property(nonatomic,copy)NSString *err_no;
@property(nonatomic,copy)NSString *ad;
@property(nonatomic,copy)NSDictionary *forum_extra;
@property(nonatomic,copy)NSDictionary *h5_extra;
@property(nonatomic,copy)NSString *like_desc;
@property(nonatomic,copy)NSString *repost_type;
@property(nonatomic)KKForumInfo *forum_info;
@property(nonatomic)KKThreadInfo *thread;
@end
