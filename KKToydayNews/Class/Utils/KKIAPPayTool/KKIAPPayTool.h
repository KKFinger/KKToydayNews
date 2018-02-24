//
//  KKIAPPayTool.h
//  KKTodayNews
//
//  Created by finger on 2018/2/23.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "KKIAPOrderInfo.h"

//支付错误类型
typedef NS_ENUM(NSInteger, KKIPAErrorCode){
    KKIPASuccess,//成功
    KKIPAErrorCodeProductIdEmpty,//商品id为空
    KKIPAErrorCodeUnSupport,//不支持IPA
    KKIPAErrorCodeProductNotFound,//商品找不到
    KKIPAErrorCodeUnknown,//未知
    KKIPAErrorCodeInvalidAppleId,//apple id 无效
    KKIPAErrorCodeCancelled,//用户取消
    KKIPAErrorCodePaymentInvalid,//订单无效
    KKIPAErrorCodePaymentNotAllowed,//设备未允许付款
    KKIPAErrorCodeProductNotAvailable,//商品不可用
    KKIPAErrorCodePermissionDenied,
    KKIPAErrorCodeConnectionFailed,//网络连接错误
    KKIPAErrorCodeVerifyReceiptError,//验证交易凭据错误
};

//查询内购项目回调
typedef void(^queryProductInfoCallback)(NSArray<SKProduct *> *productArray, NSArray<NSString *> *invalidProductsIds);
//支付结果回调
typedef void(^payCompleteCallback)(KKIAPOrderInfo *orderInfo,KKIPAErrorCode errorCode);

@interface KKIAPPayTool : NSObject

#pragma mark -- 查询内购项目信息
/**
 查询内购项目信息
 @param productIds 内购项目的id，详见itnues connect上app申请的内购详请
 @param callback 内购项目的数组
 */
- (void)queryProductInfoWithProductIds:(NSArray *)productIds complete:(queryProductInfoCallback)callback;

#pragma mark -- 购买
/**
 购买
 @param productId 内购项目的id，详见itnues connect上app申请的内购详请
 @param userId 支付用户id，没有可置空
 @param shouldCheckReceipt 是否在app端验证交易凭证
 @param complete 支付结果回调
 */
- (void)buyProductById:(NSString *)productId userId:(NSString *)userId shouldCheckReceipt:(BOOL)shouldCheckReceipt complete:(payCompleteCallback)complete;

@end
