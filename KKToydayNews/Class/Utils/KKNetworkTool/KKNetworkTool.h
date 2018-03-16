//
//  KKNetworkTool.h
//  KKToydayNews
//
//  Created by finger on 2017/9/3.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  请求\下载进度
 *
 *  @param downloadProgress 总大小值
 *  @param currentValue     计算后的当前进度值
 */
typedef void (^downloadProgress)(NSProgress *downloadProgress, double currentValue);

/**
 *  请求成功
 */
typedef void (^success)(id success);

/**
 *  请求失败
 */
typedef void (^failure)(NSError *failure);

/**
 *  请求结果
 */
typedef void (^requestResult)(success,failure);


@interface KKNetworkTool : NSObject

@property (nonatomic, assign) KKNetworkStatus netStatus;
@property (nonatomic, strong) NSOutputStream *outputStream;

+ (instancetype)shareInstance;

/**取消所有网络请求*/
+ (void)cancelAllOperations;

/**网络状态*/
+ (void)checkingNetworkResult:(void(^)(KKNetworkStatus status))result;

/**
 *  GET请求,设置固定的请求头
 *
 *  @param url              请求接口
 *  @param value            values
 *  @param httpHeaderField  key
 *  @param parameters       向服务器请求时的参数
 *  @param success          请求成功，block的参数为服务返回的数据
 *  @param failure          请求失败，block的参数为错误信息
 */
- (void)get:(NSString *)url
      value:(NSString *)value
httpHeaderField:(NSString *)httpHeaderField
 parameters:(NSDictionary *)parameters
    success:(void (^)(id result))success
    failure:(void (^)(NSError *error))failure;

/**
 *  GET请求
 *
 *  @param url        请求接口
 *  @param parameters 向服务器请求时的参数
 *  @param success    请求成功，block的参数为服务返回的数据
 *  @param failure    请求失败，block的参数为错误信息
 */
- (void)get:(NSString *)url
 parameters:(NSDictionary *)parameters
    success:(void(^)(id responseObject))success
    failure:(void (^)(NSError *error))failure;


/**
 *  GET请求,带有进度值
 *
 *  @param url        请求接口
 *  @param parameters 请求参数
 *  @param progress   请求/下载进度值：
 *  @param success    请求成功，block的参数为服务返回的数据
 *  @param failure    请求失败，block的参数为错误信息
 */
- (void)get:(NSString *)url
 parameters:(NSDictionary *)parameters
   progress:(downloadProgress)progress
    success:(success)success
    failure:(failure)failure;


/**
 *  POST请求
 *
 *  @param url        要提交的数据结构
 *  @param parameters 要提交的数据
 *  @param success    成功执行，block的参数为服务器返回的内容
 *  @param failure    执行失败，block的参数为错误信息
 */
- (void)post:(NSString *)url
  parameters:(NSDictionary *)parameters
     success:(void(^)(id responseObject))success
     failure:(void(^)(NSError *error))failure;

/**
 *  向服务器上传文件
 *
 *  @param url       要上传的文件接口
 *  @param parameters 上传的参数
 *  @param fileData  上传的文件\数据
 *  @param fieldName 服务对应的字段
 *  @param fileName  上传到时服务器的文件名
 *  @param mimeType  上传的文件类型
 *  @param success   成功执行，block的参数为服务器返回的内容
 *  @param progress  进度
 *  @param failure   执行失败，block的参数为错误信息
 */
-(void)post:(NSString *)url
  parameter:(NSDictionary *)parameters
       data:(NSData *)fileData
  fieldName:(NSString *)fieldName
   fileName:(NSString *)fileName
   mimeType:(NSString *)mimeType
    success:(void (^)(id))success
   progress:(void(^)(NSProgress *uploadProgress,double progressValue))progress
    failure:(void (^)(NSError *))failure;

/**
 *  下载文件
 *
 *  @param url            下载地址
 *  @param complete       下载结束：成功返回文件路径
 *  @param progress       设置进度条的百分比：progressValue
 */
- (void)downloadFileWithRequestUrl:(NSString *)url
                          complete:(void (^)(NSURL *filePath, NSError *error))complete
                          progress:(void (^)(id downloadProgress, double currentValue))progress;


/**
 *  下载文件
 *
 *  @param url       下载地址
 *  @param patameter 下载参数
 *  @param complete  下载成功返回文件：NSData
 *  @param progress  设置进度条的百分比：progressValue
 */
- (void)downloadFileWithRequestUrl:(NSString *)url
                         parameter:(NSDictionary *)patameter
                          complete:(void (^)(NSData *data, NSURL *filePath, NSError *error))complete
                          progress:(void (^)(id downloadProgress, double currentValue))progress;


/**
 *  NSData上传文件
 *
 *  @param str        目标地址
 *  @param fromData   文件源
 *  @param progress   实时进度回调
 *  @param completion 完成结果
 */
- (void)updataDataWithRequestStr:(NSString *)str
                        fromData:(NSData *)fromData
                        progress:(void(^)(NSProgress *uploadProgress))progress
                      completion:(void(^)(id object,NSError *error))completion;


/**
 *  NSURL上传文件
 *
 *  @param str        目标地址
 *  @param fromUrl    文件源
 *  @param progress   实时进度回调
 *  @param completion 完成结果
 */
- (void)updataFileWithRequestStr:(NSString *)str
                        fromFile:(NSURL *)fromUrl
                        progress:(void(^)(NSProgress *uploadProgress))progress
                      completion:(void(^)(id object,NSError *error))completion;

@end
