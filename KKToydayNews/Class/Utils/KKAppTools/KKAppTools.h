//
//  KKAppTools.h
//  KKToydayNews
//
//  Created by finger on 2017/9/20.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKAppTools : NSObject

#pragma mark -- 返回当前类的所有属性
+ (NSArray *)getProperties:(Class)cls;
#pragma mark -- 跳转到设置界面
+ (void)jumpToSetting;
#pragma mark -- 视图是push还是present显示的
+ (BOOL)isPushWithCtrl:(UIViewController *)ctrl;
#pragma mark -- 字节大小转换
+ (NSString*)formatSizeFromByte:(long long)bytes;
#pragma mark -- 时长转换
+ (NSString *)convertDurationToString:(NSTimeInterval)duration;
#pragma mark -- Unicode转码
+ (NSString*)replaceUnicode:(NSString*)unicodeString;
#pragma mark -- 生成as和cp,数据请求时会用到
+ (void)generateAs:(NSString **)asStr cp:(NSString **)cpStr;
#pragma mark -- md5加密
+ (NSString *)md5String:(NSString *)content;
#pragma mark -- 十进制转16进制
+ (NSString *)toHexString:(long long)tmpid;
@end

@interface KKAppTools (KKFile)
#pragma mark -- 清除文件夹下的所有文件
+ (void)clearFileAtFolder:(NSString *)folderPath;
#pragma mark -- 创建文件夹
+ (NSString *)createFolderIfNeed:(NSString *)folderPath;
#pragma mark -- 生成视频名称，确保唯一性
+ (NSString *)formartFileName:(NSString *)name fileType:(NSString *)fileType;
#pragma mark -- 获取ctrl最顶层的present出来的控制器
- (UIViewController *)presentedCttl:(UIViewController *)ctrl;
#pragma mark -- 获取ctrl最底层的present出来的控制器
- (UIViewController *)presentingCttl:(UIViewController *)ctrl;

@end
