//
//  KKArticleModal.h
//  KKToydayNews
//
//  Created by finger on 2017/9/20.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYTextContainer.h"

@interface KKNewsBaseInfo:NSObject
@property(nonatomic,copy)NSString *groupId;
@property(nonatomic,copy)NSString *itemId;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *publicTime;
@property(nonatomic,copy)NSString *catagory;
@property(nonatomic,copy)NSString *articalUrl;
@property(nonatomic,copy)NSString *source;
@property(nonatomic,copy)NSString *commentCount;
@property(nonatomic,copy)NSString *videoWatchCount;
@property(nonatomic,copy)NSString *diggCount;
@property(nonatomic,copy)NSString *buryCount;
@property(nonatomic)KKUserInfo *userInfo;
@property(nonatomic)TYTextContainer *textContainer;
@end

@interface KKRelatedNews : KKModalBase
@property(nonatomic,copy)NSDictionary *log_pb;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *open_page_url;
@property(nonatomic,copy)NSString *type_name;
@property(nonatomic,copy)NSString *impr_id;
@property(nonatomic,copy)NSString *item_id;
@property(nonatomic,copy)NSString *group_id;
@property(nonatomic,copy)NSString *aggr_type;
@end

@interface KKMixed : KKModalBase
@property(nonatomic,copy)NSString *button_text;
@property(nonatomic,copy)NSString *display_subtype;
@property(nonatomic,copy)NSArray<KKFilterWords*> *filter_words;
@property(nonatomic,copy)NSString *Id;
@property(nonatomic,copy)NSString *image;
@property(nonatomic,copy)NSString *image_height;
@property(nonatomic,copy)NSString *image_width;
@property(nonatomic,copy)NSString *label;
@property(nonatomic,copy)NSDictionary *log_extra;
@property(nonatomic,copy)NSString *open_url;
@property(nonatomic,copy)NSString *show_dislike;
@property(nonatomic,copy)NSString *source_name;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *track_url;
@property(nonatomic,copy)NSArray *track_url_list;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *web_title;
@property(nonatomic,copy)NSString *web_url;
@end

@interface KKAdItem : KKModalBase
@property(nonatomic,copy)NSString *is_preview;
@property(nonatomic)KKMixed *mixed;
@end

@interface KKLikeAndReward : KKModalBase
@property(nonatomic,copy)NSString *user_like;
@property(nonatomic,copy)NSString *rewards_list_url;
@property(nonatomic,copy)NSArray *rewards_list;
@property(nonatomic,copy)NSString *like_num;
@property(nonatomic,copy)NSString *rewards_open_url;
@property(nonatomic,copy)NSString *rewards_num;
@end

@interface KKLabelItem : KKModalBase
@property(nonatomic,copy)NSString *word;
@property(nonatomic,copy)NSString *link;
@end

@interface KKOrderInfo : KKModalBase
@property(nonatomic,copy)NSArray<KKLabelItem*> *labels;
@property(nonatomic)KKLikeAndReward *like_and_rewards;
@property(nonatomic)KKAdItem *ad;
@property(nonatomic,copy)NSArray<KKRelatedNews *> *related_news;
@end

@interface KKArticleData : KKModalBase
@property(nonatomic,copy)NSDictionary *log_pb;
@property(nonatomic,copy)NSDictionary *h5_extra;
@property(nonatomic,copy)NSString *user_bury;
@property(nonatomic,copy)NSString *ban_comment;
@property(nonatomic,copy)NSString *ban_bury;
@property(nonatomic,copy)NSString *related_video_section;
@property(nonatomic,copy)NSString *like_count;
@property(nonatomic,copy)NSString *like_desc;
@property(nonatomic,copy)NSArray *related_gallery;
@property(nonatomic,copy)NSString *info_flag;
@property(nonatomic,copy)NSString *is_wenda;
@property(nonatomic,copy)NSString *user_digg;
@property(nonatomic,copy)NSString *ban_digg;
@property(nonatomic,copy)NSString *detail_show_flags;
@property(nonatomic,copy)NSDictionary *context;
@property(nonatomic,copy)NSString *group_flags;
@property(nonatomic,copy)NSString *bury_count;
@property(nonatomic,copy)NSString *script;
@property(nonatomic,copy)NSString *ignore_web_transform;
@property(nonatomic)KKUserInfo *user_info;
@property(nonatomic,copy)NSString *display_url;
@property(nonatomic,copy)NSString *digg_count;
@property(nonatomic,copy)NSString *share_url;
@property(nonatomic,copy)NSString *source;
@property(nonatomic,copy)NSString *comment_count;
@property(nonatomic,copy)NSArray<KKFilterWords *> *filter_words;
@property(nonatomic,copy)NSString *repin_count;
@property(nonatomic,copy)NSString *user_repin;
@property(nonatomic,copy)NSString *url;
@property(nonatomic)KKMediaInfo *media_info;
@property(nonatomic,copy)NSString *group_id;
@property(nonatomic)KKOrderInfo *ordered_info;
@property(nonatomic,copy)NSArray<KKSummaryContent*> *related_video_toutiao;
@end

@interface KKArticleModal : KKModalBase
@property(nonatomic,copy)NSString *message;
@property(nonatomic)KKArticleData *articleData;
@end
