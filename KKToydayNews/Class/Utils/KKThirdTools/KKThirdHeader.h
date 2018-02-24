//
//  KKThirdHeader.h
//  KKTodayNews
//
//  Created by finger on 2018/2/14.
//  Copyright © 2018年 finger. All rights reserved.
//

#ifndef KKThirdHeader_h
#define KKThirdHeader_h

typedef NS_ENUM(NSInteger, KKThirdPlatform){
    KKThirdPlatformWX,//微信
    KKThirdPlatformQQ,//QQ
    KKThirdPlatformWeiBo,//微博
    KKThirdPlatformAliPay,//支付宝
    KKThirdPlatformApplePay,//苹果支付
};

//错误类型
typedef NS_ENUM(NSInteger, KKErrorCode){
    KKSuccess = 0,//成功
    KKErrorCodeCommon = -1,//普通错误类型
    KKErrorCodeUserCancel = -2,//用户点击取消并返回
    KKErrorCodeFail = -3,//失败
    KKErrorCodeAuthDeny = -4,//授权失败
    KKErrorCodeUnsupport = -5//不支持
};

//分享类型
typedef NS_ENUM(NSInteger, KKShareContentType){
    KKShareContentTypeText,//纯文本
    KKShareContentTypeImage,//图片
    KKShareContentTypeMusic,//音乐
    KKShareContentTypeVideo,//视频
    KKShareContentTypeWebLink,//链接
    KKShareContentTypeMiniProgram//小程序
};

//微信分享场景
typedef NS_ENUM(NSInteger, KKWXSceneType){
    KKWXSceneTypeChat,//聊天界面
    KKWXSceneTypeTimeline,//朋友圈
    KKWXSceneTypeFavorite,//收藏
};

//QQ分享场景
typedef NS_ENUM(NSInteger, KKQQSceneType){
    KKQQSceneTypeFriend,//好友
    KKQQSceneTypeQZone,//QQ空间
};

//分享结果回调
typedef void(^complateCallback)(KKErrorCode resultCode,NSString *resultString);
//授权结果回调
@class KKAuthorizeObject;
typedef void(^authorizeCompleteCallback)(KKErrorCode resultCode,KKAuthorizeObject *authObj);

//微信
#define WXAppID @"这里写你自己申请的微信appid"
#define WXAppSecret @"这里写你自己申请的微信AppSecret"
#define KKWXGetTokenUrl @"https://api.weixin.qq.com/sns/oauth2/access_token"
#define KKWXGetUserInfoUrl @"https://api.weixin.qq.com/sns/userinfo"

//QQ
#define QQAppID @"这里写你自己申请的QQ AppID"
#define QQAppKey @"这里写你自己申请的QQ AppKey"

//微博
#define WBAppID @"这里写你自己申请的微博 AppID"
#define WBAppSecret @"这里写你自己申请的微博 AppSecret"
#define WBRedirectURL @"https://www.sina.com"
#define WBGetTokeninfo @"https://api.weibo.com/oauth2/get_token_info"
#define WBGetUserinfo @"https://api.weibo.com/2/users/show.json"

#endif /* KKThirdHeader_h */
