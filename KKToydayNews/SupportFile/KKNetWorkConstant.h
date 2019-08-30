//
//  KKNetWorkConstant.h
//  KKToydayNews
//
//  Created by KKFinger on 2019/5/16.
//  Copyright © 2019 finger. All rights reserved.
//

#ifndef KKNetWorkConstant_h
#define KKNetWorkConstant_h

//获取头条数据的服务器
#define KKNewsHost @"https://is.snssdk.com/"//新闻服务器
#define KKNovelHost @"http://ic.snssdk.com"//小说服务器
#define KKTeMaiHost @"http://temai.snssdk.com"//特卖服务器
//#define KKVideoHost @"http://i.snssdk.com/"//获取视频信息服务器

#define KKNewsFeed  @"api/news/feed/v65/"//获取新闻接口
#define KKFavSecFeed @"article/category/get_subscribed/v4/"//获取感兴趣的section
#define KKRecommonSecFeed @"article/category/get_extra/v1/"//获取推荐的section
#define KKXiGuaCatagoryFeed  @"video_api/get_category/v3"//西瓜视频分类
#define KKArticleFeed @"2/article/information/v23/"//查看文章详情
#define KKCommentFeedV2 @"article/v2/tab_comments/"//文章评论
#define KKUserCommentFeed @"2/comment/v1/detail/"//个人评论详情
#define KKUserCommentReplyFeed @"2/comment/v1/reply_list/"//个人评论的回复列表
#define KKUserCommentDiggFeed @"2/comment/v1/digg_list/"//个人评论的点赞用户列表
#define KKFetchVideoFeed @"video/urls/v/1/toutiao/mp4/"//获取视频信息
#define KKWTTDetailFeed @"ttdiscuss/v1/thread/detail/info/"//微头条详情信息
#define KKUserCenterFeed @"user/profile/homepage/v4/"//个人中心详情
#define KKUserDongTaiFeed @"dongtai/list/v14/"//用户动态
#define KKUserWenDaFeed @"wenda/profile/wendatab/brow/"//个人问答
#define KKUserWenDaMoreFeed @"wenda/profile/wendatab/loadmore/"//个人问答 加载更多
#define KKUserPgcFeed @"pgc/ma/"

#define KKVersionCode @"6.3.4"
#define KKAppName @"news_article"
#define KKVid @"8491C2DB-6EC5-4167-B6CB-6DFEAD81999F"
#define KKDeviceId @"39227613373"
#define KKOpenudid @"5285c37da03d39246b0f2238c43200fe8f545a89"
#define KKIdfv @"8491C2DB-6EC5-4167-B6CB-6DFEAD81999F"
#define KKIid @"15082941673"
#define KKIdfa @"2A40AEE2-84EF-44B4-8289-ED47DBCC8C51"

#endif /* KKNetWorkConstant_h */
