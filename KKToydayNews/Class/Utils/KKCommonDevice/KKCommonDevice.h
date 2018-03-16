//
//  KKCommonDevice.h
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum
{
    iPhoneType_unknow = -1,
    iPhoneType_4      = 1,
    iPhoneType_4s     = iPhoneType_4,
    iPhoneType_5      = 2,
    iPhoneType_5s     = iPhoneType_5,
    iPhoneType_5c     = iPhoneType_5,
    iPhoneType_6      = 3,
    iPhoneType_6_plus = 4,
    iPadType_ALL = 5,
};
typedef NSInteger DeviceType;

static inline NSArray *networkTypeString() {
    NSArray *values = @[@"无网络",
                        @"2G",
                        @"3G",
                        @"4G",
                        @"LTE",
                        @"WIFI"
                        ];
    return values;
}

enum
{
    NetworkType_NotReachable = 0,
    NetworkType_2G           = 1,
    NetworkType_3G           = 2,
    NetworkType_4G           = 3,
    NetworkType_LTE          = 4,
    NetworkType_WIFI         = 5
};
typedef NSInteger NetworkType;

typedef UInt32 PhoneToneSoundID;
CF_ENUM(PhoneToneSoundID){
    kPhoneToneSoundID_Default  = 0,
    kPhoneToneSoundID_Custom   = 1
};
    
@interface KKCommonDevice : NSObject

#pragma mark - 手机信息
//设备名称
+ (NSString *)deviceName;

//设备类型
+ (NSString *)deviceModel;

//系统名称
+ (NSString *)deviceSystemName;

//系统版本号
+ (NSString *)deviceSystemVersion;

//设备当前使用语言
+ (NSString *)deviceCurrentLanguage;

//设备当前电量
+ (int)deviceBatteryValue;

//设备分辨率
+ (CGSize)deviceResolution;

//设备显示缩放率
+ (CGFloat)deviceScreenScale;

//系统版本
+ (NSString *)systemVersion;

//系统版本，返回float类型
+ (CGFloat)IOSVersion;

+ (BOOL)IOS7;
+ (BOOL)IOS8;
+ (BOOL)IOS9;
+ (BOOL)IOS10;
+ (BOOL)IOS103;

//手机类型
+ (DeviceType)getIPhoneType;

//设备类型，手机或者ipad
+ (DeviceType)getDeviceType;

+ (NSString *)devicePlatForm;

//手机总容量
+ (long long)deviceTotalSpace;

//手机剩余容量
+ (long long)deviceFreeSpace;

//获取当前的网络类型
+ (NSString *)getCurrentNetworkType;

//获取当前已连接网络名称
+ (NSString *)getWifiName;

#pragma mark - 手机功能

//手机震动
+ (void)PhoneVibration;

//手机铃声(文件时长不得操过35秒)
+ (void)PhoeTone;
+ (void)PhoneToneWithSoundFilePath:(NSString*)filePath;

+ (void)openSystemSettingWiFi;
+ (void)openSystemSettingAppCompetence;

//闪光灯
+ (void)turnTorchOn:(BOOL)on;

#pragma mark -- 获取设备当前ip地址

+ (void)deviceIpAddress:(void(^)(NSString *ip))resultHandler;
+ (NSString *)deviceIpAddress;

#pragma mark -- 获取设备的mac地址

+ (NSString*)ipToMacAddress:(NSString*)ipAddress;

#pragma mark -- 获取设备的mac地址

+ (NSString*)getRouteIpAddress;

@end
