//
//  KKThirdTools.m
//  KKTodayNews
//
//  Created by finger on 2018/2/14.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKThirdTools.h"
#import "KKNetworkTool.h"

@implementation KKThirdTools

#pragma mark -- 平台注册，参数为KKThirdPlatform的枚举数组

+ (void)registerPlatform:(NSArray<NSNumber *> *)array{
    for(NSNumber *number in array){
        KKThirdPlatform platform = [number integerValue];
        if(platform == KKThirdPlatformWX){
            [KKWXTool registerWXApp];
        }else if(platform == KKThirdPlatformQQ){
            [KKQQTool registerQQApp];
        }else if(platform == KKThirdPlatformWeiBo){
            [KKWeiBoTool registerWBApp];
        }
    }
}

#pragma mark -- 第三方平台回调

+ (BOOL)handlerOpenUrl:(NSURL *)url{
    NSLog(@"scheme:%@,host:%@",url.scheme,url.host);
    if([url.scheme isEqualToString:WXAppID]){
        return [[KKWXTool shareInstance]handlerOpenUrl:url];
    }else if([url.scheme isEqualToString:[NSString stringWithFormat:@"tencent%@",QQAppID]]){
        return [[KKQQTool shareInstance]handlerOpenUrl:url];
    }else if([url.scheme isEqualToString:[NSString stringWithFormat:@"wb%@",WBAppID]]){
        return [[KKWeiBoTool shareInstance]handlerOpenUrl:url];
    }
    return NO;
}

#pragma mark -- 微信分享
/**
 微信分享
 @param obj 分享信息
 @param scene 分享场景 好友、朋友圈、收藏
 @param callback 分享回调
 */
+ (void)shareToWXWithObject:(KKShareObject *)obj scene:(KKWXSceneType)scene complete:(complateCallback)callback{
    if(obj.shareType == KKShareContentTypeText){
        [[KKWXTool shareInstance]shareText:obj.shareContent scene:scene complete:callback];
    }else if(obj.shareType == KKShareContentTypeImage){
        [[KKWXTool shareInstance]shareImage:obj.shareImage thumbImage:obj.thumbImage scene:scene complete:callback];
    }else if(obj.shareType == KKShareContentTypeMusic){
        [[KKWXTool shareInstance]shareMusic:obj.title desc:obj.desc linkUrl:obj.linkUrl dataUrl:obj.dataUrl thumbImage:obj.thumbImage scene:scene complete:callback];
    }else if(obj.shareType == KKShareContentTypeVideo){
        [[KKWXTool shareInstance]shareVideo:obj.title desc:obj.desc linkUrl:obj.linkUrl thumbImage:obj.thumbImage scene:scene complete:callback];
    }else if(obj.shareType == KKShareContentTypeWebLink){
        [[KKWXTool shareInstance]shareLink:obj.title desc:obj.desc linkUrl:obj.linkUrl thumbImage:obj.thumbImage scene:scene complete:callback];
    }else{
        if(callback){
            callback(KKErrorCodeUnsupport,@"不支持的分享");
        }
    }
}

#pragma mark -- QQ分享
/**
 QQ分享
 @param obj 分享信息
 @param scene 分享场景 好友、QQ空间
 @param callback 分享回调
 */
+ (void)shareToQQWithObject:(KKShareObject *)obj scene:(KKQQSceneType)scene complete:(complateCallback)callback{
    if(obj.shareType == KKShareContentTypeText){
        [[KKQQTool shareInstance]shareText:obj.shareContent scene:scene complete:callback];
    }else if(obj.shareType == KKShareContentTypeImage){
        if(scene == KKQQSceneTypeFriend){
            [[KKQQTool shareInstance]shareImageToFriend:obj.shareImage thumbImage:obj.thumbImage title:obj.title desc:obj.desc complete:callback];
        }else if(scene == KKQQSceneTypeQZone){
            [[KKQQTool shareInstance]shareImageToQZone:obj.shareImages title:obj.title complete:callback];
        }
    }else if(obj.shareType == KKShareContentTypeMusic){
        [[KKQQTool shareInstance]shareMusic:obj.title desc:obj.desc linkUrl:obj.linkUrl thumbImage:obj.thumbImage scene:scene complete:callback];
    }else if(obj.shareType == KKShareContentTypeVideo){
        [[KKQQTool shareInstance]shareVideo:obj.title desc:obj.desc linkUrl:obj.linkUrl thumbImage:obj.thumbImage scene:scene complete:callback];
    }else if(obj.shareType == KKShareContentTypeWebLink){
        [[KKQQTool shareInstance]shareLink:obj.title desc:obj.desc linkUrl:obj.linkUrl thumbImage:obj.thumbImage scene:scene complete:callback];
    }if(callback){
        callback(KKErrorCodeUnsupport,@"不支持的分享");
    }
}

#pragma mark -- 微博分享
/**
 微博分享
 @param obj 分享信息
 @param callback 分享回调
 */
+ (void)shareToWbWithObject:(KKShareObject *)obj complete:(complateCallback)callback{
    if(obj.shareType == KKShareContentTypeText){
        [[KKWeiBoTool shareInstance]shareText:obj.shareContent complete:callback];
    }else if(obj.shareType == KKShareContentTypeImage){
        [[KKWeiBoTool shareInstance]shareImages:obj.shareImages complete:callback];
    }else if(obj.shareType == KKShareContentTypeMusic){
        [[KKWeiBoTool shareInstance]shareMusic:obj.dataUrl complete:callback];
    }else if(obj.shareType == KKShareContentTypeVideo){
        [[KKWeiBoTool shareInstance]shareVideo:obj.dataUrl complete:callback];
    }else if(obj.shareType == KKShareContentTypeWebLink){
        [[KKWeiBoTool shareInstance]shareLink:obj.title desc:obj.desc linkUrl:obj.linkUrl thumbImage:obj.thumbImage complete:callback];
    }else{
        if(callback){
            callback(KKErrorCodeUnsupport,@"不支持的分享");
        }
    }
}

#pragma mark -- 第三方授权
/**
 第三方授权
 @param platform 第三方平台
 @param viewCtrl 授权确认视图的父控制器
 @param callback 授权结果
 */
+ (void)authorizeWithPlatform:(KKThirdPlatform)platform inViewCtrl:(UIViewController *)viewCtrl complate:(authorizeCompleteCallback)callback{
    if(platform == KKThirdPlatformWX){
        [[KKWXTool shareInstance]requireAuthorizeInViewCtrl:viewCtrl complete:callback];
    }else if(platform == KKThirdPlatformQQ){
        [[KKQQTool shareInstance]requireAuthorizeInViewCtrl:viewCtrl complete:callback];
    }else if(platform == KKThirdPlatformWeiBo){
        [[KKWeiBoTool shareInstance]requireAuthorizeInViewCtrl:viewCtrl complete:callback];
    }else{
        if(callback){
            callback(KKErrorCodeAuthDeny,nil);
        }
    }
}

#pragma mark -- 第三方支付

+ (void)paymentWithPlatform:(KKThirdPlatform)platform payInfo:(KKWXPayObject *)payInfo complete:(complateCallback)callback{
    if(platform == KKThirdPlatformWX){
        [[KKWXTool shareInstance]payWithObject:payInfo complete:callback];
    }else{
        if(callback){
            callback(KKErrorCodeUnsupport,@"暂不支持");
        }
    }
}

#pragma mark -- 是否安装了某个平台

+ (BOOL)isInstalled:(KKThirdPlatform)platform{
    if(platform == KKThirdPlatformWX){
        return [WXApi isWXAppInstalled];
    }else if(platform == KKThirdPlatformQQ){
        return [QQApiInterface isQQInstalled];
    }else if(platform == KKThirdPlatformWeiBo){
        return [WeiboSDK isWeiboAppInstalled];
    }
    return NO ;
}

@end



#pragma mark -- 通用


@implementation KKThirdTools(KKTools)

+ (NSString *)urlStringWithUrl:(NSString *)url param:(NSDictionary *)param{
    NSMutableArray *parts = [NSMutableArray array];
    [param enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                          [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
                          ];
        [parts addObject:part];
    }];
    NSString *paramString = [parts componentsJoinedByString:@"&"];
    if(!paramString.length){
        return url;
    }
    
    if(!url.length){
        url = @"";
    }
    return [NSString stringWithFormat:@"%@?%@",url,paramString];
}

+ (void)asyncRequestWithUrl:(NSString *)urlString param:(NSDictionary *)param method:(NSString *)method complate:(void(^)(id response))complete{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    NSString *url = [KKThirdTools urlStringWithUrl:urlString param:param];
    if(!url){
        url = @"";
    }
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"GET";
    if([[method lowercaseString]isEqualToString:@"post"]){
        request.HTTPMethod = @"POST";
    }
    
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseObject = nil ;
        if (error == nil) {
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        }
        if (complete) {
            complete(responseObject);
        }
    }];
    [task resume];
    [session finishTasksAndInvalidate];
}

@end
