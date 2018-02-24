//
//  KKQQTool.h
//  KKTodayNews
//
//  Created by finger on 2018/2/14.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import "KKThirdHeader.h"

@interface KKQQTool : NSObject
+ (KKQQTool *)shareInstance;
+ (BOOL)registerQQApp;
- (BOOL)handlerOpenUrl:(NSURL *)url;
@end







#pragma mark -- //////////////QQ分享////////////////////

@interface KKQQTool(KKShareMsg)

@property(nonatomic,copy)complateCallback shareCallback;

#pragma mark -- 分享文字

- (void)shareText:(NSString *)text
            scene:(KKQQSceneType)scene
         complete:(complateCallback)callback;

#pragma mark -- 分享图片给好友

- (void)shareImageToFriend:(UIImage *)image thumbImage:(UIImage *)thumbImage title:(NSString *)title desc:(NSString *)desc complete:(complateCallback)callback;

#pragma mark -- 分享图片到QQ空间

- (void)shareImageToQZone:(NSArray<UIImage *> *)images title:(NSString *)title complete:(complateCallback)callback;

#pragma mark -- 分享音乐
/**
 分享音乐
 @param title 音乐标题
 @param desc 音乐描述
 @param linkUrl 点击分享跳转的链接
 @param thumbImage 封面
 @param scene 分享场景
 @param callback 分享回调
 */
- (void)shareMusic:(NSString *)title
              desc:(NSString *)desc
           linkUrl:(NSString *)linkUrl
        thumbImage:(UIImage *)thumbImage
             scene:(KKQQSceneType)scene
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
             scene:(KKQQSceneType)scene
          complete:(complateCallback)callback;

#pragma mark -- 分享链接
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
            scene:(KKQQSceneType)scene
         complete:(complateCallback)callback;
@end








#pragma mark -- //////////////QQ授权////////////////

@interface KKQQTool(KKAuthorize)
@property(nonatomic,copy)authorizeCompleteCallback authCallback;//授权结果回调
@property(nonatomic,copy)NSString *openId;
@property(nonatomic,copy)NSString *accessToken;

#pragma mark -- 申请授权

- (BOOL)requireAuthorizeInViewCtrl:(UIViewController *)ctrl complete:(authorizeCompleteCallback)callback;

@end
