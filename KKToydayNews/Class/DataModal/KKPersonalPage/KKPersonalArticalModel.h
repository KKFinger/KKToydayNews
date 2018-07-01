//
//  KKPersonalArticalModel.h
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKModalBase.h"

@interface KKPersonalVideoInfo:KKModalBase
@property(nonatomic,copy)NSString *thumb_height;
@property(nonatomic,copy)NSString *sp;
@property(nonatomic,copy)NSString *vid;
@property(nonatomic,copy)NSString *thumb_width;
@property(nonatomic,copy)NSString *video_partner;
@property(nonatomic,copy)NSString *duration;
@property(nonatomic,copy)NSString *thumb_url;
@property(nonatomic,copy)NSDictionary *video_size;
@property(nonatomic,copy)NSString *vu;
@end

@interface KKPersonalSummary:KKModalBase
//@property(nonatomic,copy)NSString *detail_mode;
//@property(nonatomic,copy)NSString *play_effective_count;
//@property(nonatomic,copy)NSString *impression_count;
@property(nonatomic,copy)NSArray<KKImageItem*> *image_list;
//@property(nonatomic,copy)NSString *item_status;
@property(nonatomic,copy)NSString *datetime;
@property(nonatomic,copy)NSArray<KKPersonalVideoInfo *> *video_infos;
//@property(nonatomic,copy)NSString *str_item_id;
//@property(nonatomic,copy)NSString *group_status;
//@property(nonatomic,copy)NSString *keywords;
//@property(nonatomic,copy)NSArray *label;
@property(nonatomic,copy)NSString *creator_uid;//用户id
//@property(nonatomic,copy)NSString *original_media_id;
//@property(nonatomic,copy)NSString *city;
@property(nonatomic,copy)NSString *bury_count;
@property(nonatomic,copy)NSString *title;
//@property(nonatomic,copy)NSString *web_article_type;
@property(nonatomic,copy)NSString *source;
@property(nonatomic,copy)NSString *comment_count;
//@property(nonatomic,copy)NSString *natant_level;
//@property(nonatomic,copy)NSString *own_group;
@property(nonatomic,copy)NSString *share_count;
//@property(nonatomic,copy)NSString *internal_visit_count;
//@property(nonatomic,copy)NSString *list_play_effective_count;
@property(nonatomic,copy)NSString *media_id;
//@property(nonatomic,copy)NSString *go_detail_count;
//@property(nonatomic,copy)NSString *group_flags;
@property(nonatomic,copy)NSString *total_read_count;
//@property(nonatomic,copy)NSString *detail_play_effective_count;
//@property(nonatomic,copy)NSString *visibility;
//@property(nonatomic,copy)NSString *ad_type;
//@property(nonatomic,copy)NSString *was_recommended;
//@property(nonatomic,copy)NSArray *categories;
//@property(nonatomic,copy)NSArray<KKImageItem *> *thumb_image;
//@property(nonatomic,copy)NSString *seo_url;
//@property(nonatomic,copy)NSString *level;
//@property(nonatomic,copy)NSString *display_status;
@property(nonatomic,copy)NSString *repin_count;
@property(nonatomic,copy)NSString *digg_count;
//@property(nonatomic,copy)NSString *is_key_item;
//@property(nonatomic,copy)NSArray<KKImageItem *> *image_detail;
//@property(nonatomic,copy)NSString *ban_action;
//@property(nonatomic,copy)NSString *review_comment_mode;
@property(nonatomic,copy)NSString *comments_count;
@property(nonatomic,copy)NSString *has_inner_video;
@property(nonatomic,copy)NSString *has_image;
//@property(nonatomic,copy)NSArray<KKImageItem *> *cover_image_infos;
@property(nonatomic,copy)NSString *group_id;
//@property(nonatomic,copy)NSString *middle_image;
//@property(nonatomic,copy)NSString *play_effective_count_num;
//@property(nonatomic,copy)NSArray *slave_infos;
//@property(nonatomic,copy)NSString *article_live_type;
@property(nonatomic,copy)NSString *has_m3u8_video;
//@property(nonatomic,copy)NSString *ban_comment;
//@property(nonatomic,copy)NSString *pgc_id;
@property(nonatomic,copy)NSString *abstract;
//@property(nonatomic,copy)NSString *middle_mode;
//@property(nonatomic,copy)NSString *is_original;
//@property(nonatomic,copy)NSString *ban_bury;
//@property(nonatomic,copy)NSString *external_visit_count;
//@property(nonatomic,copy)NSString *article_type;
//@property(nonatomic,copy)NSString *tag;
@property(nonatomic,copy)NSString *behot_time;
//@property(nonatomic,copy)NSDictionary *optional_data;
//@property(nonatomic,copy)NSString *app_url;
//@property(nonatomic,copy)NSString *book_info;
//@property(nonatomic,copy)NSString *article_sub_type;
//@property(nonatomic,copy)NSString *internal_visit_count_format;
@property(nonatomic,copy)NSString *has_video;
@property(nonatomic,copy)NSString *has_mp4_video;
//@property(nonatomic,copy)NSString *pgc_ad;
@property(nonatomic,copy)NSString *article_url;
@property(nonatomic,copy)NSString *create_time;
@property(nonatomic,copy)NSString *group_source;
//@property(nonatomic,copy)NSString *display_mode;
//@property(nonatomic,copy)NSString *image_url;
//@property(nonatomic,copy)NSString *composition;
//@property(nonatomic,copy)NSString *str_group_id;
@property(nonatomic,copy)NSString *publish_time;
//@property(nonatomic,copy)NSString *wap_open;
//@property(nonatomic,copy)NSString *tag_id;
@property(nonatomic,copy)NSString *source_url;
//@property(nonatomic,copy)NSString *pgc_article_type;
//@property(nonatomic,copy)NSString *display_type;
@property(nonatomic,copy)NSString *item_id;
//@property(nonatomic,copy)NSString *good_voice;
//@property(nonatomic,copy)NSString *pc_image_url;
//@property(nonatomic,copy)NSArray *gallery;
@property(nonatomic,copy)NSString *detail_source;
//@property(nonatomic,copy)NSDictionary *verify_detail;
@property(nonatomic,copy)NSString *max_comments;
//@property(nonatomic,copy)NSString *language;
@property(nonatomic,copy)NSString *display_url;
@property(nonatomic,copy)NSString *url;
//@property(nonatomic,copy)NSString *region;
//@property(nonatomic,copy)NSString *web_display_type;
//@property(nonatomic,copy)NSArray<KKImageItem*> *image_infos;
//@property(nonatomic,copy)NSString *content_cards;
@property(nonatomic,copy)NSString *has_gallery;
@property(nonatomic,copy)NSString *gallery_pic_count;
//@property(nonatomic,copy)NSString *modify_time;
//@property(nonatomic,copy)NSString *content_cntw;
//@property(nonatomic,copy)NSString *review_comment;
//@property(nonatomic,copy)NSString *external_visit_count_format;

//标题富文本
@property(nonatomic)TYTextContainer *textContainer;

@property(nonatomic,assign)CGFloat newsTipWidth;

@end

@interface KKNextKey:KKModalBase
@property(nonatomic,copy)NSString *max_behot_time;
@end

@interface KKPersonalArticalModel : KKModalBase
@property(nonatomic,copy)NSString *media_id;
//@property(nonatomic,copy)NSString *has_more;
@property(nonatomic)KKNextKey *next;//key:max_behot_time
//@property(nonatomic,copy)NSString *page_type;
//@property(nonatomic,copy)NSString *message;
@property(nonatomic,copy)NSArray<KKPersonalSummary *> *summaryArray;//data
@end
