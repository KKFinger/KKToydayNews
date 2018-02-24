//
//  KKQQTool.m
//  KKTodayNews
//
//  Created by finger on 2018/2/14.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKQQTool.h"
#import "KKAuthorizeObject.h"

@interface KKQQTool()<QQApiInterfaceDelegate,TencentSessionDelegate>
@property(nonatomic,strong)TencentOAuth *tencentOAuth;//必须要先注册，否则分享和登录都会失败
@end

@implementation KKQQTool

+ (KKQQTool *)shareInstance{
    static KKQQTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[KKQQTool alloc]init];
    });
    return instance;
}

+ (BOOL)registerQQApp{
    return YES ;
}

- (instancetype)init{
    self = [super init];
    if(self){
        BOOL flag = self.tencentOAuth != nil;
        if(!flag){
            NSLog(@"QQ初始化授权失败");
        }
    }
    return self ;
}

- (BOOL)handlerOpenUrl:(NSURL *)url{
    return [QQApiInterface handleOpenURL:url delegate:self] || [TencentOAuth HandleOpenURL:url];
}

#pragma mark -- QQApiInterfaceDelegate

/**
 处理来至QQ的请求
 */
- (void)onReq:(QQBaseReq *)req{
    
}

/**
 处理来至QQ的响应
 */
- (void)onResp:(QQBaseResp *)resp{
    switch (resp.type){
        case ESENDMESSAGETOQQRESPTYPE:{
            SendMessageToQQResp* sendResp = (SendMessageToQQResp*)resp;
            if([sendResp.result isEqualToString:@"-4"]){
                if(self.shareCallback){
                    self.shareCallback(KKErrorCodeUserCancel, @"分享取消");
                }
            }else if([sendResp.result isEqualToString:@"0"]){
                if(self.shareCallback){
                    self.shareCallback(KKSuccess, @"分享成功");
                }
            }else{
                if(self.shareCallback){
                    self.shareCallback(KKErrorCodeFail, @"分享失败");
                }
            }
            break;
        }
        default:{
            break;
        }
    }
}

/**
 处理QQ在线状态的回调
 */
- (void)isOnlineResponse:(NSDictionary *)response{
    
}

#pragma mark -- TencentSessionDelegate,授权相关
/**
 第三方网站可存储access token信息，以便后续调用OpenAPI访问和修改用户信息时使用。
 如果需要保存授权信息，需要保存登录完成后返回的accessToken，openid 和 expirationDate三个数据，
 下次登录的时候直接将这三个数据是设置到TencentOAuth对象中即可。
 获得：
 [_tencentOAuth accessToken] ;
 [_tencentOAuth openId] ;
 [_tencentOAuth expirationDate] ;
 设置：
 [_tencentOAuth setAccessToken:accessToken] ;
 [_tencentOAuth setOpenId:openId] ;
 [_tencentOAuth setExpirationDate:expirationDate] ;
 */

/**
 * 登录成功后的回调
 */
- (void)tencentDidLogin {
    if (self.tencentOAuth.accessToken && 0 != [self.tencentOAuth.accessToken length]){
        //记录登录用户的OpenID、Token
        self.accessToken = self.tencentOAuth.accessToken;
        self.openId = [self.tencentOAuth openId];

        //YES表示API调用成功，NO表示API调用失败
        BOOL isGetUserinfo = [self.tencentOAuth getUserInfo];
        if (!isGetUserinfo) {
            if(self.authCallback){
                self.authCallback(KKErrorCodeAuthDeny, nil);
            }
        }
    }else{
        if(self.authCallback){
            self.authCallback(KKErrorCodeAuthDeny, nil);
        }
    }
}

/* 登录失败后的回调
* \param cancelled 代表用户是否主动退出登录
*/
-(void)tencentDidNotLogin:(BOOL)cancelled{
    if(cancelled){
        if(self.authCallback){
            self.authCallback(KKErrorCodeUserCancel, nil);
        }
    }else{
        if(self.authCallback){
            self.authCallback(KKErrorCodeAuthDeny, nil);
        }
    }
}

/**
 * 登录时网络有问题的回调
 */
-(void)tencentDidNotNetWork{
    if(self.authCallback){
        self.authCallback(KKErrorCodeCommon, nil);
    }
}

/**
 * 获取用户个人信息回调
 * \param response API返回结果，具体定义参见sdkdef.h文件中\ref APIResponse
 * \remarks 正确返回示例: \snippet example/getUserInfoResponse.exp success
 *          错误返回示例: \snippet example/getUserInfoResponse.exp fail
 */
- (void)getUserInfoResponse:(APIResponse*)response{
    if (URLREQUEST_SUCCEED == response.retCode
        && kOpenSDKErrorSuccess == response.detailRetCode){
        NSDictionary *userInfo = response.jsonResponse;
        if(!userInfo){
            if(self.authCallback){
                self.authCallback(KKErrorCodeAuthDeny, nil);
            }
            return ;
        }
        KKAuthorizeObject *obj = [KKAuthorizeObject new];
        obj.nickName = userInfo[@"nickname"];
        obj.gender = [userInfo[@"gender"]isEqualToString:@"男"]?@"1":@"0";
        obj.headImgUrl = userInfo[@"figureurl_qq_2"];//100X100
        obj.userId = self.openId;
        if(self.authCallback){
            self.authCallback(KKSuccess, obj);
        }
    }else{
        if(self.authCallback){
            self.authCallback(KKErrorCodeAuthDeny, nil);
        }
    }
}

#pragma mark -- @property

- (TencentOAuth *)tencentOAuth{
    if(!_tencentOAuth){
        _tencentOAuth = [[TencentOAuth alloc]initWithAppId:QQAppID andDelegate:self];
    }
    return _tencentOAuth;
}

@end









#pragma mark -- //////////////////// QQ分享 ///////////////////

@implementation KKQQTool(KKShareMsg)

#pragma mark -- 分享文本

- (void)shareText:(NSString *)text scene:(KKQQSceneType)scene complete:(complateCallback)callback{
    self.shareCallback = callback;
    if(scene == KKQQSceneTypeFriend){
        QQApiTextObject *txtObj = [QQApiTextObject objectWithText:text];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
    }else if(scene == KKQQSceneTypeQZone){
        QQApiImageArrayForQZoneObject *obj = [QQApiImageArrayForQZoneObject objectWithimageDataArray:nil title:text];
        SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:obj];
        QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
        [self handleSendResult:sent];
    }
}

#pragma mark -- 分享图片给好友

- (void)shareImageToFriend:(UIImage *)image thumbImage:(UIImage *)thumbImage title:(NSString *)title desc:(NSString *)desc complete:(complateCallback)callback{
    self.shareCallback = callback;
    NSData *imageData = UIImagePNGRepresentation(image);
    NSData *thumbData = UIImagePNGRepresentation(thumbImage);
    QQApiImageObject *img = [QQApiImageObject objectWithData:imageData previewImageData:thumbData title:title description:desc];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:img];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

#pragma mark -- 分享图片到QQ空间

- (void)shareImageToQZone:(NSArray<UIImage *> *)images title:(NSString *)title complete:(complateCallback)callback{
    self.shareCallback = callback;
    
    NSMutableArray *array = [NSMutableArray new];
    for(UIImage *image in images){
        NSData *data = UIImagePNGRepresentation(image);
        if(data){
            [array addObject:data];
        }
    }
    QQApiImageArrayForQZoneObject *img = [QQApiImageArrayForQZoneObject objectWithimageDataArray:array title:title];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:img];
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    [self handleSendResult:sent];
}

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
          complete:(complateCallback)callback{
    self.shareCallback = callback;
    if(!linkUrl.length){
        if(self.shareCallback){
            self.shareCallback(KKErrorCodeCommon, @"分享链接不能为空");
        }
        return;
    }
    NSURL *url = [NSURL URLWithString:linkUrl];
    if(scene == KKQQSceneTypeFriend){
        NSData *thumbData = UIImagePNGRepresentation(thumbImage);
        QQApiAudioObject *audio = [QQApiAudioObject objectWithURL:url title:title description:desc previewImageData:thumbData];
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:audio];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
    }else if(scene == KKQQSceneTypeQZone){
        if (self.shareCallback) {
            self.shareCallback(KKErrorCodeUnsupport, @"不支持分享音乐到QQ空间");
        }
    }
}

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
- (void)shareVideo:(NSString *)title desc:(NSString *)desc linkUrl:(NSString *)linkUrl thumbImage:(UIImage *)thumbImage scene:(KKQQSceneType)scene complete:(complateCallback)callback{
    self.shareCallback = callback;
    if(!linkUrl.length){
        if(self.shareCallback){
            self.shareCallback(KKErrorCodeCommon, @"分享链接不能为空");
        }
        return;
    }
    NSURL *url = [NSURL URLWithString:linkUrl];
    if(scene == KKQQSceneTypeFriend){
        NSData *thumbData = UIImagePNGRepresentation(thumbImage);
        QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:title description:desc previewImageData:thumbData];
        SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
        QQApiSendResultCode sent = [QQApiInterface sendReq:req];
        [self handleSendResult:sent];
    }else if(scene == KKQQSceneTypeQZone){
        if (self.shareCallback) {
            self.shareCallback(KKErrorCodeUnsupport, @"不支持分享视频到QQ空间");
        }
    }
}

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
- (void)shareLink:(NSString *)title desc:(NSString *)desc linkUrl:(NSString *)linkUrl thumbImage:(UIImage *)thumbImage scene:(KKQQSceneType)scene complete:(complateCallback)callback{
    self.shareCallback = callback;
    if(!linkUrl.length){
        if(self.shareCallback){
            self.shareCallback(KKErrorCodeCommon, @"分享链接不能为空");
        }
        return;
    }
    NSURL *url = [NSURL URLWithString:linkUrl];
    NSData *thumbData = UIImagePNGRepresentation(thumbImage);
    QQApiNewsObject *link = [QQApiNewsObject objectWithURL:url title:title description:desc previewImageData:thumbData];
    if(scene == KKQQSceneTypeQZone){
        [link setCflag:kQQAPICtrlFlagQZoneShareOnStart]; //不要忘记设置这个flag
    }
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:link];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
}

#pragma mark -- 分享处理结果

- (void)handleSendResult:(QQApiSendResultCode)sendResult{
    switch (sendResult){
        case EQQAPIAPPNOTREGISTED:{
            if(self.shareCallback){
                self.shareCallback(KKErrorCodeCommon, @"App未注册");
            }
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:{
            if(self.shareCallback){
                self.shareCallback(KKErrorCodeCommon, @"发送参数错误");
            }
            break;
        }
        case EQQAPIQQNOTINSTALLED:{
            if(self.shareCallback){
                self.shareCallback(KKErrorCodeCommon, @"未安装手机QQ");
            }
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:{
            if(self.shareCallback){
                self.shareCallback(KKErrorCodeUnsupport, @"API接口不支持");
            }
            break;
        }
        case EQQAPISENDFAILD:{
            if(self.shareCallback){
                self.shareCallback(KKErrorCodeFail, @"发送失败");
            }
            break;
        }
        case EQQAPIVERSIONNEEDUPDATE:{
            if(self.shareCallback){
                self.shareCallback(KKErrorCodeCommon, @"当前QQ版本太低，需要更新");
            }
            break;
        }
        default:{
            break;
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

@end










#pragma mark -- ///////////////QQ授权/////////////////

@implementation KKQQTool(KKAuthorize)

#pragma mark -- 申请授权

- (BOOL)requireAuthorizeInViewCtrl:(UIViewController *)ctrl complete:(authorizeCompleteCallback)callback{
    self.authCallback = callback;
    
    NSArray *permissions = [NSArray arrayWithObjects:
                    kOPEN_PERMISSION_GET_USER_INFO,
                    kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                    kOPEN_PERMISSION_GET_INFO,
                    kOPEN_PERMISSION_ADD_TOPIC,
                    kOPEN_PERMISSION_ADD_ONE_BLOG,
                    kOPEN_PERMISSION_ADD_SHARE,nil];
    
    [self.tencentOAuth authorize:permissions inSafari:NO];
    
    return YES;
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
