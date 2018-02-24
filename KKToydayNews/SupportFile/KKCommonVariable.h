//
//  KKCommonVariable.h
//  KKToydayNews
//
//  Created by finger on 2017/8/8.
//  Copyright © 2017年 finger. All rights reserved.
//

#ifndef KKCommonVariable_h
#define KKCommonVariable_h

#import "KKSummaryDataModel.h"
#import "KKUserCommentDetail.h"

/* 外边距、内边距 */
//外边距
static float const kkMarginSuper = 70.f;
static float const kkMarginMax = 55.f;
static float const kkMarginHuge = 45.f;
static float const kkMarginLarge = 40.f;
static float const kkMarginNormal = 30.f;
static float const kkMarginSmall = 20.f;
static float const kkMarginMin = 15.f;
static float const kkMarginTiny = 10.f;
//内边距
static float const kkPaddingSuper = 30.f;
static float const kkPaddingMax = 25.f;
static float const kkPaddingHuge = 20.f;
static float const kkPaddingLarge = 15.f;
static float const kkPaddingNormal = 10.f;
static float const kkPaddingSmall = 5.f;
static float const kkPaddingMin = 4.f;
static float const kkPaddingTiny = 2.f;

/* 图标、头像尺寸 */
//图标
static CGSize const kkIconSizeSuper = (CGSize){37.f, 37.f};
static CGSize const kkIconSizeMax = (CGSize){33.f, 33.f};
static CGSize const kkIconSizeHuge = (CGSize){27.f, 27.f};
static CGSize const kkIconSizeLarge = (CGSize){24.f, 24.f};
static CGSize const kkIconSizeNormal = (CGSize){22.f, 22.f};
static CGSize const kkIconSizeSmall = (CGSize){20.f, 20.f};
static CGSize const kkIconSizeMin = (CGSize){18.f, 18.f};
static CGSize const kkIconSizeTiny = (CGSize){15.f, 15.f};
static CGSize const kkIconSizeMinimum = (CGSize){12.f, 12.f};
//图片/头像
static CGSize const kkImageSizeSuper = (CGSize){105.f, 105.f};
static CGSize const kkImageSizeMax = (CGSize){90.f, 90.f};
static CGSize const kkImageSizeHuge = (CGSize){75.f, 75.f};
static CGSize const kkImageSizeLarge = (CGSize){62.f, 62.f};
static CGSize const kkImageSizeNormal = (CGSize){45.f, 45.f};
static CGSize const kkImageSizeSmall = (CGSize){42.f, 42.f};
static CGSize const kkImageSizeMin = (CGSize){40.f, 40.f};
static CGSize const kkImageSizeTiny = (CGSize){30.f, 30.f};
static CGSize const kkImageSizeMinimum = (CGSize){25.f, 25.f};

/* 不透明度 */
static float const kkLowOpacity = .3f;//30%，低不透明
static float const kkNormalOpacity = .5f;//50%，中不透明(常用于按钮)
static float const kkHighOpacity = .75f;//75%，高不透明(常用语遮罩）

typedef NS_ENUM(NSInteger, KKSectionOpType){
    KKSectionOpTypeAddToFavSection,//添加到用户感兴趣的板块
    KKSectionOpTypeRemoveFromFavSection,//从用户感兴趣的板块中删除
};

typedef NS_ENUM(NSInteger, KKNetworkStatus){
    KKNetworkStatusUnknown = -1,//未知状态
    KKNetworkStatusNotReachable = 0,//无网状态
    KKNetworkStatusReachableViaWWAN = 1,//手机网络
    KKNetworkStatusReachableViaWiFi = 2,//Wifi网络
};

typedef NS_ENUM(NSInteger, KKBarButtonType){
    KKBarButtonTypeUpvote,//点赞
    KKBarButtonTypeComment,//评论
    KKBarButtonTypeShare,//分享
    KKBarButtonTypeBury,//点踩
    KKBarButtonTypeFavorite,//收藏
    KKBarButtonTypeMore,//收藏
    KKBarButtonTypeConcern,//关注
    KKBarButtonTypePlayVideo,//播放视频
};

typedef NS_ENUM(NSInteger, KKMoveDirection){
    KKMoveDirectionNone,
    KKMoveDirectionUp,
    KKMoveDirectionDown,
    KKMoveDirectionRight,
    KKMoveDirectionLeft
} ;

typedef NS_ENUM(NSInteger, KKShowViewType){
    KKShowViewTypeNone,
    KKShowViewTypePush,
    KKShowViewTypePopup,
} ;

typedef NS_ENUM(NSInteger, KKBottomBarType){
    KKBottomBarTypePersonalComment,//个人评论页面
    KKBottomBarTypePictureComment,//图片新闻的评论页面
    KKBottomBarTypeNewsDetail,//新闻详情页面
} ;

//用户访问相册权限
typedef NS_ENUM(NSInteger, KKPhotoAuthorizationStatus){
    KKPhotoAuthorizationStatusNotDetermined = 0,  // User has not yet made a choice with regards to this application
    
    KKPhotoAuthorizationStatusRestricted,         // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //   such as parental controls being in place.
    KKPhotoAuthorizationStatusDenied,             // User has explicitly denied this            application access to photos data.
    
    KKPhotoAuthorizationStatusAuthorized         // User has authorized this application to access photos data.
};

//相片分组的日期格式
typedef NS_ENUM(NSInteger, KKDateFormat){
    KKDateFormatYMD = 0, // yyyy-mm-dd
    KKDateFormatYM,// yyyy-mm
    KKDateFormatYear //yyyy
};

typedef NS_ENUM(NSInteger,KKViewTag){
    KKViewTagPersonInfoScrollView = 100000 ,//他人信息(动态，文章等视图的父视图)scrollview的tag，主要用于解决手势冲突
    KKViewTagRecognizeSimultaneousTableView,//他人信息最外层tableview的tag，主要用于解决手势冲突
    KKViewTagPersonInfoDongTai ,//他人信息动态视图的uitableview的tag，主要用于解决手势冲突
    KKViewTagPersonInfoArtical ,//他人信息文章视图的uitableview的tag，主要用于解决手势冲突
    KKViewTagPersonInfoVideo ,//他人信息视频视图的uitableview的tag，主要用于解决手势冲突
    KKViewTagPersonInfoWenDa ,//他人信息问答视图的uitableview的tag，主要用于解决手势冲突
    KKViewTagPersonInfoRelease ,//他人信息发布厅视图的uitableview的tag，主要用于解决手势冲突
    KKViewTagPersonInfoMatrix ,//他人信息矩阵视图的uitableview的tag，主要用于解决手势冲突
    KKViewTagUserCenterView ,//个人中心的uitableview的tag，主要用于解决手势冲突
    KKViewTagImageDetailView ,//相片预览视图tag，主要用于解决手势冲突
    KKViewTagImageDetailDescView ,//相片描述视图tag，主要用于解决手势冲突
};

@protocol KKCommonDelegate <NSObject>
@optional
- (void)clickButtonWithType:(KKBarButtonType)type item:(KKSummaryContent *)item;
- (void)shieldBtnClicked:(KKSummaryContent *)item;
- (void)jumpToUserPage:(NSString *)userId;
- (void)clickImageWithItem:(KKSummaryContent *)item rect:(CGRect)rect fromView:(UIView *)fromView image:(UIImage *)image indexPath:(NSIndexPath *)indexPath;
@end

@protocol KKCommentDelegate <NSObject>
@optional
- (void)diggBtnClick:(NSString *)commemtId callback:(void(^)(BOOL suc))callback;
- (void)setConcern:(BOOL)isConcern userId:(NSString *)userId callback:(void(^)(BOOL isSuc))callback;
- (void)jumpToUserPage:(NSString *)userId;
- (void)showAllDiggUser:(NSString *)commemtId;
- (void)reportUser:(NSString *)userId ;
- (void)showAllComment:(NSString *)commentId;
@end

//获取这个板块信息(如标题，concern_id等)
static inline NSArray *kkCatagoryItem(){
    NSArray *array = @[
                       /*@{
                           @"category":@"推荐",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"推荐",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"6286225228934679042",
                           @"type":@(4),
                           @"icon_url":@""
                           },*/
                       @{
                           @"category":@"news_hot",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"热点",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                        },
                       @{
                           @"category":@"video",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"视频",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_world",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"国际新闻",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_society",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"社会",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"组图",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"图片",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_military",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"军事",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"image_funny",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"趣图",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_tech",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"科技",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_car",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"汽车",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_finance",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"财经",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_sports",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"体育",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"essay_joke",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"笑话",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"image_ppmm",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"美女",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_entertainment",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"娱乐",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"question_and_answer",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"问答",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_local",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"本地",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_health",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"健康",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"jinritemai",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"特卖",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_house",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"房产",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"hotsoon_video",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"小视频",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"novel_channel",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"小说",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_fashion",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"时尚",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_history",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"历史",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_baby",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"育儿",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"live_talk",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"直播",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"funny",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"搞笑",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"digital",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"数码",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_food",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"美食",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_regimen",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"养生",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"movie",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"电影",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"cellphone",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"手机",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"positive",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"正能量",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"中国好表演",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"中国好表演",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"weitoutiao",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"微头条",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"hotsoon",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"火山直播",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"彩票",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"彩票",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"中国新唱将",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"中国新唱将",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"快乐男声",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"快乐男声",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_astrology",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"星座",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"image_wonderful",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"美图",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"government",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"政务",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"rumor",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"辟谣",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_story",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"故事",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_collect",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"收藏",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"boutique",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"精选",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"essay_saying",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"语录",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_game",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"游戏",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"stock",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"股票",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"science_all",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"科学",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_comic",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"动漫",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_edu",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"教育",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_agriculture",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"三农",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"pregnancy",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"孕产",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_culture",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"文化",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_travel",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"旅游",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"宠物",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"宠物",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"emotion",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"情感",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       @{
                           @"category":@"news_home",
                           @"web_url":@"",
                           @"flags":@(0),
                           @"name":@"家居",
                           @"tip_new":@(0),
                           @"default_add":@(1),
                           @"concern_id":@"",
                           @"type":@(4),
                           @"icon_url":@""
                           },
                       ];
    return array ;
} 

#endif /* KKCommonVariable_h */
