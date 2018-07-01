//
//  KKDongTaiModel.h
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKModalBase.h"
#import "KKWTTDetailModel.h"
#import "TYTextContainer.h"

@interface KKDongTaiGroup : KKModalBase
//@property(nonatomic,copy)NSString *open_url;
//@property(nonatomic,copy)NSString *show_tips;
@property(nonatomic)KKUserInfoNew *user;
//@property(nonatomic,copy)NSString *show_origin;
@property(nonatomic,copy)NSString *item_id;
@property(nonatomic,copy)NSString *thumb_url;
@property(nonatomic,copy)NSString *group_id;
@property(nonatomic,copy)NSString *source;
@property(nonatomic,copy)NSString *title;
//@property(nonatomic,copy)NSString *item_type;
@property(nonatomic,copy)NSString *image_url;
//@property(nonatomic,copy)NSString *item_id_str;
@property(nonatomic,copy)NSString *media_type;//1是普通新闻，2是视频新闻
//@property(nonatomic,copy)NSString *group_id_str;
@property(nonatomic,copy)NSString *isDelete;//delete

@property(nonatomic)TYTextContainer *textContainer;

@end

@interface KKDongTaiObject : KKModalBase
//@property(nonatomic,copy)NSString *comment_visible_count;
//@property(nonatomic,copy)NSString *comment_type;
//@property(nonatomic,copy)NSString *digg_limit;
//@property(nonatomic,copy)NSString *open_url;
//@property(nonatomic,copy)NSString *content_rich_span;
//@property(nonatomic)NSDictionary *origin_item;
@property(nonatomic)KKDongTaiGroup *group;
//@property(nonatomic)MSArray *image_type;
//@property(nonatomic,copy)NSString *share_url;
@property(nonatomic,copy)NSString *comment_count;
//@property(nonatomic,copy)NSString *id_str;
//@property(nonatomic,copy)NSString *type;
//@property(nonatomic,copy)NSString *is_repost;
@property(nonatomic,copy)NSString *comment_id;
//@property(nonatomic,copy)NSDictionary *origin_thread;
//@property(nonatomic,copy)NSString *is_admin;
@property(nonatomic,copy)NSArray<KKImageItem*> *thumb_image_list;
@property(nonatomic,copy)NSArray<KKImageItem*> *large_image_list;
//@property(nonatomic,copy)NSString *user_digg;
@property(nonatomic,copy)NSArray<KKImageItem*> *ugc_cut_image_list;
//@property(nonatomic,copy)NSArray *digg_list;
@property(nonatomic,copy)NSString *forward_num;
//@property(nonatomic,copy)NSDictionary *talk_item;
@property(nonatomic)KKDongTaiGroup *origin_group;
@property(nonatomic,copy)NSString *digg_count;
@property(nonatomic,copy)NSString *cursor;
//@property(nonatomic,copy)NSDictionary *repost_params;
//@property(nonatomic,copy)NSString *item_id_str;
@property(nonatomic,copy)NSString *isDelete;//delete
@property(nonatomic,copy)NSString *read_count;
//@property(nonatomic,copy)NSString *display_lines;
@property(nonatomic,copy)NSString *forward_count;
@property(nonatomic,copy)NSString *create_time;
//@property(nonatomic,copy)NSString *action_desc;
//@property(nonatomic,copy)NSString *device_type;
@property(nonatomic,copy)NSString *idStr;//id
//@property(nonatomic,copy)NSString *cell_type;
@property(nonatomic,copy)NSString *content_unescape;
//@property(nonatomic,copy)NSArray *comments;
@property(nonatomic,copy)NSString *content;
//@property(nonatomic,copy)NSString *comment_id_str;
//@property(nonatomic,copy)NSString *source_type;
//@property(nonatomic,copy)NSString *reason;
@property(nonatomic)KKUserInfoNew *user;
@property(nonatomic,copy)NSString *item_id;
//@property(nonatomic,copy)NSString *is_pgc_author;
//@property(nonatomic,copy)NSString *device_model;
//@property(nonatomic,copy)NSString *item_type;
//@property(nonatomic,copy)NSString *flags;
//@property(nonatomic,copy)NSString *modify_time;
@property(nonatomic)KKPositionInfo *position;

@property(nonatomic)TYTextContainer *textContainer;
@property(nonatomic,assign)CGFloat itemCellHeight;//cell的高度

@end

@interface KKDongTaiData : KKModalBase
@property(nonatomic,copy)NSString *max_cursor;
//@property(nonatomic,copy)NSString *login_status;
//@property(nonatomic,copy)NSString *has_more;
//@property(nonatomic,copy)NSArray *change_list;
//@property(nonatomic,copy)NSDictionary *tips;
@property(nonatomic,copy)NSString *min_cursor;
@property(nonatomic,copy)NSArray<KKDongTaiObject *> *dtObjectArray;//data
@end

@interface KKDongTaiModel : KKModalBase
@property(nonatomic,copy)NSString *message;
@property(nonatomic)KKDongTaiData *dtData;//data
@end
