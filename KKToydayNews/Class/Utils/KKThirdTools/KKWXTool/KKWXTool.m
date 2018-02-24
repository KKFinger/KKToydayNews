//
//  KKWXTool.m
//  KKToydayNews
//
//  Created by finger on 2018/2/13.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKWXTool.h"
#import "KKThirdTools.h"
#import "KKAuthorizeObject.h"
#import <objc/runtime.h>

@implementation KKWXTool

+ (KKWXTool *)shareInstance{
    static KKWXTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KKWXTool alloc]init];
    });
    return instance;
}

+ (BOOL)registerWXApp{
    //向微信注册支持的文件类型
    UInt64 typeFlag = MMAPP_SUPPORT_TEXT | MMAPP_SUPPORT_PICTURE | MMAPP_SUPPORT_LOCATION | MMAPP_SUPPORT_VIDEO |MMAPP_SUPPORT_AUDIO | MMAPP_SUPPORT_WEBPAGE | MMAPP_SUPPORT_DOC | MMAPP_SUPPORT_DOCX | MMAPP_SUPPORT_PPT | MMAPP_SUPPORT_PPTX | MMAPP_SUPPORT_XLS | MMAPP_SUPPORT_XLSX | MMAPP_SUPPORT_PDF;
    [WXApi registerAppSupportContentFlag:typeFlag];
    
    return [WXApi registerApp:WXAppID enableMTA:NO];
}

- (BOOL)handlerOpenUrl:(NSURL *)url{
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark -- WXApiDelegate

/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void)onReq:(BaseReq*)req{
    NSLog(@"-(void) onReq:(BaseReq*)req");
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp 具体的回应内容，是自动释放的
 */
-(void)onResp:(BaseResp*)resp{
    KKErrorCode rstCode = resp.errCode;
    NSString *errString = resp.errStr;
    if([resp isKindOfClass:[SendMessageToWXResp class]]){
        dispatch_async(dispatch_get_main_queue(), ^{
            if(rstCode == KKErrorCodeUserCancel){
                if(self.shareCallback){
                    self.shareCallback(rstCode,@"分享取消");
                }
            }else if(rstCode == KKSuccess){
                if(self.shareCallback){
                    self.shareCallback(rstCode,@"分享成功");
                }
            }else{
                if(self.shareCallback){
                    self.shareCallback(rstCode,errString);
                }
            }
        });
    }else if([resp isKindOfClass:[SendAuthResp class]]) {
        [self processAuthResp:(SendAuthResp *)resp];//授权响应
    }else if([resp isKindOfClass:[PayResp class]]){
        switch (resp.errCode) {
            case KKSuccess:{
                if(self.payCallback){
                    self.payCallback(KKSuccess, @"支付成功");
                }
            }
                break;
            case KKErrorCodeUserCancel:{
                if(self.payCallback){
                    self.payCallback(KKErrorCodeUserCancel, @"支付取消");
                }
            }
                break;
            default:{
                if(self.payCallback){
                    self.payCallback(KKErrorCodeFail,errString);
                }
            }
                break;
        }
    }
}

@end









#pragma mark -- /////////////// 微信分享 //////////////////

@implementation KKWXTool(KKShareMsg)

#pragma mark -- 分享文字

- (void)shareText:(NSString *)text
            scene:(KKWXSceneType)scene
         complete:(complateCallback)callback{
    self.shareCallback = callback;
    if(!text.length){
        if(self.shareCallback){
            self.shareCallback(KKErrorCodeFail,@"分享内容为空");
        }
        return ;
    }
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.text = text;
    req.bText = YES ;
    req.scene = scene;
    [WXApi sendReq:req];
}

#pragma mark -- 分享图片

- (void)shareImage:(UIImage *)image
        thumbImage:(UIImage *)thumbImage
             scene:(KKWXSceneType)scene
          complete:(complateCallback)callback{
    self.shareCallback = callback;
    if(!image){
        if(self.shareCallback){
            self.shareCallback(KKErrorCodeFail,@"分享图片为空");
        }
        return ;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    
    WXImageObject *imgObj = [WXImageObject object];
    imgObj.imageData = UIImagePNGRepresentation(image);
    
    [message setThumbImage:thumbImage];
    [message setMediaObject:imgObj];
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc]init];
    req.bText = NO ;
    req.message = message;
    req.scene = scene;
    [WXApi sendReq:req];
}

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
          complete:(complateCallback)callback{
    self.shareCallback = callback;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    [message setThumbImage:thumbImage];
    
    WXMusicObject *ext = [WXMusicObject object];
    //点击分享跳转的url
    ext.musicUrl = linkUrl;
    ext.musicLowBandDataUrl = ext.musicUrl;
    //播放音乐数据的url
    ext.musicDataUrl = dataUrl;
    ext.musicLowBandDataUrl = ext.musicDataUrl;
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

#pragma mark -- 分享视频
/**
 分享视频
 @param title 标题
 @param desc 描述
 @param linkUrl 点击分享跳转的链接
 @param thumbImage 缩略图
 @param scene 分享场景
 @param callback 分享回调
 */
- (void)shareVideo:(NSString *)title
              desc:(NSString *)desc
           linkUrl:(NSString *)linkUrl
        thumbImage:(UIImage *)thumbImage
             scene:(KKWXSceneType)scene
          complete:(complateCallback)callback{
    self.shareCallback = callback;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    [message setThumbImage:thumbImage];
    
    WXVideoObject *ext = [WXVideoObject object];
    ext.videoUrl = linkUrl;
    ext.videoLowBandUrl = ext.videoUrl;
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

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
         complete:(complateCallback)callback{
    self.shareCallback = callback;
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = desc;
    [message setThumbImage:thumbImage];
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = linkUrl;
    message.mediaObject = webpageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = scene;
    
    [WXApi sendReq:req];
}

#pragma mark -- @property

static char shareCallbackKey;
- (void)setShareCallback:(complateCallback)shareCallback{
    objc_setAssociatedObject(self, &shareCallbackKey, shareCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (complateCallback)shareCallback{
    return objc_getAssociatedObject(self, &shareCallbackKey);
}

@end









#pragma mark -- ///////////////微信授权/////////////////

@implementation KKWXTool(KKAuthorize)

#pragma mark -- 申请授权

- (BOOL)requireAuthorizeInViewCtrl:(UIViewController *)ctrl complete:(authorizeCompleteCallback)callback{
    self.authCallback = callback;
    
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";//授权范围
    req.state = @"xxx";//状态，可设置任意内容
    
    return [WXApi sendAuthReq:req
               viewController:ctrl
                     delegate:self];
}

#pragma mark -- 授权响应处理

- (void)processAuthResp:(SendAuthResp *)resp{
    if (resp.errCode == KKErrorCodeUserCancel) {
        if(self.authCallback){
            self.authCallback(KKErrorCodeUserCancel, nil);
        }
        return;
    }
    if (resp.errCode == KKErrorCodeUnsupport){
        if(self.authCallback){
            self.authCallback(KKErrorCodeUnsupport, nil);
        }
        return;
    }
    if (resp.errCode == KKErrorCodeAuthDeny){
        if(self.authCallback){
            self.authCallback(KKErrorCodeAuthDeny, nil);
        }
        return;
    }
    NSString *respCode = resp.code;
    if(!respCode){
        if(self.authCallback){
            self.authCallback(KKErrorCodeAuthDeny, nil);
        }
        return ;
    }
    NSDictionary *params = @{@"appid":WXAppID,
                                @"secret":WXAppSecret,
                                @"code":respCode,
                                @"grant_type":@"authorization_code"};
    
    __weak typeof(self)wSelf = self;
    [KKThirdTools asyncRequestWithUrl:KKWXGetTokenUrl param:params method:@"GET" complate:^(id responseObject) {
        __strong typeof(wSelf)sSelf = wSelf;
        if(responseObject){
            sSelf.openId = responseObject[@"openid"];
            sSelf.accessToken = responseObject[@"access_token"];
            if(sSelf.openId && sSelf.accessToken){
                __weak typeof(sSelf)wsSelf = sSelf;
                [sSelf fetchUserInfoWithToken:sSelf.accessToken openId:sSelf.openId complete:^(KKAuthorizeObject *obj) {
                    __strong typeof(wsSelf)ssSelf = wsSelf;
                    if(obj){
                        if(ssSelf.authCallback){
                            ssSelf.authCallback(KKSuccess, obj);
                        }
                    }else{
                        if(ssSelf.authCallback){
                            ssSelf.authCallback(KKErrorCodeAuthDeny, nil);
                        }
                    }
                }];
            }
        }else{
            if(sSelf.authCallback){
                sSelf.authCallback(KKErrorCodeCommon, nil);
            }
        }
    }];
}

#pragma mark -- 获取用户信息

- (void)fetchUserInfoWithToken:(NSString *)token openId:(NSString *)openId complete:(void(^)(KKAuthorizeObject *obj))complete{
    NSDictionary *param  = @{@"access_token":token,@"openid":openId};
    [KKThirdTools asyncRequestWithUrl:KKWXGetUserInfoUrl param:param method:@"GET" complate:^(id response) {
        if(response){
            KKAuthorizeObject *obj = [KKAuthorizeObject new];
            obj.nickName = response[@"nickname"];
            obj.gender = [NSString stringWithFormat:@"%ld",[response[@"sex"]integerValue]];
            obj.userId = response[@"unionid"];
            obj.headImgUrl = response[@"headimgurl"];
            if(complete){
                complete(obj);
            }
        }else{
            if(complete){
                complete(nil);
            }
        }
    }];
}

#pragma mark -- @property

static char openIdKey;
- (void)setOpenId:(NSString *)openId{
    objc_setAssociatedObject(self, &openIdKey, openId, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)openId{
    return objc_getAssociatedObject(self, &openIdKey);
}

static char accessTokenKey;
- (void)setAccessToken:(NSString *)accessToken{
    objc_setAssociatedObject(self, &accessTokenKey, accessToken, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)accessToken{
    return objc_getAssociatedObject(self, &accessTokenKey);
}

static char authCallbackKey;
- (void)setAuthCallback:(authorizeCompleteCallback)authCallback{
    objc_setAssociatedObject(self, &authCallbackKey, authCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (authorizeCompleteCallback)authCallback{
    return objc_getAssociatedObject(self, &authCallbackKey);
}

@end






#pragma mark -- //////////////微信支付////////////////

@implementation KKWXTool(KKWXPay)

- (void)payWithObject:(KKWXPayObject *)obj complete:(complateCallback)callback{
    if(!obj){
        if(callback){
            callback(KKErrorCodeFail,@"支付失败");
        }
        return;
    }
    
    self.payCallback = callback;
    
    PayReq *req = [[PayReq alloc] init];
    req.partnerId = obj.partnerId;
    req.prepayId = obj.prepayId;
    req.nonceStr = obj.nonceStr;
    req.timeStamp = (UInt32)obj.timeStamp;
    req.package = obj.package;
    req.sign = obj.sign;
    [WXApi sendReq:req];
}

static char payCallbackKey;
- (void)setPayCallback:(complateCallback)payCallback{
    objc_setAssociatedObject(self, &payCallbackKey, payCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (complateCallback)payCallback{
    return objc_getAssociatedObject(self, &payCallbackKey);
}

@end
