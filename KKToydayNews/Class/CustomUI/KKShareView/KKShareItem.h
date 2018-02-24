//
//  KKShareItem.h
//  KKShareView
//
//  Created by finger on 2017/8/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,KKShareType) {
    KKShareTypeWeiTouTiao,//微头条
    KKShareTypeWXTimesmp,//微信朋友圈
    KKShareTypeWXFriend,//微信好友
    KKShareTypeQQ,//QQ
    KKShareTypeQZone,//QQ空间
    KKShareTypeWeiBo,//微博
    KKShareTypeHelpToTouTiao,//帮上头条
    KKShareTypeSysShare,//系统分享
    KKShareTypeMessage,//短信
    KKShareTypeEmail,//邮件
    KKShareTypeCopyLink,//复制链接
    KKShareTypeReport,//举报
};

@interface KKShareItem : UIView
@property(nonatomic,assign)KKShareType shareType;
@property(nonatomic,copy)NSString *shareIconName;
@property(nonatomic,copy)NSString *title;
- (instancetype)initWithShareType:(KKShareType)shareType iconImageName:(NSString *)iconImageName title:(NSString *)title;
@end
