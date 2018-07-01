//
//  KKSummaryDataModel.h
//  KKToydayNews
//
//  Created by finger on 2017/9/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKModalBase.h"
#import "TYTextContainer.h"

//过滤词汇
@interface KKFilterWords : KKModalBase
@property(nonatomic,copy)NSString *filterId;
@property(nonatomic,copy)NSString *is_selected;
@property(nonatomic,copy)NSString *name;
@end

@interface KKUrlList:KKModalBase
@property(nonatomic,copy)NSString *url;
@end

//封面图片信息
@interface KKImageItem : KKModalBase
@property(nonatomic,assign)CGFloat height;
@property(nonatomic,assign)CGFloat width;
@property(nonatomic,assign)CGFloat cellHeight;//图片在cell中的实际高度(自适应)
@property(nonatomic,assign)CGFloat cellWidth;//图片在cell中的实际宽度(自适应)
//@property(nonatomic,copy)NSString *uri;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *desc;
@property(nonatomic)UIImage *image;
@property(nonatomic,copy)NSArray<KKUrlList *> *url_list;//只有一个键值对，key值为url

@property(nonatomic)TYTextContainer *textContainer;

@end

//媒体相关信息
@interface KKMediaInfo : KKModalBase
@property(nonatomic,copy)NSString *avatar_url;//头像
@property(nonatomic,copy)NSString *follow;//是否关注
//@property(nonatomic,copy)NSString *is_star_user;//是否是明星
@property(nonatomic,copy)NSString *media_id;
@property(nonatomic,copy)NSString *name;//名字
//@property(nonatomic,copy)NSString *recommend_reason;//推荐原因
//@property(nonatomic,copy)NSString *recommend_type;//推荐类型
@property(nonatomic,copy)NSString *user_id;//用户id
@property(nonatomic,copy)NSString *user_verified;//用户是否验证
@property(nonatomic,copy)NSString *verified_content;//描述
@end

@interface KKVideoDetailInfo : KKModalBase
@property(nonatomic)KKImageItem *detail_video_large_image;
//@property(nonatomic,copy)NSString *direct_play;
//@property(nonatomic,copy)NSString *group_flags;
//@property(nonatomic,copy)NSString *show_pgc_subscribe;
@property(nonatomic,copy)NSString *video_id;
//@property(nonatomic,copy)NSString *video_preloading_flag;
//@property(nonatomic,copy)NSString *video_type;
@property(nonatomic,copy)NSString *video_watch_count;
@property(nonatomic,copy)NSString *video_watching_count;
@end

@interface KKVideoItem : KKModalBase
//@property(nonatomic,copy)NSString *preload_interval;
//@property(nonatomic,copy)NSString *preload_max_step;
//@property(nonatomic,copy)NSString *preload_min_step;
//@property(nonatomic,copy)NSString *preload_size;
//@property(nonatomic,copy)NSString *socket_buffer;
//@property(nonatomic,copy)NSString *user_video_proxy;
//@property(nonatomic,copy)NSString *vheight;
//@property(nonatomic,copy)NSString *vwidth;
//@property(nonatomic,copy)NSString *size;
//@property(nonatomic,copy)NSString *vtype;
@property(nonatomic,copy)NSString *main_url; /// 用 base 64 加密的视频真实地址
@property(nonatomic,copy)NSString *backup_url_1;
@end

@interface KKVideoList : KKModalBase
@property(nonatomic)KKVideoItem *video_1;
@property(nonatomic)KKVideoItem *video_2;
@property(nonatomic)KKVideoItem *video_3;
@end

@interface KKVideoPlayInfo : KKModalBase
//@property(nonatomic,copy)NSString *status;
//@property(nonatomic,copy)NSString *message;
@property(nonatomic,copy)NSString *video_duration;
//@property(nonatomic,copy)NSString *validate;
//@property(nonatomic,copy)NSString *enable_ssl;
@property(nonatomic,copy)NSString *poster_url;
//@property(nonatomic,copy)NSDictionary *original_play_url;
@property(nonatomic)KKVideoList *video_list;
@end

//用户认证信息
@interface KKAuthInfo : KKModalBase
@property(nonatomic,copy)NSString *auth_type;
@property(nonatomic,copy)NSDictionary *other_auth;//{"pgc": "头条号科技作者"}
@property(nonatomic,copy)NSString *auth_info ;
@end

//用户的相关信息
@interface KKUserInfo : KKModalBase
@property(nonatomic,copy)NSString *avatar_url;//头像
@property(nonatomic,copy)NSString *follow;//是否关注
@property(nonatomic,copy)NSString *follower_count;//关注人数
@property(nonatomic,copy)NSString *description_;//介绍
//@property(nonatomic,copy)NSString *is_star_user;//是否是明星
@property(nonatomic,copy)NSString *media_id;
@property(nonatomic,copy)NSString *name;//名字
//@property(nonatomic,copy)NSString *recommend_reason;//推荐原因
//@property(nonatomic,copy)NSString *recommend_type;//推荐类型
@property(nonatomic,copy)NSString *user_id;//用户id
//@property(nonatomic,copy)NSString *user_verified;//用户是否验证
@property(nonatomic,copy)NSString *verified_content;//描述
@end

//新的用户信息
@interface KKUserInfoNew : KKModalBase
//@property(nonatomic,copy)NSString *is_blocking;
@property(nonatomic,copy)NSString *user_id;
@property(nonatomic,copy)NSString *media_id;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *uname;
@property(nonatomic,copy)NSString *screen_name;
//@property(nonatomic,copy)NSString *is_friend;
@property(nonatomic,copy)NSString *verified_content;
@property(nonatomic,copy)NSString *schema;
@property(nonatomic,copy)NSString *avatar_url;
@property(nonatomic,copy)NSString *is_following;
@property(nonatomic)KKAuthInfo *user_auth_info;
//@property(nonatomic,copy)NSString *is_blocked;
@property(nonatomic,copy)NSString *user_verified;
//@property(nonatomic,copy)NSArray *medals;
@property(nonatomic,copy)NSString *description_;
@property(nonatomic,copy)NSString *desc;
@property(nonatomic,copy)NSString *followers_count;
@property(nonatomic,copy)NSString *followings_count;
@end

//广告信息
@interface KKAdInfo : KKModalBase
@property(nonatomic,copy)NSString *app_name;
@property(nonatomic,copy)NSString *appleid;
@property(nonatomic,copy)NSString *button_text;
@property(nonatomic,copy)NSString *click_track_url;
@property(nonatomic,copy)NSString *description_;
@property(nonatomic,copy)NSString *display_type;
@property(nonatomic,copy)NSString *download_url;
@property(nonatomic,copy)NSString *hide_if_exists;
@property(nonatomic,copy)NSString *open_url;
@property(nonatomic,copy)NSString *package;
@property(nonatomic,copy)NSString *source;
@property(nonatomic,copy)NSString *track_url;
@property(nonatomic,copy)NSString *type;
@property(nonatomic,copy)NSString *ui_type;
@property(nonatomic,copy)NSString *web_title;
@property(nonatomic,copy)NSString *web_url;
@end

@interface KKSmallVideoAction : KKModalBase
@property(nonatomic,copy)NSString *read_count;
@property(nonatomic,copy)NSString *user_bury;
@property(nonatomic,copy)NSString *bury_count;
@property(nonatomic,copy)NSString *forward_count;
@property(nonatomic,copy)NSString *digg_count;
@property(nonatomic,copy)NSString *play_count;
@property(nonatomic,copy)NSString *comment_count;
@property(nonatomic,copy)NSString *user_repin;
@property(nonatomic,copy)NSString *user_digg;
@end

@interface KKAddressInfo : KKModalBase
@property(nonatomic,copy)NSArray<NSString *>* url_list;
@property(nonatomic,copy)NSString *uri;
@end

@interface KKSmallVideoPlayInfo : KKModalBase
@property(nonatomic,copy)NSString *ratio;
@property(nonatomic)KKAddressInfo *play_addr;
@property(nonatomic,copy)NSString *video_id;
@property(nonatomic,copy)NSString *height;
@property(nonatomic,copy)NSString *width;
@property(nonatomic)KKAddressInfo *download_addr;
@property(nonatomic)KKAddressInfo *origin_cover;
@property(nonatomic,copy)NSString *duration;
@end

@interface KKSmallVideoUserInfo : KKModalBase
@property(nonatomic)KKUserInfo *info;
@property(nonatomic,copy)NSDictionary *relation;
@property(nonatomic,copy)NSDictionary *relation_count;
@end

@interface KKSmallMusicInfo : KKModalBase
@property(nonatomic,copy)NSString *album;
@property(nonatomic,copy)NSString *cover_hd;
@property(nonatomic,copy)NSString *author;
@property(nonatomic,copy)NSString *music_id;
@property(nonatomic,copy)NSString *cover_large;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *cover_medium;
@property(nonatomic,copy)NSString *cover_thumb;
@end

@interface KKSmallVideoData:KKModalBase
//@property(nonatomic,copy)NSDictionary *status;
@property(nonatomic,copy)NSArray<KKImageItem *>*first_frame_image_list;
//@property(nonatomic,copy)NSString *recommand_reason;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSArray<KKImageItem *>*animated_image_list;
//@property(nonatomic,copy)NSString *detail_schema;
//@property(nonatomic,copy)NSDictionary *share;
//@property(nonatomic,copy)NSDictionary *publish_reason;
//@property(nonatomic,copy)NSString *label;
//@property(nonatomic,copy)NSDictionary *app_download;
@property(nonatomic)KKSmallVideoAction *action;
@property(nonatomic,copy)NSString *create_time;
@property(nonatomic)KKSmallVideoPlayInfo *video;
@property(nonatomic)KKSmallVideoUserInfo *user;
@property(nonatomic,copy)NSArray<KKImageItem *>*large_image_list;
//@property(nonatomic,copy)NSString *group_source;
@property(nonatomic,copy)NSString *item_id;
//@property(nonatomic)KKSmallMusicInfo *music;
@property(nonatomic,copy)NSString *group_id;
@property(nonatomic,copy)NSArray<KKImageItem *>*thumb_image_list;

@property(nonatomic)TYTextContainer *textContainer;

@end

/*
cell的布局方式
没有视频和图片：上面标题，下面评论、发布时间等信息
有图片:
1、image_list >= 3  上标题、中三张图片、下描述
2、只有一张图片
large_image_list >= 1 ,上标题、中一张大图片、下描述
middle_image 不为空，large_image_list为空 ,左边标题和描述，右边小图
有视频:
 large_image_list >= 1 ,上标题、中一张大图片、下描述
 middle_image 不为空,large_image_list为空 ,左边标题和描述，右边小图
 */
@interface KKSummaryContent : KKModalBase
//@property(nonatomic,copy)NSString *abstract;//内容摘要
@property(nonatomic,copy)NSString *article_url;//原文链接
@property(nonatomic,copy)NSString *display_url;
//@property(nonatomic,copy)NSString *behot_time;//
@property(nonatomic,copy)NSString *bury_count;//点踩的个数
@property(nonatomic,copy)NSString *digg_count;//点赞的个数
@property(nonatomic,copy)NSString *ban_comment;//是否禁止评论 0 不禁止 1 禁止
//@property(nonatomic,copy)NSString *allow_download;//是否允许下载
@property(nonatomic,copy)NSString *comment_count;//评论数
//@property(nonatomic,copy)NSArray<KKFilterWords*> *filter_words;//屏蔽词条
@property(nonatomic,copy)NSString *gallary_image_count;//摘要显示的图片个数
@property(nonatomic,copy)NSString *has_image;//摘要是否有相片
@property(nonatomic,copy)NSString *has_m3u8_video;
@property(nonatomic,copy)NSString *has_mp4_video;
@property(nonatomic,copy)NSString *has_video;
@property(nonatomic,copy)NSString *hot;//是否是热门
//@property(nonatomic,copy)NSString *keywords;//关键字
@property(nonatomic)KKImageItem *middle_image;
@property(nonatomic)KKImageItem *large_image;
@property(nonatomic,copy)NSArray<KKImageItem *> *large_image_list;
@property(nonatomic,copy)NSArray<KKImageItem *> *image_list;
@property(nonatomic,copy)NSArray<KKImageItem *> *thumb_image_list;
@property(nonatomic,copy)NSArray<KKImageItem *> *ugc_cut_image_list;
@property(nonatomic)KKMediaInfo *media_info;
@property(nonatomic)KKUserInfo *user_info;
@property(nonatomic)KKUserInfoNew *user;
//@property(nonatomic)KKAdInfo *ad_button;
@property(nonatomic)KKVideoDetailInfo *video_detail_info;
@property(nonatomic)KKSmallVideoData *smallVideo;//小视频
@property(nonatomic)KKVideoPlayInfo *video_play_info;//西瓜视频
@property(nonatomic,copy)NSString *publish_time;//发布时间
@property(nonatomic,copy)NSString *create_time;//发布时间
@property(nonatomic,copy)NSString *read_count;//浏览次数
@property(nonatomic,copy)NSString *share_count;//分享次数
@property(nonatomic,copy)NSString *repin_count;//收藏次数
//@property(nonatomic,copy)NSString *max_text_line;//文本的最大行数
//@property(nonatomic,copy)NSString *default_text_line;//文本的默认行数
@property(nonatomic,copy)NSString *share_url;
@property(nonatomic,copy)NSString *source;//来源
//@property(nonatomic,copy)NSString *source_open_url;
//@property(nonatomic,copy)NSString *source_avatar;//作者头像
//@property(nonatomic,copy)NSString *tag;//新闻的分类标签
//@property(nonatomic,copy)NSString *tag_id;//标签id
@property(nonatomic,copy)NSString *title;//标题
@property(nonatomic,copy)NSString *content;//认证用户发布的评论，类似微博
//@property(nonatomic,copy)NSString *user_verified;//用户是否验证
//@property(nonatomic,copy)NSString *verified_content;//验证内容
@property(nonatomic,copy)NSString *media_name;//名称
@property(nonatomic,copy)NSString *user_repin;//用户收藏
@property(nonatomic)NSDictionary *position;
@property(nonatomic,copy)NSDictionary *forward_info;//{"forward_count":0}，分享次数
@property(nonatomic,copy)NSString *item_id;
//@property(nonatomic,copy)NSString *item_version;
@property(nonatomic,copy)NSString *like_count;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *video_duration;
@property(nonatomic,copy)NSString *video_id;
@property(nonatomic,copy)NSString *ad_id;
//@property(nonatomic,copy)NSString *ad_label;
//@property(nonatomic,copy)NSString *display_info;
//@property(nonatomic,copy)NSString *expire_seconds;
@property(nonatomic,copy)NSString *sub_title;
@property(nonatomic,copy)NSString *group_id;
@property(nonatomic,copy)NSString *thread_id;
@property(nonatomic,copy)NSString *aggr_type;
@property(nonatomic,copy)NSString *gallary_style;//1 浏览图片形式 其他浏览新闻形式
//@property(nonatomic,copy)NSString *article_sub_type;
//@property(nonatomic,copy)NSString *article_type;
//@property(nonatomic,copy)NSDictionary *log_pb;//{"impr_id":"20170904205350010003026208463D82"}
//@property(nonatomic,copy)NSString *rid;
//@property(nonatomic,copy)NSString *show_portrait;
//@property(nonatomic,copy)NSString *show_portrait_article;
//@property(nonatomic,copy)NSString *tip;
//@property(nonatomic,copy)NSDictionary *ugc_recommend;
//@property(nonatomic,copy)NSString *level;
//@property(nonatomic,copy)NSString *ignore_web_transform;
//@property(nonatomic,copy)NSString *is_subject;
//@property(nonatomic,copy)NSString *video_style;
//@property(nonatomic,copy)NSString *cell_flag;
//@property(nonatomic,copy)NSString *cell_layout_style;
//@property(nonatomic,copy)NSString *cell_type;
//@property(nonatomic,copy)NSString *cursor;
//@property(nonatomic,copy)NSString *group_flags;
//@property(nonatomic,copy)NSString *source_icon_style;

//标题富文本
@property(nonatomic)TYTextContainer *textContainer;
//视频长度字符、图片个数字符等宽度
@property(nonatomic,assign)CGFloat newsTipWidth;
//item对应的cell的高度
@property(nonatomic,assign)CGFloat itemCellHeight;

@end

@interface KKContentDataModel : KKModalBase
@property(nonatomic)NSString *content;
@property(nonatomic)NSString *code ;
@end

@interface KKTipInfo : KKModalBase
//@property(nonatomic,copy)NSString *type;
//@property(nonatomic,copy)NSString *display_duration;
@property(nonatomic,copy)NSString *display_info;
//@property(nonatomic,copy)NSString *display_template;
//@property(nonatomic,copy)NSString *open_url;
//@property(nonatomic,copy)NSString *web_url;
//@property(nonatomic,copy)NSString *download_url;
//@property(nonatomic,copy)NSString *app_name;
//@property(nonatomic,copy)NSString *package_name;
@end

@interface KKSummaryDataModel : KKModalBase
@property(nonatomic)NSMutableArray<KKSummaryContent *> *contentArray;
@property(nonatomic,copy)NSMutableArray<KKContentDataModel*> *data;
@property(nonatomic,copy)NSString *message;
@property(nonatomic,copy)NSString *total_number;
//@property(nonatomic,copy)NSString *has_more;
//@property(nonatomic,copy)NSString *login_status;
//@property(nonatomic,copy)NSString *show_et_status;
//@property(nonatomic,copy)NSString *post_content_hint;
//@property(nonatomic,copy)NSString *has_more_to_refresh;
//@property(nonatomic,copy)NSString *action_to_last_stick;
//@property(nonatomic,copy)NSString *feed_flag;
@property(nonatomic)KKTipInfo *tips ;
@end
