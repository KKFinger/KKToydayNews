//
//  KKWeiBoTool.m
//  KKTodayNews
//
//  Created by finger on 2018/2/15.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKWeiBoTool.h"
#import "KKAuthorizeObject.h"

@interface KKWeiBoTool()<WeiboSDKDelegate,WBMediaTransferProtocol,WBHttpRequestDelegate>
@property(nonatomic,strong)WBHttpRequest *wbHttpRequest;
@end

@implementation KKWeiBoTool

+ (KKWeiBoTool *)shareInstance{
    static KKWeiBoTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KKWeiBoTool alloc]init];
    });
    return instance;
}

+ (BOOL)registerWBApp{
    return [WeiboSDK registerApp:WBAppID];
}

- (BOOL)handlerOpenUrl:(NSURL *)url{
    return [WeiboSDK handleOpenURL:url delegate:self];
}

#pragma mark -- WeiboSDKDelegate

/**
 收到一个来自微博客户端程序的请求
 
 收到微博的请求后，第三方应用应该按照请求类型进行处理，处理完后必须通过 [WeiboSDK sendResponse:] 将结果回传给微博
 @param request 具体的请求对象
 */
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
}

/**
 收到一个来自微博客户端程序的响应
 
 收到微博的响应后，第三方应用可以通过响应类型、响应的数据和 WBBaseResponse.userInfo 中的数据完成自己的功能
 @param response 具体的响应对象
 */
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]){
        WBSendMessageToWeiboResponse *sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString *accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken){
            self.wbtoken = accessToken;
        }
        NSString *userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
        switch (response.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess:{
                if(self.shareCallback){
                    self.shareCallback(KKSuccess, @"分享成功");
                }
            }
                break;
            case WeiboSDKResponseStatusCodeUserCancel:{
                if(self.shareCallback){
                    self.shareCallback(KKErrorCodeUserCancel, @"用户取消发送");
                }
            }
                break;
            case WeiboSDKResponseStatusCodeUnsupport:{
                if(self.shareCallback){
                    self.shareCallback(KKErrorCodeUnsupport, @"不支持的请求");
                }
            }
                break;
            case WeiboSDKResponseStatusCodeSentFail:{
                if(self.shareCallback){
                    self.shareCallback(KKErrorCodeFail, @"发送失败");
                }
            }
                break;
            case WeiboSDKResponseStatusCodeAuthDeny:{
                if(self.shareCallback){
                    self.shareCallback(KKErrorCodeAuthDeny, @"授权失败");
                }
            }
                break;
            case WeiboSDKResponseStatusCodeShareInSDKFailed:{
                if(self.shareCallback){
                    self.shareCallback(KKErrorCodeFail, @"发送失败");
                }
            }
                break;
            default:{
                if(self.shareCallback){
                    self.shareCallback(KKErrorCodeFail, @"发送失败");
                }
            }
                break;
        }
    }else if ([response isKindOfClass:WBAuthorizeResponse.class]){
        switch (response.statusCode) {
            case WeiboSDKResponseStatusCodeSuccess:{
                WBAuthorizeResponse *authResp = (WBAuthorizeResponse *)response;
                if(!authResp){
                    if(self.authCallback){
                        self.authCallback(KKErrorCodeAuthDeny, nil);
                    }
                    return;
                }
                
                self.wbtoken = [authResp accessToken];
                self.wbCurrentUserID = [authResp userID];
                self.wbRefreshToken = [authResp refreshToken];
                
                [self fetchUserInfo];
            }
                break;
            case WeiboSDKResponseStatusCodeUserCancel:{
                if(self.authCallback){
                    self.authCallback(KKErrorCodeUserCancel, nil);
                }
            }
                break;
            case WeiboSDKResponseStatusCodeUnsupport:{
                if(self.authCallback){
                    self.authCallback(KKErrorCodeUnsupport, nil);
                }
            }
                break;
            case WeiboSDKResponseStatusCodeSentFail:
            case WeiboSDKResponseStatusCodeAuthDeny:
            case WeiboSDKResponseStatusCodeShareInSDKFailed:{
                if(self.authCallback){
                    self.authCallback(KKErrorCodeAuthDeny, nil);
                }
            }
                break;
            default:{
                if(self.authCallback){
                    self.authCallback(KKErrorCodeAuthDeny, nil);
                }
            }
                break;
        }
    }
}

#pragma mark -- WBMediaTransferProtocol,音乐、图片、视频分享回调

/**
 数据准备成功回调
 */
-(void)wbsdk_TransferDidReceiveObject:(id)object{
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = WBRedirectURL;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:self.message authInfo:authRequest access_token:self.wbtoken];
    if (![WeiboSDK sendRequest:request]) {
        if(self.shareCallback){
            self.shareCallback(KKErrorCodeFail, @"分享失败");
        }
    }
}

/**
 数据准备失败回调
 */
-(void)wbsdk_TransferDidFailWithErrorCode:(WBSDKMediaTransferErrorCode)errorCode andError:(NSError*)error{
    if(self.shareCallback){
        self.shareCallback(KKErrorCodeFail, @"分享失败");
    }
}

#pragma mark -- 获取用户信息

- (void)fetchUserInfo{
    if(!self.wbtoken.length || !self.wbCurrentUserID.length){
        if(self.authCallback){
            self.authCallback(KKErrorCodeAuthDeny, nil);
        }
        return;
    }
    NSArray *value=[NSArray arrayWithObjects:self.wbtoken,self.wbCurrentUserID,nil];
    NSArray *key=[NSArray arrayWithObjects:@"access_token",@"uid", nil];
    NSDictionary *parameters=[[NSDictionary alloc]initWithObjects:value forKeys:key];
    self.wbHttpRequest = [WBHttpRequest requestWithURL:WBGetUserinfo httpMethod:@"GET" params:parameters delegate:self withTag:@"getUserInfo"];
}

#pragma mark -- WBHttpRequestDelegate

-  (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result{
    if([request.tag isEqualToString:@"getUserInfo"]){
        NSData *data = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if(!info){
            if(self.authCallback){
                self.authCallback(KKErrorCodeAuthDeny, nil);
            }
            return;
        }
        KKAuthorizeObject *obj = [KKAuthorizeObject new];
        obj.nickName = info[@"screen_name"];
        obj.headImgUrl = info[@"avatar_large"];
        obj.gender = [info[@"gender"]isEqualToString:@"m"]?@"1":@"0";
        obj.userId = info[@"idstr"];
        if(self.authCallback){
            self.authCallback(KKSuccess, obj);
        }
    }
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error{
    if([request.tag isEqualToString:@"getUserInfo"]){
        if(self.authCallback){
            self.authCallback(KKErrorCodeAuthDeny, nil);
        }
    }
}

@end







#pragma mark -- //////////////////////分享//////////////////

@implementation KKWeiBoTool(KKShareMsg)

#pragma mark -- 分享文字

- (void)shareText:(NSString *)text complete:(complateCallback)callback{
    if(!text.length){
        if(callback){
            callback(KKErrorCodeFail, @"分享内容不能为空");
        }
    }
    self.shareCallback = callback;
    self.message = [WBMessageObject message];
    self.message.text = text;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = WBRedirectURL;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:self.message authInfo:authRequest access_token:self.wbtoken];
    if (![WeiboSDK sendRequest:request]) {
        if(self.shareCallback){
            self.shareCallback(KKErrorCodeFail, @"分享失败");
        }
    }
}

#pragma mark -- 分享图片

- (void)shareImages:(NSArray<UIImage *> *)images complete:(complateCallback)callback{
    self.shareCallback = callback;
    self.message = [WBMessageObject message];
    
    WBImageObject *imageObject = [WBImageObject object];
    imageObject.delegate = self;
    [imageObject addImages:images];
    self.message.imageObject = imageObject;
}

#pragma mark -- 分享音乐

- (void)shareMusic:(NSString *)url complete:(complateCallback)callback{
    if(callback){
        callback(KKErrorCodeUnsupport,@"暂不支持分享音乐");
    }
}

#pragma mark -- 分享视频

- (void)shareVideo:(NSString *)videoUrl complete:(complateCallback)callback{
    if(!videoUrl.length){
        if(callback){
            callback(KKErrorCodeFail, @"分享链接不能为空");
        }
        return;
    }
    self.shareCallback = callback;
    self.message = [WBMessageObject message];
    
    WBNewVideoObject *videoObject = [WBNewVideoObject object];
    NSURL *url = [NSURL URLWithString:videoUrl];
    videoObject.delegate = self;
    [videoObject addVideo:url];
    self.message.videoObject = videoObject;
}

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
         complete:(complateCallback)callback{
    if(!linkUrl.length){
        if(callback){
            callback(KKErrorCodeFail, @"分享链接不能为空");
        }
        return;
    }
    self.shareCallback = callback;
    self.message = [WBMessageObject message];
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"identifier1";
    webpage.title = title;
    webpage.description = desc;
    webpage.thumbnailData = UIImagePNGRepresentation(thumbImage);
    webpage.webpageUrl = linkUrl;
    self.message.mediaObject = webpage;
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = WBRedirectURL;
    authRequest.scope = @"all";
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:self.message authInfo:authRequest access_token:self.wbtoken];
    if (![WeiboSDK sendRequest:request]) {
        if(self.shareCallback){
            self.shareCallback(KKErrorCodeFail, @"分享失败");
        }
    }
}

#pragma mark -- @property

static char shareCallbackKey;
- (void)setShareCallback:(complateCallback)shareCallback{
    objc_setAssociatedObject(self, &shareCallbackKey, shareCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (complateCallback)shareCallback{
    return objc_getAssociatedObject(self, &shareCallbackKey);
}

static char messageKey;
- (void)setMessage:(WBMessageObject *)message{
    objc_setAssociatedObject(self, &messageKey, message, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WBMessageObject *)message{
    return objc_getAssociatedObject(self, &messageKey);
}

@end









#pragma mark -- ///////////////授权/////////////////

@implementation KKWeiBoTool(KKAuthorize)

#pragma mark -- 申请授权

- (BOOL)requireAuthorizeInViewCtrl:(UIViewController *)ctrl complete:(authorizeCompleteCallback)callback{
    self.authCallback = callback;
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = WBRedirectURL;
    request.scope = @"all";
    
    return [WeiboSDK sendRequest:request];
}

#pragma mark -- @property

static char wbtokenKey;
- (void)setWbtoken:(NSString *)wbtoken{
    objc_setAssociatedObject(self, &wbtokenKey, wbtoken, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)wbtoken{
    return objc_getAssociatedObject(self, &wbtokenKey);
}

static char wbRefreshTokenKey;
- (void)setWbRefreshToken:(NSString *)wbRefreshToken{
    objc_setAssociatedObject(self, &wbRefreshTokenKey, wbRefreshToken, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)wbRefreshToken{
    return objc_getAssociatedObject(self, &wbRefreshTokenKey);
}

static char wbCurrentUserIDKey;
- (void)setWbCurrentUserID:(NSString *)wbCurrentUserID{
    objc_setAssociatedObject(self, &wbCurrentUserIDKey, wbCurrentUserID, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)wbCurrentUserID{
    return objc_getAssociatedObject(self, &wbCurrentUserIDKey);
}

static char authCallbackKey;
- (void)setAuthCallback:(authorizeCompleteCallback)authCallback{
    objc_setAssociatedObject(self, &authCallbackKey, authCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (authorizeCompleteCallback)authCallback{
    return objc_getAssociatedObject(self, &authCallbackKey);
}

@end
