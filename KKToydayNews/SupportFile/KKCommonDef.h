//
//  KKCommonDef.h
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#ifndef KKCommonDef_h
#define KKCommonDef_h

#import <objc/runtime.h>

#define KKBundleDictionary [[NSBundle mainBundle] infoDictionary]
//app版本
#define KKAppVersion [KKBundleDictionary objectForKey:@"CFBundleShortVersionString"]
// app build版本
#define KKAppBuildVersion [KKBundleDictionary objectForKey:@"CFBundleVersion"]
//获取BundleID
#define KKAppBundleId [KKBundleDictionary objectForKey:@"CFBundleIdentifier"]

#define UIDeviceScreenSize   [[UIScreen mainScreen] bounds].size
#define UIDeviceScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define UIDeviceScreenHeight [[UIScreen mainScreen] bounds].size.height

#define IOS11_OR_LATER		( [[[UIDevice currentDevice] systemVersion] compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS10_OR_LATER		( [[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS9_OR_LATER		( [[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS8_OR_LATER		( [[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS7_OR_LATER		( [[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS6_OR_LATER		( [[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS5_OR_LATER		( [[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS4_OR_LATER		( [[[UIDevice currentDevice] systemVersion] compare:@"4.0" options:NSNumericSearch] != NSOrderedAscending )
#define IOS3_OR_LATER		( [[[UIDevice currentDevice] systemVersion] compare:@"3.0" options:NSNumericSearch] != NSOrderedAscending )

#define IOS10_OR_EARLIER	( !IOS11_OR_LATER )
#define IOS9_OR_EARLIER		( !IOS10_OR_LATER )
#define IOS8_OR_EARLIER		( !IOS9_OR_LATER )
#define IOS7_OR_EARLIER		( !IOS8_OR_LATER )
#define IOS6_OR_EARLIER		( !IOS7_OR_LATER )
#define IOS5_OR_EARLIER		( !IOS6_OR_LATER )
#define IOS4_OR_EARLIER		( !IOS5_OR_LATER )
#define IOS3_OR_EARLIER		( !IOS4_OR_LATER )

#define SYSTEM_VERSION_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) \
([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_SCREEN_55_INCH	([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_SCREEN_47_INCH	([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_SCREEN_4_INCH	([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_SCREEN_35_INCH	([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

//判断设备类型
#define iPhone4 ([UIScreen mainScreen].bounds.size.height == 480)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size)) : NO)
#define iPhonePlus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneXs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneXsMax ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhoneXr ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1624), [[UIScreen mainScreen] currentMode].size) : NO)

//iPhoneX、iPhoneXS、iPhoneXsMax、iPhoneXR适配
#define KKStatusBarHeight ((iPhoneX || iPhoneXs || iPhoneXsMax || iPhoneXr) ? 44 : 20)
#define KKNavBarHeight ((iPhoneX || iPhoneXs || iPhoneXsMax || iPhoneXr) ? 88 : 64)
#define KKSafeAreaBottomHeight ((iPhoneX || iPhoneXs || iPhoneXsMax || iPhoneXr) ? 34 : 0)
#define KKTabbarHeight ((iPhoneX || iPhoneXs || iPhoneXsMax || iPhoneXr) ? 83 : 49)

#define KKAdjustsScrollViewInsets(scrollView)\
do {\
_Pragma("clang diagnostic push")\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")\
if ([scrollView respondsToSelector:NSSelectorFromString(@"setContentInsetAdjustmentBehavior:")]) {\
NSMethodSignature *signature = [UIScrollView instanceMethodSignatureForSelector:@selector(setContentInsetAdjustmentBehavior:)];\
NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];\
NSInteger argument = 2;\
invocation.target = scrollView;\
invocation.selector = @selector(setContentInsetAdjustmentBehavior:);\
[invocation setArgument:&argument atIndex:2];\
[invocation retainArguments];\
[invocation invoke];\
}\
_Pragma("clang diagnostic pop")\
} while (0)


#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000

#define UILineBreakMode					NSLineBreakMode
#define UILineBreakModeWordWrap			NSLineBreakByWordWrapping
#define UILineBreakModeCharacterWrap	NSLineBreakByCharWrapping
#define UILineBreakModeClip				NSLineBreakByClipping
#define UILineBreakModeHeadTruncation	NSLineBreakByTruncatingHead
#define UILineBreakModeTailTruncation	NSLineBreakByTruncatingTail
#define UILineBreakModeMiddleTruncation	NSLineBreakByTruncatingMiddle

#define UITextAlignmentLeft				NSTextAlignmentLeft
#define UITextAlignmentCenter			NSTextAlignmentCenter
#define UITextAlignmentRight			NSTextAlignmentRight
#define	UITextAlignment					NSTextAlignment

#endif

// block 安全self
#if __has_feature(objc_arc)
// arc
#define WEAKSELF        typeof(self) __weak weakSelf = self
#define STRONGSELF      typeof(weakSelf) __strong strongSelf = weakSelf
#else
// mrc
#define WEAKSELF     __block typeof(id) weakSelf = self;
#define WEAKSELF_( __CLASSNAME__ )     __block typeof( __CLASSNAME__ *) weakSelf = self;
#endif

#define __weakify(type) @weakify(type)
#define __strongify(type) @strongify(type)

//颜色相关
#define KKColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define randomColorValue arc4random_uniform(256)
#define KKRandomColor [UIColor colorWithRed:(randomColorValue)/255.0 green:(randomColorValue)/255.0 blue:(randomColorValue)/255.0 alpha:1.0]


#pragma mark --关联方法宏定义
/*
 用法
 @property(nonatomic,assign)NSInteger pageCount;//基本类型属性
 @property(nonatomic,assign)NSArray *dataArray;//对象类型属性
 
 ////基本类型使用方法
 SYNTHESIZE_CATEGORY_VALUE_PROPERTY(NSInteger, pageCount, setPageCount:);
 //对象类型使用方法
 SYNTHESIZE_CATEGORY_OBJ_PROPERTY(dataArray, setDataArray:);
 
 */

//对象类型
#define SYNTHESIZE_CATEGORY_OBJ_PROPERTY(propertyGetter, propertySetter)\
- (id) propertyGetter {\
return objc_getAssociatedObject(self, @selector( propertyGetter ));\
}\
- (void) propertySetter (id)obj{\
objc_setAssociatedObject(self, @selector( propertyGetter ), obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}

//基本类型
#define SYNTHESIZE_CATEGORY_VALUE_PROPERTY(valueType, propertyGetter, propertySetter)\
- (valueType) propertyGetter {\
valueType ret = {0};\
[objc_getAssociatedObject(self, @selector( propertyGetter )) getValue:&ret];\
return ret;\
}\
- (void) propertySetter (valueType)value{\
NSValue *valueObj = [NSValue valueWithBytes:&value objCType:@encode(valueType)];\
objc_setAssociatedObject(self, @selector( propertyGetter ), valueObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}


#define KKNewsAlbumName @"KK头条"

#define KKUserFavSectionData @"KKUserFavSectionData"//保存用户感兴趣的板块
#define KKXiGuaSectionData @"KKXiGuaSectionData"//西瓜视频模块的section

//标题的字体
#define KKTitleFont [UIFont systemFontOfSize:(iPhone5)?17:18]
//详情的字体
#define KKDescFont [UIFont systemFontOfSize:11]

#define KKVideoRecordFileFolder [NSTemporaryDirectory() stringByAppendingPathComponent:@"recordVideoFolder"]
#define KKVideoCompressFileFolder [NSTemporaryDirectory() stringByAppendingPathComponent:@"videoCompressFolder"]
#define KKVideoMergeFileFolder [NSTemporaryDirectory() stringByAppendingPathComponent:@"videoMergeFileFolder"]

#define KKNotifyPhotoLibraryDidChange             @"KKNotifyPhotoLibraryDidChange"//相片库发生改变的通知
#define KKNotifyVideoLibraryDidChange             @"KKNotifyVideoLibraryDidChange"//视频变动通知

#define KKDeviceToken @"remoteNotifyDeviceToken"

#define BuglyAppId @"269f2796e5"//Bugly App id

#endif
