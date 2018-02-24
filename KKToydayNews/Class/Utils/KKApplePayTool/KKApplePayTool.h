//
//  KKApplePayTool.h
//  KKToydayNews
//
//  Created by finger on 2018/2/24.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

//支付错误类型
typedef NS_ENUM(NSInteger, KKApplePayErrorCode){
    KKApplePaySuccess,//成功
    KKApplePayErrorCodeSysVersionLow,//系统版本太低，系统版本要在9.0级以上
    KKApplePayErrorCodeUnBingBankCard,//没有绑定银行卡
};

typedef void(^payCompleteCallback)(KKApplePayErrorCode errCode);

@interface KKApplePayTool : NSObject
- (void)payWithMerchantId:(NSString *)merchantId viewCtrl:(UIViewController *)viewCtrl complete:(payCompleteCallback)callback;
@end
