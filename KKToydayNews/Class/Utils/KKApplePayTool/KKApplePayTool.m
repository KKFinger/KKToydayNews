//
//  KKApplePayTool.m
//  KKToydayNews
//
//  Created by finger on 2018/2/24.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKApplePayTool.h"
#import <PassKit/PassKit.h>
#import <PassKit/PKPaymentAuthorizationViewController.h>
#import <AddressBook/AddressBook.h>

@interface KKApplePayTool()<PKPaymentAuthorizationViewControllerDelegate>
@property(nonatomic)payCompleteCallback payCallback;
@end

@implementation KKApplePayTool

- (void)payWithMerchantId:(NSString *)merchantId viewCtrl:(UIViewController *)viewCtrl complete:(payCompleteCallback)callback{
    
    self.payCallback = callback;
    
    //操作系统9.0以上版本，且iPhone6以上设备才支持
    if (![PKPaymentAuthorizationViewController class]) {
        if(self.payCallback){
            self.payCallback(KKApplePayErrorCodeSysVersionLow);
        }
        return;
    }
    //检查当前设备是否可以支付
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        //支付需iOS9.0以上支持
        if(self.payCallback){
            self.payCallback(KKApplePayErrorCodeSysVersionLow);
        }
        return;
    }
    //检查用户是否可进行某种卡的支付，是否支持Amex、MasterCard、Visa与银联四种卡，根据自己项目的需要进行检测
    NSArray *supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkMasterCard,PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay];
    if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:supportedNetworks]) {
        //没有绑定支付卡
        if(self.payCallback){
            self.payCallback(KKApplePayErrorCodeUnBingBankCard);
        }
        return;
    }
    
    //设置币种、国家码及merchant标识符等基本信息
    PKPaymentRequest *payRequest = [[PKPaymentRequest alloc]init];
    payRequest.countryCode = @"CN"; //国家代码
    payRequest.currencyCode = @"CNY"; //RMB的币种代码
    payRequest.merchantIdentifier = merchantId; //申请的merchantID
    payRequest.supportedNetworks = supportedNetworks; //用户可进行支付的银行卡
    payRequest.merchantCapabilities = PKMerchantCapability3DS|PKMerchantCapabilityEMV;      //设置支持的交易处理协议，3DS必须支持，EMV为可选
    payRequest.requiredShippingAddressFields = PKAddressFieldNone;//不设置送货地址
    payRequest.shippingMethods = nil;//配送方式
    
    NSDecimalNumber *subtotalAmount = [NSDecimalNumber decimalNumberWithMantissa:1275 exponent:-2 isNegative:NO];   //12.75
    PKPaymentSummaryItem *subtotal = [PKPaymentSummaryItem summaryItemWithLabel:@"商品价格" amount:subtotalAmount];
    
    NSDecimalNumber *discountAmount = [NSDecimalNumber decimalNumberWithString:@"-12.74"];      //-12.74
    PKPaymentSummaryItem *discount = [PKPaymentSummaryItem summaryItemWithLabel:@"优惠折扣" amount:discountAmount];
    
    NSDecimalNumber *methodsAmount = [NSDecimalNumber zero];
    PKPaymentSummaryItem *methods = [PKPaymentSummaryItem summaryItemWithLabel:@"包邮" amount:methodsAmount];
    
    NSDecimalNumber *totalAmount = [NSDecimalNumber zero];
    totalAmount = [totalAmount decimalNumberByAdding:subtotalAmount];
    totalAmount = [totalAmount decimalNumberByAdding:discountAmount];
    totalAmount = [totalAmount decimalNumberByAdding:methodsAmount];
    PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"Yasin" amount:totalAmount];  //最后这个是支付给谁。哈哈，快支付给我
    
    NSMutableArray *summaryItems = [NSMutableArray arrayWithArray:@[subtotal, discount, methods, total]];
    //summaryItems为账单列表，类型是 NSMutableArray，这里设置成成员变量，在后续的代理回调中可以进行支付金额的调整。
    payRequest.paymentSummaryItems = summaryItems;
    
    
    //ApplePay控件
    PKPaymentAuthorizationViewController *view = [[PKPaymentAuthorizationViewController alloc]initWithPaymentRequest:payRequest];
    view.delegate = self;
    
    UIViewController *ctrl = viewCtrl;
    while (ctrl.presentedViewController) {
        ctrl = ctrl.presentedViewController;
    }
    [ctrl presentViewController:view animated:YES completion:nil];
}

#pragma mark -- PKPaymentAuthorizationViewControllerDelegate

//送货信息变更回调
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                  didSelectShippingContact:(PKContact *)contact
                                completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> * _Nonnull, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion{
    //contact送货地址信息，PKContact类型
    NSPersonNameComponents *name = contact.name;                //联系人姓名
    CNPostalAddress *postalAddress = contact.postalAddress;     //联系人地址
    NSString *emailAddress = contact.emailAddress;              //联系人邮箱
    CNPhoneNumber *phoneNumber = contact.phoneNumber;           //联系人手机
    NSString *supplementarySubLocality = contact.supplementarySubLocality;  //补充信息,iOS9.2及以上才有
}

//配送方式变更回调
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                   didSelectShippingMethod:(PKShippingMethod *)shippingMethod
                                completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion{
}

//支付银行卡变更回调
-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod completion:(void (^)(NSArray<PKPaymentSummaryItem *> * _Nonnull))completion{
}

//付款成功回调
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    
    PKPaymentToken *payToken = payment.token;
    //支付凭据，发给服务端进行验证支付是否真实有效
    PKContact *billingContact = payment.billingContact;     //账单信息
    PKContact *shippingContact = payment.shippingContact;   //送货信息
    PKContact *shippingMethod = payment.shippingMethod;     //送货方式
    //等待服务器返回结果后再进行系统block调用
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //模拟服务器通信
        completion(PKPaymentAuthorizationStatusSuccess);
    });
    
    
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
