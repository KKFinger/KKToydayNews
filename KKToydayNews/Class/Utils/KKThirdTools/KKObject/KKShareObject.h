//
//  KKShareObject.h
//  KKTodayNews
//
//  Created by finger on 2018/2/14.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKThirdHeader.h"

@interface KKShareObject : NSObject
@property(nonatomic,assign)KKShareContentType shareType;
@property(nonatomic,copy)NSString *title;//分享标题
@property(nonatomic,copy)NSString *desc;//分享描述
@property(nonatomic,copy)NSString *shareContent;//纯文本分享时的分享内容
@property(nonatomic,copy)NSString *linkUrl;//点击分享小卡片后的跳转链接
@property(nonatomic,copy)NSString *dataUrl;//数据链接，微信的音乐和视频分享，点击分享小卡片上的播放按钮，可直接使用该链接播放
@property(nonatomic,strong)UIImage *shareImage;//分享图片
@property(nonatomic,strong)NSArray<UIImage *> *shareImages;//批量分享图片到QQ空间
@property(nonatomic,strong)UIImage *thumbImage;//缩略图，分享的图片、音乐、视频的缩略图
@end
