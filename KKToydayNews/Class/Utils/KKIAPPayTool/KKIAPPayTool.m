//
//  KKIAPPayTool.m
//  KKTodayNews
//
//  Created by finger on 2018/2/23.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKIAPPayTool.h"

#define SandboxVerifyReceiptURL @"https://sandbox.itunes.apple.com/verifyReceipt"
#define ProductionVerifyReceiptURL @"https://buy.itunes.apple.com/verifyReceipt"

@interface KKIAPPayTool()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
@property(nonatomic)NSMutableArray<queryProductInfoCallback> *queryProductCallbacks;
@property(nonatomic,copy)payCompleteCallback payCompleteCallback;
@property(nonatomic)NSMutableDictionary<NSString *,SKProduct *> *productInfos;//内购项目信息
@property(nonatomic,assign)BOOL shouldCheckReceipt;//是否在app端验证交易凭证
@property(nonatomic)SKPaymentTransaction *curtTransaction;
@end

@implementation KKIAPPayTool

- (instancetype)init{
    self = [super init];
    if(self){
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue]restoreCompletedTransactions];
    }
    return self;
}

- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 查询内购项目信息
/**
 查询内购项目信息
 
 @param productIds 内购项目的id，详见itnues connect上app申请的内购详请
 @param complete 内购项目的数组
 */
- (void)queryProductInfoWithProductIds:(NSArray *)productIds complete:(queryProductInfoCallback)callback{
    if(productIds.count <= 0){
        if(callback){
            callback(nil,nil);
        }
        return;
    }
    
    if(callback){
        @synchronized(self){
            [self.queryProductCallbacks addObject:callback];
        }
    }
    
    NSSet *productSet = [NSSet setWithArray:productIds];
    SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productSet];
    productRequest.delegate = self;
    [productRequest start];
}

#pragma mark -- 购买
/**
 购买
 @param productId 内购项目的id，详见itnues connect上app申请的内购详请
 @param userId 支付用户id，没有可置空
 @param shouldCheckReceipt 是否在app端验证交易凭证
 @param complete 支付结果回调
 */
- (void)buyProductById:(NSString *)productId userId:(NSString *)userId shouldCheckReceipt:(BOOL)shouldCheckReceipt complete:(payCompleteCallback)complete{
    if(!productId.length){
        if(complete){
            complete(nil,KKIPAErrorCodeProductIdEmpty);
        }
        return ;
    }
    
    if (![SKPaymentQueue canMakePayments]) {
        if(complete){
            complete(nil,KKIPAErrorCodeUnSupport);
        }
        return ;
    }
    
    self.payCompleteCallback = complete;
    self.shouldCheckReceipt = shouldCheckReceipt;
    
    SKProduct *product = [self.productInfos objectForKey:productId];
    if(product){
        SKMutablePayment *payment= [SKMutablePayment paymentWithProduct:product];
        payment.applicationUsername = userId;
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        NSLog(@"");
    }else{
        __weak typeof(self)wSelf = self;
        [self queryProductInfoWithProductIds:@[productId] complete:^(NSArray<SKProduct *> *productArray, NSArray<NSString *> *invalidProductsIds) {
            SKProduct *product = productArray.firstObject;
            if(product && [product.productIdentifier isEqualToString:productId]){
                SKMutablePayment *payment= [SKMutablePayment paymentWithProduct:product];
                payment.applicationUsername = userId;
                [[SKPaymentQueue defaultQueue] addPayment:payment];
                NSLog(@"");
            }else{
                if(wSelf.payCompleteCallback){
                    wSelf.payCompleteCallback(nil, KKIPAErrorCodeProductNotFound);
                }
            }
        }];
    }
}

#pragma mark -- SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSArray *products = response.products;
    NSArray *invalidProductsIds = response.invalidProductIdentifiers;
    for(SKProduct *product in products){
        [self.productInfos setObject:product forKey:product.productIdentifier];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        @synchronized(self){
            for(queryProductInfoCallback callback in self.queryProductCallbacks){
                callback(products, invalidProductsIds);
            }
            [self.queryProductCallbacks removeAllObjects];
        }
    });
}

#pragma mark -- SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
    for (SKPaymentTransaction *paymentTransaction in transactions) {
        self.curtTransaction = paymentTransaction;
        switch (paymentTransaction.transactionState) {
            case SKPaymentTransactionStatePurchased:{ //支付完成
                [self compaleteTransaction:paymentTransaction];
            }
                break;
            case SKPaymentTransactionStateFailed:{  //支付失败
                [self failedTransaction:paymentTransaction];
            }
                break;
            case SKPaymentTransactionStateRestored:{//恢复购买
                [self resroreTransaction:paymentTransaction];
            }
                break;
            case SKPaymentTransactionStatePurchasing:{ //商品添加进列表
            }
                break;
            case SKPaymentTransactionStateDeferred:{
                NSLog(@"交易还在队列里面，但最终状态还没有决定");
            }
                break;
            default:
                break;
        }
    }
}

// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions{
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    for (SKPaymentTransaction *paymentTransaction in queue.transactions) {
        switch (paymentTransaction.transactionState){
            case SKPaymentTransactionStateRestored:
            case SKPaymentTransactionStatePurchased:{
                if (paymentTransaction.transactionIdentifier) {
                    [self resroreTransaction:paymentTransaction];
                } else {
                    [[SKPaymentQueue defaultQueue] finishTransaction:paymentTransaction];
                }
            }
            default:
                break;
        }
    }
}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
}

#pragma mark -- 交易完成

- (void)compaleteTransaction:(SKPaymentTransaction *)transaction {
    if(self.shouldCheckReceipt){
        [self verifyReceiptWithTransaction:transaction];
    }else{
        KKIAPOrderInfo *orderInfo = [self convertTransaction:transaction];
        if(self.payCompleteCallback){
            self.payCompleteCallback(orderInfo, KKIPASuccess);
        }
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark -- 交易失败

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    KKIPAErrorCode errCode = KKIPASuccess;
    switch (transaction.error.code) {
        case SKErrorUnknown:
            errCode = KKIPAErrorCodeUnknown;
            break;
        case SKErrorClientInvalid:
            errCode = KKIPAErrorCodeInvalidAppleId;
            break;
        case SKErrorPaymentCancelled:
            errCode = KKIPAErrorCodeCancelled;
            break;
        case SKErrorPaymentInvalid:
            errCode = KKIPAErrorCodePaymentInvalid;
            break;
        case SKErrorPaymentNotAllowed:
            errCode = KKIPAErrorCodePaymentNotAllowed;
            break;
        case SKErrorStoreProductNotAvailable:
            errCode = KKIPAErrorCodeProductNotAvailable;
            break;
#ifdef NSFoundationVersionNumber_iOS_9_3
        case SKErrorCloudServicePermissionDenied:
            errCode = KKIPAErrorCodePermissionDenied;
            break;
        case SKErrorCloudServiceNetworkConnectionFailed:
            errCode = KKIPAErrorCodeConnectionFailed;
            break;
#endif
        default:
            errCode = KKIPAErrorCodeUnknown;
            break;
    }
    KKIAPOrderInfo *orderInfo = [self convertTransaction:transaction];
    if(self.payCompleteCallback){
        self.payCompleteCallback(orderInfo, errCode);
    }
}

#pragma mark -- 恢复已购买商品

- (void)resroreTransaction:(SKPaymentTransaction *)transaction {
    if(self.shouldCheckReceipt){
        [self verifyReceiptWithTransaction:transaction];
    }else{
        KKIAPOrderInfo *orderInfo = [self convertTransaction:transaction];
        if(self.payCompleteCallback){
            self.payCompleteCallback(orderInfo, KKIPASuccess);
        }
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark -- 交易验证

-(void)verifyReceiptWithTransaction:(SKPaymentTransaction *)transaction{
    [self verifyReceiptWithEnvironment:[self isSandBoxEnvironment:transaction] transaction:transaction];
}

- (void)verifyReceiptWithEnvironment:(BOOL)isSandbox transaction:(SKPaymentTransaction *)transaction{
    __weak typeof(self)wSelf = self;
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    NSString *receiptStr = [receiptData base64EncodedStringWithOptions:0];
    [self fetchVerifyDataWithEnvironment:isSandbox receiptStr:receiptStr complete:^(id resultObject, NSError *error) {
        KKIAPOrderInfo *orderInfo = [wSelf convertTransaction:transaction];
        if (error) {
            if(wSelf.payCompleteCallback){
                wSelf.payCompleteCallback(orderInfo, KKIPAErrorCodeVerifyReceiptError);
            }
        } else {
            if(!resultObject){
                if(wSelf.payCompleteCallback){
                    wSelf.payCompleteCallback(orderInfo, KKIPAErrorCodeVerifyReceiptError);
                }
                return ;
            }
            NSString *statusKey = @"status";
            
            /*
             内购验证凭据返回结果状态码说明
             21000 App Store无法读取你提供的JSON数据
             21002 收据数据不符合格式
             21003 收据无法被验证
             21004 你提供的共享密钥和账户的共享密钥不一致
             21005 收据服务器当前不可用
             21006 收据是有效的，但订阅服务已经过期。当收到这个信息时，解码后的收据信息也包含在返回内容中
             21007 收据信息是测试用（sandbox），但却被发送到产品环境中验证
             21008 收据信息是产品环境中使用，但却被发送到测试环境中验证
             */
            NSInteger statusCode = [resultObject[statusKey] integerValue];
            
            //验证信息是否匹配
            BOOL transactionCompare = [wSelf compareJsonData:resultObject withTransaction:wSelf.curtTransaction];
            
            if (statusCode == 21007){
                //验证环境反了，重新验证一次
                [wSelf verifyReceiptWithEnvironment:YES transaction:transaction];
                return;
            }
            
            if (statusCode == 0) {
                if (transactionCompare) {
                    if(wSelf.payCompleteCallback){
                        wSelf.payCompleteCallback(orderInfo, KKIPASuccess);
                    }
                } else {
                    if(wSelf.payCompleteCallback){
                        wSelf.payCompleteCallback(orderInfo, KKIPAErrorCodeVerifyReceiptError);
                    }
                }
                
            } else {
                if(wSelf.payCompleteCallback){
                    wSelf.payCompleteCallback(orderInfo, KKIPAErrorCodeVerifyReceiptError);
                }
            }
        }
    }];
}

#pragma mark -- 根据receipt从苹果服务器获取验证数据

- (void)fetchVerifyDataWithEnvironment:(BOOL)sandboxEnvironment
                            receiptStr:(NSString *)receiptStr
                              complete:(void(^)(id resultObject, NSError *error))complete {
    NSError *error = nil;
    NSDictionary *requestContents = @{
                                      @"receipt-data":receiptStr
                                      };
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    
    NSString *verifyReceiptURL = SandboxVerifyReceiptURL;
    if (!sandboxEnvironment) {
        verifyReceiptURL = ProductionVerifyReceiptURL;
    }
    
    // Create a POST request with the receipt data.
    NSURL *storeURL = [NSURL URLWithString:verifyReceiptURL];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    // Make a connection to the iTunes Store on a background queue.
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:storeRequest
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             NSError *error2;
             NSDictionary *jsonResponse;
             if (data) {
                 jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error2];
             }
             if (complete) {
                 complete(jsonResponse,error);
             }
         });
     }];
}

#pragma mark -- SKPaymentTransaction跟apple服务器返回的验证数据比较

- (BOOL)compareJsonData:(NSDictionary*)jsonResponse withTransaction:(SKPaymentTransaction *)payTransaction {
    NSDictionary *receipt = [jsonResponse objectForKey:@"receipt"];
    if (!receipt) {
        return NO;
    }
    
    NSString *appBundleId = [[[NSBundle mainBundle] infoDictionary]objectForKey:@"CFBundleIdentifier"];
    NSString *bundle_id = [receipt objectForKey:@"bundle_id"];
    if (![bundle_id isEqualToString:appBundleId]) {
        return NO;
    }
    
    NSArray *in_app = [receipt objectForKey:@"in_app"];
    if (in_app.count < 1) {
        return NO;
    }
    
    NSString *product_id = nil;
    NSString *transaction_id = nil;
    @autoreleasepool {
        for (NSDictionary *pidDict in in_app) {
            NSString *pid = [pidDict objectForKey:@"product_id"];
            NSString *tid = [pidDict objectForKey:@"original_transaction_id"];
            
            if ([pid isEqualToString:payTransaction.payment.productIdentifier]) {
                product_id = pid;
            }
            if ([tid isEqualToString:payTransaction.transactionIdentifier]) {
                transaction_id = tid;
            }
        }
    }
    
    if (![product_id isEqualToString:payTransaction.payment.productIdentifier]) {
        return NO;
    }
    
    if (![transaction_id isEqualToString:payTransaction.transactionIdentifier]){
        return NO;
    }
    
    return YES;
}

#pragma mark -- 判断是否是沙盒环境

- (BOOL)isSandBoxEnvironment:(SKPaymentTransaction *)payTransaction{
    NSString * transactionReceipt = [[NSString alloc] initWithData:payTransaction.transactionReceipt encoding:NSUTF8StringEncoding];
    NSString *environmentStr = [self processEnvString:transactionReceipt];
    BOOL environment = [environmentStr isEqualToString:@"environment=Sandbox"];
    
    return environment;
}

- (NSString * )processEnvString:(NSString * )str{
    str= [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str=[str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *arr=[str componentsSeparatedByString:@";"];
    
    //存储收据环境的变量
    if (arr.count < 2) {
        return @"inproduct";
    }
    
    NSString * environment = arr[2];
    
    return environment;
}

- (KKIAPOrderInfo *)convertTransaction:(SKPaymentTransaction *)transaction{
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
    
    KKIAPOrderInfo *orderInfo = [KKIAPOrderInfo new];
    orderInfo.transactionId = transaction.transactionIdentifier;
    orderInfo.productId = transaction.payment.productIdentifier;
    orderInfo.userId = transaction.payment.applicationUsername;
    orderInfo.productReceipt = [receiptData base64EncodedStringWithOptions:0];
    orderInfo.isSandboxEnvironment = [self isSandBoxEnvironment:transaction];
    
    return orderInfo;
}

#pragma mark -- @property

- (NSMutableArray<queryProductInfoCallback> *)queryProductCallbacks{
    if(!_queryProductCallbacks){
        _queryProductCallbacks = [NSMutableArray arrayWithCapacity:0];
    }
    return _queryProductCallbacks;
}

- (NSMutableDictionary<NSString *,SKProduct *> *)productInfos{
    if(!_productInfos){
        _productInfos = [NSMutableDictionary new];
    }
    return _productInfos;
}

@end
