//
//  KKVideoManager.h
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import "KKVideoInfo.h"

@class KKMediaAlbumInfo;
@interface KKVideoManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark -- 用户权限

- (KKPhotoAuthorizationStatus )convertStatusWithPHAuthorizationStatus:(PHAuthorizationStatus)PHStatus;

- (KKPhotoAuthorizationStatus)authorizationStatus;

- (void)requestAuthorization:(void (^)(KKPhotoAuthorizationStatus))handler;

#pragma mark -- 初始化相册相关参数,collection 可以是PHAssetCollection对象,也可以是相册id

- (void)initAlbumWithAlbumObj:(NSObject *)collection
                        block:(void(^)(BOOL done ,KKMediaAlbumInfo *albumInfo))hander;

#pragma mark -- 获取系统视频分组的id

- (NSString*)getCameraRollAlbumId;

#pragma mark -- 获取视频分组对应的PHAssetCollection

- (void)getVideoAlbumCollectionWithAlbumId:(NSString *)albumId block:(void(^)(PHAssetCollection *collection))handler;

- (PHAssetCollection *)getCollectionWithAlbumId:(NSString *)albumId;

#pragma mark -- 获取视频分组列表

- (void)getVideoAlbumListWithBlock:(void(^)(NSArray<KKMediaAlbumInfo *>* albumList))handler;

#pragma mark -- 获取视频分组信息

- (KKMediaAlbumInfo *)getAlbumInfoWithPHAssetCollection:(PHAssetCollection *)collection;

#pragma mark -- 获取所有的视频信息

- (void)getVideoInfoListWithBlock:(void(^)(BOOL , NSArray<KKVideoInfo *>* infoArray))handler;

#pragma mark -- 根据索引获取视频信息

- (void)getVideoInfoWithIndex:(NSInteger)index block:(void(^)(BOOL done , KKVideoInfo *videoInfo))handler;

#pragma mark -- 根据视频id获取视频信息

- (void)getVideoInfoWithIdentifier:(NSString *)identifier block:(void(^)(BOOL done , KKVideoInfo *videoInfo))handler;

- (void)getVideoInfoWithIdentifierArrat:(NSArray *)identifierArray block:(void(^)(BOOL done , NSArray<KKVideoInfo *> *videoInfos))handler;

#pragma mark -- 根据PHAsset获取视频信息

- (void)getVideoInfoWithAsset:(PHAsset *)asset
                        index:(NSInteger)index
                        block:(void(^)(BOOL done , KKVideoInfo *videoInfo))handler;

- (void)getVideoInfoWithAsset:(PHAsset *)asset
                        block:(void(^)(BOOL done , KKVideoInfo *videoInfo))handler;

#pragma mark -- 获取指定索引范围的视频信息

- (void)getVideoInfoListWithFetchRange:(NSRange )range block:(void(^)(BOOL done , NSArray<KKVideoInfo *>* videoList))handler;

#pragma mark -- 根据视频分组id、视频标识符(索引、PHAsset、视频id)获取视频信息

- (void)getVideoInfoWithAlbumID:(NSString *)albumId
                       searchId:(id)searchId
                           sort:(NSComparisonResult)comparison
                          Block:(void(^)(BOOL done , KKVideoInfo* videoInfo))handler;

#pragma mark -- 获取视频的缩略图

- (void)getVideoCorverWithIndex:(NSInteger)index
                  needImageSize:(CGSize)size
                 isNeedDegraded:(BOOL)degraded
                          block:(void(^)(KKVideoInfo *videoInfo))handler;

- (void)getVideoCorverWithLocalIdentifier:(NSString *)localIdentifier
                            needImageSize:(CGSize)size
                           isNeedDegraded:(BOOL)degraded
                                    block:(void(^)(KKVideoInfo *videoInfo))handler;

#pragma mark -- 添加

- (void)addVideoToAlbumWithFilePath:(NSString *)filePath albumId:(NSString *)albumId block:(void(^)(BOOL,KKVideoInfo *))block;

- (void)addVideoFilesToAlbumWithFilePaths:(NSArray *)filePaths albumId:(NSString *)albumId block:(void(^)(BOOL,NSArray *))block;

#pragma mark -- 删除

- (void)deleteVideoWithIndexArray:(NSArray*)indexArray block:(void(^)(BOOL suc))handler;

- (void)deleteVideoWithIdentifierArray:(NSArray*)indentiferArray block:(void(^)(BOOL suc))handler;

@end
