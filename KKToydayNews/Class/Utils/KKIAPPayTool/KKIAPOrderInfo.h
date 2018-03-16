//
//  KKIAPOrderInfo.h
//  KKTodayNews
//
//  Created by finger on 2018/2/23.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKIAPOrderInfo : NSObject
@property(nonatomic,copy)NSString *transactionId;//订单号
@property(nonatomic,copy)NSString *productId;//产品ID
@property(nonatomic,copy)NSString *userId;//支付者id
@property(nonatomic,copy)NSString *productReceipt;//交易凭证,用于验证交易结果
@property(nonatomic,assign)BOOL isSandboxEnvironment;//沙盒或者正式环境
@end
