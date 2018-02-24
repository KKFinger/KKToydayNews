//
//  KKExample.h
//  KKTodayNews
//
//  Created by finger on 2018/2/15.
//  Copyright © 2018年 finger. All rights reserved.
//

#ifndef KKExample_h
#define KKExample_h

/*示例

1、微信分享

分享文本
 KKShareObject *obj = [KKShareObject new];
 obj.shareContent = @"分享纯文本";
 obj.shareType = KKShareContentTypeText;
 [KKThirdTools shareToWXWithObject:obj scene:KKWXSceneTypeTimeline complete:^(KKErrorCode resultCode,NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];

//分享图片
 KKShareObject *obj = [KKShareObject new];
 obj.shareImage = [UIImage imageWithColor:[UIColor redColor]];
 obj.thumbImage = [UIImage imageWithColor:[UIColor grayColor]];
 obj.shareType = KKShareContentTypeImage;
 [KKThirdTools shareToWXWithObject:obj scene:KKWXSceneTypeChat complete:^(KKErrorCode resultCode,NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //分享音乐
 KKShareObject *obj = [KKShareObject new];
 obj.thumbImage = [UIImage imageWithColor:[UIColor grayColor]];
 obj.shareType = KKShareContentTypeMusic;
 obj.title = @"Wish You Were Here";
 obj.desc = @"Avril Lavigne";
 obj.linkUrl = @"http://i.y.qq.com/v8/playsong.html?hostuin=0&songid=&songmid=002x5Jje3eUkXT&_wv=1&source=qq&appshare=iphone&media_mid=002x5Jje3eUkXT";
 obj.dataUrl = @"http://i.y.qq.com/v8/playsong.html?hostuin=0&songid=&songmid=002x5Jje3eUkXT&_wv=1&source=qq&appshare=iphone&media_mid=002x5Jje3eUkXT";
 [KKThirdTools shareToWXWithObject:obj scene:KKWXSceneTypeTimeline complete:^(KKErrorCode resultCode,NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //分享视频
 KKShareObject *obj = [KKShareObject new];
 obj.thumbImage = [UIImage imageWithColor:[UIColor grayColor]];
 obj.shareType = KKShareContentTypeVideo;
 obj.title = @"Wish You Were Here";
 obj.desc = @"Avril Lavigne";
 obj.linkUrl = @"http://i.y.qq.com/v8/playsong.html?hostuin=0&songid=&songmid=002x5Jje3eUkXT&_wv=1&source=qq&appshare=iphone&media_mid=002x5Jje3eUkXT";
 obj.dataUrl = @"http://i.y.qq.com/v8/playsong.html?hostuin=0&songid=&songmid=002x5Jje3eUkXT&_wv=1&source=qq&appshare=iphone&media_mid=002x5Jje3eUkXT";
 [KKThirdTools shareToWXWithObject:obj scene:KKWXSceneTypeChat complete:^(KKErrorCode resultCode,NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //分享连接
 KKShareObject *obj = [KKShareObject new];
 obj.thumbImage = [UIImage imageWithColor:[UIColor grayColor]];
 obj.shareType = KKShareContentTypeWebLink;
 obj.title = @"Wish You Were Here";
 obj.desc = @"Avril Lavigne";
 obj.linkUrl = @"http://i.y.qq.com/v8/playsong.html?hostuin=0&songid=&songmid=002x5Jje3eUkXT&_wv=1&source=qq&appshare=iphone&media_mid=002x5Jje3eUkXT";
 [KKThirdTools shareToWXWithObject:obj scene:KKWXSceneTypeChat complete:^(KKErrorCode resultCode,NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 2、QQ分享
 
 //分享文本
 KKShareObject *obj = [KKShareObject new];
 obj.shareType = KKShareContentTypeText;
 obj.shareContent = @"分享纯文本";
 [KKThirdTools shareToQQWithObject:obj scene:KKQQSceneTypeFriend complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //分享图片给好友
 KKShareObject *obj = [KKShareObject new];
 obj.shareType = KKShareContentTypeImage;
 obj.shareImage = [UIImage imageNamed:@"push_"];
 obj.title = @"图片";
 obj.desc = @"这是一张图片";
 [KKThirdTools shareToQQWithObject:obj scene:KKQQSceneTypeFriend complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //分享图片到QQ空间
 KKShareObject *obj = [KKShareObject new];
 obj.shareType = KKShareContentTypeImage;
 obj.shareImages = @[[UIImage imageNamed:@"push_"]];
 obj.title = @"图片";
 obj.desc = @"这是图片";
 [KKThirdTools shareToQQWithObject:obj scene:KKQQSceneTypeQZone complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //分享音乐
 KKShareObject *obj = [KKShareObject new];
 obj.shareType = KKShareContentTypeMusic;
 obj.title = @"Wish You Were Here";
 obj.desc = @"Avril Lavigne";
 obj.thumbImage = [UIImage imageNamed:@"push_"];
 obj.linkUrl = @"http://i.y.qq.com/v8/playsong.html?hostuin=0&songid=&songmid=002x5Jje3eUkXT&_wv=1&source=qq&appshare=iphone&media_mid=002x5Jje3eUkXT";
 [KKThirdTools shareToQQWithObject:obj scene:KKQQSceneTypeFriend complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //分享视频
 KKShareObject *obj = [KKShareObject new];
 obj.shareType = KKShareContentTypeVideo;
 obj.title = @"腾讯暗黑风动作新游《天刹》国服视频曝光";
 obj.desc = @"你觉得正在玩的动作游戏的打击感不够好？战斗不够真实缺乏技巧？PVP索然无味完全是比谁装备好？那么现在有款新游戏或许能满足你的胃口！ 《天刹》是由韩国nse公司开发，腾讯全球代理中国首发的3D锁视角动作游戏，是一款有着暗黑写实风格、东方奇幻题材的游戏，具备打击感十足的动作体验、策略多变的战斗方式，游戏操作不难但有足够的深度，在动作游戏领域首次引入了手动格挡格斗机制，构建快速攻防转换体系。 官方网站：tian.qq.com 官方微博：http://t.qq.com/tiancha001";
 obj.thumbImage = [UIImage imageNamed:@"push_"];
 obj.linkUrl = @"http://www.tudou.com/programs/view/_cVM3aAp270/";
 [KKThirdTools shareToQQWithObject:obj scene:KKQQSceneTypeFriend complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 
 //分享链接
 KKShareObject *obj = [KKShareObject new];
 obj.shareType = KKShareContentTypeWebLink;
 obj.title = @"天公作美伦敦奥运圣火点燃成功 火炬传递开启";
 obj.desc = @"腾讯体育讯 当地时间5月10日中午，阳光和全世界的目光聚焦于希腊最高女祭司手中的火炬上，5秒钟内世界屏住呼吸。火焰骤然升腾的瞬间，古老的号角声随之从赫拉神庙传出——第30届伦敦夏季奥运会圣火在古奥林匹亚遗址点燃。取火仪式前，国际奥委会主席罗格、希腊奥委会主席卡普拉洛斯和伦敦奥组委主席塞巴斯蒂安-科互赠礼物，男祭司继北京奥运会后，再度出现在采火仪式中。";
 obj.thumbImage = [UIImage imageNamed:@"push_"];
 obj.linkUrl = @"http://sports.qq.com/a/20120510/000650.htm";
 [KKThirdTools shareToQQWithObject:obj scene:KKQQSceneTypeFriend complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 
 微博分享
 
 //分享文字
 KKShareObject *obj = [KKShareObject new];
 obj.shareContent = @"分享少时诵诗书所所";
 obj.shareType = KKShareContentTypeText;
 [KKThirdTools shareToWbWithObject:obj complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];

 //分享图片
 KKShareObject *obj = [KKShareObject new];
 obj.shareImages = @[[UIImage imageNamed:@"userHead"]];
 obj.shareType = KKShareContentTypeImage;
 [KKThirdTools shareToWbWithObject:obj complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //分享视频
 KKShareObject *obj = [KKShareObject new];
 obj.dataUrl = [[NSBundle mainBundle]pathForResource:@"apm" ofType:@"mov"];
 obj.shareType = KKShareContentTypeVideo;
 [KKThirdTools shareToWbWithObject:obj complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //分享链接
 KKShareObject *obj = [KKShareObject new];
 obj.title = @"分享链接";
 obj.desc = @"这是一个分享链接";
 obj.linkUrl = @"http://weibo.com/p/1001603849727862021333?rightmod=1&wvr=6&mod=noticeboard";
 obj.thumbImage = [UIImage imageNamed:@"userHead"];
 obj.shareType = KKShareContentTypeWebLink;
 [KKThirdTools shareToWbWithObject:obj complete:^(KKErrorCode resultCode, NSString *resultString) {
 NSString *title = @"分享成功";
 if(resultCode != KKSuccess){
 title = @"分享错误";
 }
 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:resultString delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 [alert show];
 }];
 
 //第三方授权
 [KKThirdTools authorizeWithPlatform:KKThirdPlatformWX inViewCtrl:self complate:^(KKErrorCode resultCode, KKAuthorizeObject *authObj) {
 NSString *name = authObj.nickName;
 NSString *sex = authObj.gender;
 NSString *headUrl = authObj.headImgUrl;
 NSString *userId = authObj.userId;
 NSLog(@"name:%@,sex:%@,headUrl:%@,userId:%@",name,sex,headUrl,userId);
 }];
 
 //第三方支付
 
 //data由后台返回
 KKWXPayObject *payObj = [KKWXPayObject new];
 payObj.nonceStr = data[@"noncestr"];
 payObj.partnerId = data[@"partnerid"];
 payObj.prepayId = data[@"prepay_id"];
 payObj.sign = data[@"sign"];
 payObj.timeStamp = [data[@"timestamp"]integerValue];
 payObj.package = @"Sign=WXPay";
 [KKThirdTools paymentWithPlatform:KKThirdPlatformWX payInfo:payObj complete:^(KKErrorCode resultCode, NSString *resultString) {
 if(resultCode == KKSuccess){
 [self.view promptMessage:@"支付成功"];
 }else{
 [self.view promptMessage:resultString];
 }
 }];
 
*/
#endif /* KKExample_h */
