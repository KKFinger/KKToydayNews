//
//  KKWeiBoTool.h
//  KKTodayNews
//
//  Created by finger on 2018/2/15.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKThirdHeader.h"
#import "WeiboSDK.h"

@interface KKWeiBoTool : NSObject
+ (KKWeiBoTool *)shareInstance;
+ (BOOL)registerWBApp;
- (BOOL)handlerOpenUrl:(NSURL *)url;
@end







#pragma mark -- /////////////////分享//////////////////

@interface KKWeiBoTool(KKShareMsg)
@property(nonatomic,strong)WBMessageObject *message;
@property(nonatomic,copy)complateCallback shareCallback;

#pragma mark -- 分享文字

- (void)shareText:(NSString *)text complete:(complateCallback)callback;

#pragma mark -- 分享图片

- (void)shareImages:(NSArray<UIImage *> *)images complete:(complateCallback)callback;

#pragma mark -- 分享音乐

- (void)shareMusic:(NSString *)url complete:(complateCallback)callback;

#pragma mark -- 分享视频

- (void)shareVideo:(NSString *)videoUrl complete:(complateCallback)callback;

#pragma mark -- 分享链接
/**
 分享链接
 @param title 标题
 @param desc 描述
 @param linkUrl 点击分享跳转的链接
 @param thumbImage 封面
 @param callback 分享回调
 */
- (void)shareLink:(NSString *)title
             desc:(NSString *)desc
          linkUrl:(NSString *)linkUrl
       thumbImage:(UIImage *)thumbImage
         complete:(complateCallback)callback;
@end








#pragma mark --  //////////////授权//////////////////////

@interface KKWeiBoTool(KKAuthorize)
@property(copy,nonatomic)NSString *wbtoken;
@property(copy,nonatomic)NSString *wbRefreshToken;
@property(copy,nonatomic)NSString *wbCurrentUserID;
@property(nonatomic,copy)authorizeCompleteCallback authCallback;//授权结果回调

#pragma mark -- 申请授权

- (BOOL)requireAuthorizeInViewCtrl:(UIViewController *)ctrl complete:(authorizeCompleteCallback)callback;

@end
