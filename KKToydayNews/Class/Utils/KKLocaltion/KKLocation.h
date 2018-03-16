//
//  KKLocation.h
//  KKToydayNews
//
//  Created by finger on 2017/9/3.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKLocation : NSObject

@property(nonatomic,copy)NSString *curtCity;
@property(nonatomic,copy)NSString *latitude;
@property(nonatomic,copy)NSString *longitude;

+ (instancetype)shareInstance;

+ (BOOL)locationStatus;

+ (NSString *)locationStatusString;

#pragma mark -- 开始结束定位

- (void)startUpdateLocation;
- (void)stopUpdateLocation;

#pragma mark - 检查授权状态

- (void)checkLocationServicesAuthorizationStatus;

@end
