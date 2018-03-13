//
//  KKNetworkTool.m
//  KKToydayNews
//
//  Created by finger on 2017/9/3.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKNetworkTool.h"

@implementation KKNetworkTool

+ (instancetype)shareInstance{
    static KKNetworkTool *netTool = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netTool = [[self alloc] init];
    });
    return netTool;
}

+(void)cancelAllOperations{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.operationQueue cancelAllOperations];
}

#pragma mark -- GET请求

/**
 *  GET请求,有固定的请求头
 */
- (void)get:(NSString *)url
      value:(NSString *)value
httpHeaderField:(NSString *)httpHeaderField
 parameters:(NSDictionary *)parameters
    success:(void (^)(id result))success
    failure:(void (^)(NSError *error))failure{
    //断言
    NSAssert(url != nil, @"url不能为空");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
    manager.requestSerializer.timeoutInterval = 10;
    
    [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        NSDictionary *result = nil;
        NSData *jsonData = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            result = responseObject;
        } else if ([responseObject isKindOfClass:[NSString class]]) {
            jsonData = [(NSString *)responseObject dataUsingEncoding : NSUTF8StringEncoding];
        } else if ([responseObject isKindOfClass:[NSData class]]) {
            jsonData = responseObject;
        }
        if (jsonData) {
            result = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
            if (![result isKindOfClass:[NSDictionary class]]) result = nil;
        }
        if (success) success(result);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        if (failure) failure(error);
    }];
}

/**
 *  GET请求
 */
- (void)get:(NSString *)url
 parameters:(NSDictionary *)parameters
    success:(void (^)(id))success
    failure:(void (^)(NSError *))failure{
    
    NSAssert(url != nil, @"url不能为空");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        NSDictionary *result = nil;
        NSData *jsonData = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            result = responseObject;
        } else if ([responseObject isKindOfClass:[NSString class]]) {
            jsonData = [(NSString *)responseObject dataUsingEncoding : NSUTF8StringEncoding];
        } else if ([responseObject isKindOfClass:[NSData class]]) {
            jsonData = responseObject;
        }
        if (jsonData) {
            result = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
            if (![result isKindOfClass:[NSDictionary class]]) result = nil;
        }
        if (success) success(result);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        if (failure) failure(error);
    }];
}

/**
 *  GET请求,带有进度值
 */
- (void)get:(NSString *)url
 parameters:(NSDictionary *)parameters
   progress:(downloadProgress)progress
    success:(success)success
    failure:(failure)failure{
    
    NSAssert(url != nil, @"url不能为空");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
    
    //使用AFNetworking进行网络请求
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    //发起get请求
    [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        double progressValue = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        if (progress) progress(downloadProgress, progressValue);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        NSDictionary *result = nil;
        NSData *jsonData = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            result = responseObject;
        } else if ([responseObject isKindOfClass:[NSString class]]) {
            jsonData = [(NSString *)responseObject dataUsingEncoding : NSUTF8StringEncoding];
        } else if ([responseObject isKindOfClass:[NSData class]]) {
            jsonData = responseObject;
        }
        if (jsonData) {
            result = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
            if (![result isKindOfClass:[NSDictionary class]]) result = nil;
        }
        if (success) success(result);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        if (failure) failure(error);
    }];
}

/**
 *  POST请求
 */
- (void)post:(NSString *)url
  parameters:(NSDictionary *)parameters
     success:(void (^)(id))success
     failure:(void (^)(NSError *))failure{
    
    //断言
    NSAssert(url != nil, @"url不能为空");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        NSDictionary *result = nil;
        NSData *jsonData = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            result = responseObject;
        } else if ([responseObject isKindOfClass:[NSString class]]) {
            jsonData = [(NSString *)responseObject dataUsingEncoding : NSUTF8StringEncoding];
        } else if ([responseObject isKindOfClass:[NSData class]]) {
            jsonData = responseObject;
        }
        if (jsonData) {
            result = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
            if (![result isKindOfClass:[NSDictionary class]]) result = nil;
        }
        if (success) success(result);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        if (failure) failure(error);
    }];
}

/**
 *  向服务器上传文件
 */
-(void)post:(NSString *)url
  parameter:(NSDictionary *)parameters
       data:(NSData *)fileData
  fieldName:(NSString *)fieldName
   fileName:(NSString *)fileName
   mimeType:(NSString *)mimeType
    success:(void (^)(id))success
   progress:(void(^)(NSProgress *uploadProgress,double progressValue))progress
    failure:(void (^)(NSError *))failure{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"multipart/form-data", @"application/json", @"text/html", @"image/jpeg", @"image/png", @"application/octet-stream", @"text/json", nil];
    
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:fileData name:fieldName fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        double progressValue = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
        if (progress) progress(uploadProgress, progressValue);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        NSDictionary *result = nil;
        NSData *jsonData = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            result = responseObject;
        } else if ([responseObject isKindOfClass:[NSString class]]) {
            jsonData = [(NSString *)responseObject dataUsingEncoding : NSUTF8StringEncoding];
        } else if ([responseObject isKindOfClass:[NSData class]]) {
            jsonData = responseObject;
        }
        if (jsonData) {
            result = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
            if (![result isKindOfClass:[NSDictionary class]]) result = nil;
        }
        if (success) success(result);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        //通过block,将错误信息回传给用户
        if (failure) failure(error);
    }];
}

/**
 *  NSData上传文件
 */
- (void)updataDataWithRequestStr:(NSString *)str
                        fromData:(NSData *)fromData
                        progress:(void(^)(NSProgress *uploadProgress))progress
                      completion:(void(^)(id object,NSError *error))completion{
    
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager uploadTaskWithRequest:request fromData:fromData progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) progress(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completion) completion(responseObject,error);
    }];
}


/**
 *  NSURL上传文件
 */
- (void)updataFileWithRequestStr:(NSString *)str
                        fromFile:(NSURL *)fromUrl
                        progress:(void(^)(NSProgress *uploadProgress))progress
                      completion:(void(^)(id object,NSError *error))completion{
    
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager uploadTaskWithRequest:request fromFile:fromUrl progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) progress(uploadProgress);
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (completion) completion(responseObject,error);
    }];
}

/**
 *  下载文件
 */
- (void)downloadFileWithRequestUrl:(NSString *)url
                          complete:(void (^)(NSURL *filePath, NSError *error))complete
                          progress:(void (^)(id downloadProgress, double currentValue))progress{
    
    NSString *urlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        double progressValue = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        if (progress) {
            progress(downloadProgress,progressValue);
        }
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return documentsDirectoryURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (complete) {
            complete(filePath,error);
        }
    }];
    [downloadTask resume];
}


/**
 *  下载文件
 */
- (void)downloadFileWithRequestUrl:(NSString *)url
                         parameter:(NSDictionary *)patameter
                          complete:(void (^)(NSData *data, NSURL *filePath, NSError *error))complete
                          progress:(void (^)(id downloadProgress, double currentValue))progress{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    });
    
    //默认配置
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSString *urlString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    //AFN3.0URLSession的句柄
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    //下载Task操作
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        double progressValue = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        if (progress) progress(downloadProgress, progressValue);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return documentsDirectoryURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        NSData *data;
        if (!error) {
            data = [NSData dataWithContentsOfURL:filePath];
        }
        if (complete) complete(data, filePath,error);
    }];
    [downloadTask resume];
}


/**
 *   监听网络状态的变化
 */
+ (void)checkingNetworkResult:(void (^)(KKNetworkStatus))result {
    
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager startMonitoring];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusUnknown) {
            if (result) result(KKNetworkStatusUnknown);
        }else if (status == AFNetworkReachabilityStatusNotReachable){
            if (result) result(KKNetworkStatusNotReachable);
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            if (result) result(KKNetworkStatusReachableViaWWAN);
        }else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            if (result) result(KKNetworkStatusReachableViaWiFi);
        }
    }];
}

@end
