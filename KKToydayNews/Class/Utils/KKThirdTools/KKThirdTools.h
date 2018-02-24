//
//  KKThirdTools.h
//  KKTodayNews
//
//  Created by finger on 2018/2/14.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKThirdHeader.h"
#import "KKShareObject.h"
#import "KKWXTool.h"
#import "KKQQTool.h"
#import "KKWeiBoTool.h"

@interface KKThirdTools : NSObject

#pragma mark --平台注册，参数为KKThirdPlatform的枚举数组

+ (void)registerPlatform:(NSArray<NSNumber *> *)array;

#pragma mark --第三方平台回调

+ (BOOL)handlerOpenUrl:(NSURL *)url;

#pragma mark -- 微信分享
/**
 微信分享
 @param obj 分享信息
 @param scene 分享场景 好友、朋友圈、收藏
 @param callback 分享回调
 */
+ (void)shareToWXWithObject:(KKShareObject *)obj scene:(KKWXSceneType)scene complete:(complateCallback)callback;

#pragma mark -- QQ分享
/**
 QQ分享
 @param obj 分享信息
 @param scene 分享场景 好友、QQ空间
 @param callback 分享回调
 */
+ (void)shareToQQWithObject:(KKShareObject *)obj scene:(KKQQSceneType)scene complete:(complateCallback)callback;

#pragma mark -- 微博分享
/**
 微博分享
 @param obj 分享信息
 @param callback 分享回调
 */
+ (void)shareToWbWithObject:(KKShareObject *)obj complete:(complateCallback)callback;

#pragma mark -- 第三方授权
/**
 第三方授权
 @param platform 第三方平台
 @param viewCtrl 授权确认视图的父控制器
 @param callback 授权结果
 */
+ (void)authorizeWithPlatform:(KKThirdPlatform)platform inViewCtrl:(UIViewController *)viewCtrl complate:(authorizeCompleteCallback)callback;

#pragma mark -- 第三方支付

+ (void)paymentWithPlatform:(KKThirdPlatform)platform payInfo:(KKWXPayObject *)payInfo complete:(complateCallback)callback;

#pragma mark -- 是否安装了某个平台

+ (BOOL)isInstalled:(KKThirdPlatform)platform;

@end


#pragma mark -- 通用

@interface KKThirdTools(KKTools)

+ (NSString *)urlStringWithUrl:(NSString *)url param:(NSDictionary *)param;

/**
 请求网络数据
 @param urlString 请求url
 @param param 请求参数
 @param method 请求方法 GET POST
 @param complete 结果回调
 */
+ (void)asyncRequestWithUrl:(NSString *)urlString param:(NSDictionary *)param method:(NSString *)method complate:(void(^)(id response))complete;

@end
