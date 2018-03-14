//
//  KKPhotoManager.h
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "KKPhotoDateGroup.h"
#import "KKMediaAlbumInfo.h"
#import "KKPhotoInfo.h"

@interface KKPhotoManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark -- 清理

- (void)clear;

#pragma mark -- 用户权限

- (KKPhotoAuthorizationStatus )convertStatusWithPHAuthorizationStatus:(PHAuthorizationStatus)PHStatus;

- (KKPhotoAuthorizationStatus)authorizationStatus;

- (void)requestAuthorization:(void (^)(KKPhotoAuthorizationStatus))handler;

#pragma mark -- 获取相机胶卷相册(主相册)的id

- (NSString*)getCameraRollAlbumId;

#pragma mark -- 相片是否选择

- (BOOL)checkSelStateWithIdentifier:(NSString *)identifier;

#pragma mark -- 加载相机胶卷(主相册)中的相片,按相片的创建日期分组

- (void)loadCameraRollWithComparison:(NSComparisonResult)comparison
                               block:(void(^)(NSArray<KKPhotoDateGroup*> *result))handler;

- (void)loadCameraRollWithComparison:(NSComparisonResult)comparison
                      withDateFormat:(KKDateFormat)dataFormat
                               block:(void(^)(NSArray<KKPhotoDateGroup*> *result))handler;

#pragma mark -- 重置相册的PHAssetCollection及其对应的相片资源

- (void)resetCollectionWithAlbumId:(NSString *)albumId;

#pragma mark -- 初始化相册相关参数,collection 可以是PHAssetCollection对象,也可以是相册id

- (void)initAlbumWithAlbumObj:(NSObject *)collection
                        block:(void(^)(BOOL done ,KKMediaAlbumInfo *albumInfo))hander;

#pragma mark -- 加载某个相册中的相片,按相片的创建日期分组

- (void)getAlbumImageWithComparison:(NSComparisonResult)comparison
                           albumObj:(NSObject *)collection
                     withDateFormat:(KKDateFormat)dataFormat
                              block:(void(^)(NSArray<KKPhotoDateGroup*> *result))handler;

#pragma mark -- 创建相册

-(NSString *)createAlbumIfNeedWithName:(NSString *)name;

#pragma mark -- 图片缩略图获取，albumCollection和albumAssets在调用之前必须先初始化

//取消所有的图片拉取工作
- (void)cancelAllThumbnailTask;

- (void)getThumbnailImageWithIndex:(NSInteger)index
                     needImageSize:(CGSize)size
                    isNeedDegraded:(BOOL)degraded
                             block:(void(^)(KKPhotoInfo *item))handler;

- (void)getThumbnailImageWithAlbumAsset:(PHFetchResult *)assetsResult
                                  index:(NSInteger)index
                          needImageSize:(CGSize)size
                         isNeedDegraded:(BOOL)degraded
                                  block:(void(^)(KKPhotoInfo *item))handler;

#pragma mark -- 根据索引获取全屏显示的照片，注意，在照片的尺寸特别大的情况下，加载原图会导致内存暴增而崩溃(原因不明)，需要重新调整获取图片的大小

- (void)getDisplayImageWithIndex:(NSInteger)index
                   needImageSize:(CGSize)size
                  isNeedDegraded:(BOOL)degraded
                           block:(void (^)(KKPhotoInfo *item))handler;

#pragma mark -- 根据相片id获取全屏显示的照片，注意，在照片的尺寸特别大的情况下，加载原图会导致内存暴增而崩溃(原因不明)，需要重新调整获取图片的大小

- (void)getDisplayImageWithIdentifier:(NSString *)identifier
                        needImageSize:(CGSize)size
                       isNeedDegraded:(BOOL)degraded
                                block:(void (^)(KKPhotoInfo *item))handler;

#pragma mark - 获取PHAssetCollection 句柄

- (PHAssetCollection *)getAlbumCollectionWithAlbumId:(NSString *)albumId;

- (void)getAlbumCollectionWithAlbumId:(NSString *)albumId block:(void(^)(PHAssetCollection *collection))callback;

#pragma mark -- 获取相册列表信息

- (void)getImageAlbumList:(void (^)(NSArray<KKMediaAlbumInfo*> *))handler;

#pragma mark -- 相册相关信息

- (KKMediaAlbumInfo *)getAlbumInfoWithPHAssetCollection:(PHAssetCollection *)collection;

#pragma mark -- 根据相册的id，获取全部图片的id

- (void)getAlbumImageIdentifierWithAlbumId:(NSString *)albumId sort:(NSComparisonResult)comparison block:(void(^)(NSArray *array))handler;

#pragma mark -- 根据相册id和图片索引获取图片

- (void)getImageWithAlbumID:(NSString *)albumID
                      index:(NSInteger)index
              needImageSize:(CGSize)size
             isNeedDegraded:(BOOL)degraded
                       sort:(NSComparisonResult)comparison
                      block:(void (^)(KKPhotoInfo *item))handler;

#pragma mark -- 根据相片的PHAsset获取图片

- (void)getImageWithAsset:(PHAsset *)asset
            needImageSize:(CGSize)size
           isNeedDegraded:(BOOL)degraded
                    block:(void (^)(KKPhotoInfo *item))handler;

#pragma mark -- 根据相册id和图片id获取图片

- (void)getImageWithAlbumID:(NSString *)albumID
       imageLocalIdentifier:(NSString *)localIdentifier
              needImageSize:(CGSize)size
             isNeedDegraded:(BOOL)degraded
                       sort:(NSComparisonResult)comparison
                      block:(void (^)(KKPhotoInfo *item))handler;

#pragma mark -- 根据相册的id，获取指定图片id的图片的PHAsset

- (void)getImageAssetWithAlbumID:(NSString *)albumID
            imageIdentifierArray:(NSArray *)identifierArray
                           block:(void(^)(NSArray *))handler;

#pragma mark -- 同步模式，根据相册id，图片索引，获取图片数据

- (KKPhotoInfo *)sycGetImageInfoWithAlbumID:(NSString *)albumId
                                      index:(NSInteger)index
                                       sort:(NSComparisonResult)comparison;

- (NSArray<KKPhotoInfo *>*)sycGetImageInfoWithAlbumID:(NSString *)albumId
                                           indexArray:(NSArray *)indexArray
                                                 sort:(NSComparisonResult)comparison;

- (void)sycGetImageDataWithAlbumID:(NSString *)albumID
                             index:(NSInteger)index
                              sort:(NSComparisonResult)comparison
                             block:(void(^)(KKPhotoInfo *item))handler;

//反向获取图片数据
- (NSArray<KKPhotoInfo *>*)sycReverseGetImageInfoWithAlbumID:(NSString *)albumId
                                                  indexArray:(NSArray *)indexArray
                                                        sort:(NSComparisonResult)comparison;

#pragma mark -- 同步模式，根据相册id，图片id，获取图片数据

- (NSArray<KKPhotoInfo *>*)sycGetImageInfoWithAlbumId:(NSString *)albumId identifierArray:(NSArray *)identifierArray;

#pragma mark -- 获取相片的数据(NSData),以数组方式返回

- (void)getImageDataListWithAlbumID:(NSString *)albumID
                         fetchRange:(NSRange)range
                               sort:(NSComparisonResult)comparison
                              block:(void(^)(NSArray<KKPhotoInfo *> *imageList))handler;

#pragma mark -- 根据相册id、相片asset 获取图片的NSData

- (void)getImageDataWithAlbumId:(NSString *)albumId
                          asset:(PHAsset *)asset
                          block:(void(^)(KKPhotoInfo *item))handler;

#pragma mark -- 根据相册id、相片标识(相片索引、相片id，相片的PHAsset对象)获取图片的NSData

- (void)getImageDataWithAlbumID:(NSString *)albumID
                       searchID:(id)searchID
                           sort:(NSComparisonResult)comparison
                          block:(void(^)(KKPhotoInfo *item))handler;

#pragma mark -- 根据相册id，图片id，获取图片数据(NSData)

- (void)getImageDataWithAlbumID:(NSString *)albumID
           imageLocalIdentifier:(NSString *)localIdentifier
                           sort:(NSComparisonResult)comparison
                          block:(void(^)(KKPhotoInfo *item))handler;

- (void)getImageDataWithAlbumID:(NSString *)albumID
           imageLocalIdentifier:(NSString *)localIdentifier
                           sort:(NSComparisonResult)comparison
                           sync:(BOOL)sync
                          block:(void(^)(KKPhotoInfo *item))handler;

#pragma mark -- 根据相册id，图片索引，获取图片数据(NSData)

- (void)getImageDataWithAlbumID:(NSString *)albumID
                          index:(NSInteger)index
                           sort:(NSComparisonResult)comparison
                          block:(void (^)(KKPhotoInfo *item))handler;

#pragma mark- 删除或移除照片

- (void)deleteImageWithAlbumId:(NSString*)albumId
             imageLocalIdArray:(NSArray *)localIdArray
                         block:(void(^)(BOOL suc))handler;

- (void)deleteImageWithAlbumId:(NSString*)albumId
                    indexArray:(NSArray*)indexArray
                          sort:(NSComparisonResult)comparison
                         block:(void(^)(bool suc))handler;

#pragma mark- 图片添加

- (void)addImageToAlbumWithImage:(UIImage *)image
                         albumId:(NSString *)albumId
                         options:(PHImageRequestOptions *)options
                           block:(void(^)(KKPhotoInfo *))block;

- (void)addImageFilesToAlbumWithImages:(NSArray *)imageFiles
                               albumId:(NSString *)albumId
                               options:(PHImageRequestOptions *)options
                                 block:(void(^)(NSArray *))block;

//可用于保存gif图
- (void)addImageData:(NSData *)data
           toAlbumId:(NSString *)albumId
               block:(void(^)(BOOL suc))block;

@end
