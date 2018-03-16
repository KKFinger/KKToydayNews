//
//  KKFetchNewsTool.h
//  KKToydayNews
//
//  Created by finger on 2017/9/3.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKSectionItem.h"
#import "KKArticleModal.h"
#import "KKSummaryDataModel.h"
#import "KKWTTDetailModel.h"
#import "KKPersonalModel.h"
#import "KKDongTaiModel.h"
#import "KKPersonalWenDaModel.h"
#import "KKPersonalArticalModel.h"

@interface KKFetchNewsTool : NSObject

+ (instancetype)shareInstance;

/**
 获取/更新用户感兴趣的板块数据
 对应模型 KKSectionItem
 @param catagory 板块对应的Catagory
 @param modify 获取 NO 更新 YES
 @param success success description
 @param failure failure description
 */
- (void)fetchFavoriteSectionWithCatagorys:(NSArray *)catagory
                                   modify:(BOOL)modify
                                  success:(void(^)(NSArray<KKSectionItem *> *itemArray))success
                                  failure:(void (^)(NSError *error))failure;

//获取推荐的板块数据  对应模型 KKSectionItem
- (void)fetchRecomonSectionWithSuccess:(void(^)(NSArray<KKSectionItem *> *itemArray))success
                               failure:(void (^)(NSError *error))failure;

//获取西瓜板块的catagory数据  对应模型 KKSectionItem
- (void)fetchXiGuaSectionWithSuccess:(void(^)(NSArray<KKSectionItem *> *itemArray))success
                             failure:(void (^)(NSError *error))failure;

//获取新闻简介数据  对应模型 KKSummaryDataodel
- (void)fetchSummaryWithSectionItem:(KKSectionItem *)secItem
                            success:(void(^)(KKSummaryDataModel *modal))success
                            failure:(void (^)(NSError *error))failure;

//获取新闻详情数据 对应模型 KKArticleModal
- (void)fetchDetailNewsWithCatagory:(NSString *)catagoryStr
                            groupId:(NSString *)groupId
                             itemId:(NSString *)itemId
                            success:(void(^)(KKArticleModal *modal))success
                            failure:(void (^)(NSError *error))failure;

//获取新闻评论数据 对应模型 KKCommentModal
- (void)fetchCommentWithCatagory:(NSString *)category
                         groupId:(NSString *)groupId
                          itemId:(NSString *)itemId
                          offset:(NSInteger)offset
                       sortIndex:(NSInteger)sortIndex//段子评论的排序，0,热门,1,最新
                         success:(void(^)(KKCommentModal *modal))success
                         failure:(void (^)(NSError *error))failure;

//获取个人评论详情 对应模型KKUserCommentDetail
- (void)fetchPersonalCommentWithCommentId:(NSString *)commentId
                                  success:(void(^)(KKUserCommentDetail *modal))success
                                  failure:(void (^)(NSError *error))failure;

//获取个人评论的全部回复 对应模型KKCommentReply
- (void)fetchReplyWithCommentId:(NSString *)commentId
                         offset:(NSInteger)offset
                        success:(void(^)(KKCommentReply *modal))success
                        failure:(void (^)(NSError *error))failure;

//获取个人评论的点赞数据 对应模型KKCommentDigg
- (void)fetchCommentDiggWithCommentId:(NSString *)commentId
                               offset:(NSInteger)offset
                                count:(NSInteger)count
                              success:(void(^)(KKCommentDigg *modal))success
                              failure:(void (^)(NSError *error))failure;

//获取视频的播放信息  对应模型KKVideoPlayInfo
- (void)fetchVideoInfoWithVideoId:(NSString *)videoId
                          success:(void(^)(KKVideoPlayInfo *modal))success
                          failure:(void (^)(NSError *error))failure;

//获取微头条详情信息
- (void)fetchWTTDetailInfoWithThreadId:(NSString *)threadId
                               success:(void(^)(KKWTTDetailModel *modal))success
                               failure:(void (^)(NSError *error))failure;

//获取微头条评论数据
- (void)fetchWTTCommentWithModal:(KKWTTDetailModel *)model
                          offset:(NSInteger)offset
                         success:(void(^)(KKCommentModal *modal))success
                         failure:(void (^)(NSError *error))failure;

//获取个人主页信息
- (void)fetchPersonalInfoWithUserId:(NSString *)userId
                            success:(void(^)(KKPersonalModel *modal))success
                            failure:(void (^)(NSError *error))failure;

//获取个人主页动态信息
- (void)fetchPersonalDongTaiInfoWithUserId:(NSString *)userId
                                    cursor:(NSString *)cursor
                                   success:(void(^)(KKDongTaiModel *modal))success
                                   failure:(void (^)(NSError *error))failure;

//获取个人主页问答信息
- (void)fetchPersonalWengDaWithUserId:(NSString *)userId
                               cursor:(NSString *)cursor
                              success:(void(^)(KKPersonalWenDaModel *modal))success
                              failure:(void (^)(NSError *error))failure;

/**
 获取个人主页文章、视频信息
 
 @param pageType 1 文章 0 视频
 @param behotTime 分页标志
 @param userId userId
 @param mediaId mediaId
 @param success success description
 @param failure failure descriptio
 */
- (void)fetchPersonalArticalWithPageType:(NSInteger)pageType
                               behotTime:(NSString *)behotTime
                                  userId:(NSString *)userId
                                mediaId:(NSString *)mediaId
                              success:(void(^)(KKPersonalArticalModel *modal))success
                              failure:(void (^)(NSError *error))failure;

@end
