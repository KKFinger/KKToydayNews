//
//  KKWXTool.h
//  KKToydayNews
//
//  Created by finger on 2018/2/13.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "KKThirdHeader.h"
#import "KKWXPayObject.h"

@interface KKWXTool : NSObject<WXApiDelegate>
+ (KKWXTool *)shareInstance;
+ (BOOL)registerWXApp;
- (BOOL)handlerOpenUrl:(NSURL *)url;
@end







#pragma mark -- ////////////微信分享/////////////

@interface KKWXTool(KKShareMsg)

@property(nonatomic,copy)complateCallback shareCallback;//分享结果回调

#pragma mark -- 分享文字

- (void)shareText:(NSString *)text
            scene:(KKWXSceneType)scene
         complete:(complateCallback)callback;

#pragma mark -- 分享图片

- (void)shareImage:(UIImage *)image
        thumbImage:(UIImage *)thumbImage
             scene:(KKWXSceneType)scene
          complete:(complateCallback)callback;

#pragma mark -- 分享音乐
/**
 分享音乐
 @param title 音乐标题
 @param desc 音乐描述
 @param linkUrl 点击分享跳转的链接
 @param dataUrl 播放音乐的链接
 @param thumbImage 封面
 @param scene 分享场景
 @param callback 分享回调
 */
- (void)shareMusic:(NSString *)title
              desc:(NSString *)desc
           linkUrl:(NSString *)linkUrl
           dataUrl:(NSString *)dataUrl
        thumbImage:(UIImage *)thumbImage
             scene:(KKWXSceneType)scene
          complete:(complateCallback)callback;

#pragma mark -- 分享视频
/**
 分享视频
 @param title 标题
 @param desc 描述
 @param linkUrl 点击分享跳转的链接
 @param thumbImage 封面
 @param scene 分享场景
 @param callback 分享回调
 */
- (void)shareVideo:(NSString *)title
              desc:(NSString *)desc
           linkUrl:(NSString *)linkUrl
        thumbImage:(UIImage *)thumbImage
             scene:(KKWXSceneType)scene
          complete:(complateCallback)callback;

#pragma mark -- 分享连接
/**
 分享链接
 @param title 标题
 @param desc 描述
 @param linkUrl 点击分享跳转的链接
 @param thumbImage 封面
 @param scene 分享场景
 @param callback 分享回调
 */
- (void)shareLink:(NSString *)title
             desc:(NSString *)desc
          linkUrl:(NSString *)linkUrl
       thumbImage:(UIImage *)thumbImage
            scene:(KKWXSceneType)scene
         complete:(complateCallback)callback;
@end











#pragma mark -- //////////////微信授权////////////////
/*
 *第一步:向微信发送授权请求SendAuthReq，微信会返回SendAuthResp响应
 *第二步:根据SendAuthResp中的code，加上appid、appSecret等参数，向https://api.weixin.qq.com/sns/oauth2/access_token获取openid、access_token等字段
 *第三步:根据openid、access_token，向@"https://api.weixin.qq.com/sns/userinfo"获取用户的基本信息
 */

/*
 *登录的一般流程:
 *1、手机登录，填写手机获取验证码，验证通过之后使用手机号码作为用户id或者新分配一个与手机号码关联的用户id，用户的信息通过该id管理
 *2、第三方登录，第三方授权之后，为分配一个第三方用户的唯一标识，使用该唯一标识作为用户的id或者分配一个与该标识相关联的id用户的信息通过该id管理
 */

@interface KKWXTool(KKAuthorize)
@property(nonatomic,copy)authorizeCompleteCallback authCallback;//授权结果回调
@property(nonatomic,copy)NSString *openId;
@property(nonatomic,copy)NSString *accessToken;

#pragma mark -- 申请授权

- (BOOL)requireAuthorizeInViewCtrl:(UIViewController *)ctrl complete:(authorizeCompleteCallback)callback;

#pragma mark -- 授权响应处理

- (void)processAuthResp:(SendAuthResp *)resp;

@end







#pragma mark -- //////////////微信支付////////////////

@interface KKWXTool(KKWXPay)
@property(nonatomic,copy)complateCallback payCallback;//支付结果回调
- (void)payWithObject:(KKWXPayObject *)obj complete:(complateCallback)callback;
@end
