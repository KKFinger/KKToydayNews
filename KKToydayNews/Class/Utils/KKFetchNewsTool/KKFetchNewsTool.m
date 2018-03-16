//
//  KKFetchNewsTool.m
//  KKToydayNews
//
//  Created by finger on 2017/9/3.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKFetchNewsTool.h"
#import "KKNetworkTool.h"
#import "KKCommonDevice.h"
#import "KKLocation.h"

@interface KKFetchNewsTool ()
@property(nonatomic)dispatch_queue_t fetchDataQueue;
@end

@implementation KKFetchNewsTool

+ (instancetype)shareInstance{
    static KKFetchNewsTool *dataTool = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataTool = [[self alloc] init];
    });
    return dataTool;
}

/**
 获取/更新用户感兴趣的板块数据
 对应模型 KKSectionItem
 @param catagoryArray 板块对应的Catagory
 @param modify 获取 NO 更新 YES
 @param success success description
 @param failure failure description
 */
- (void)fetchFavoriteSectionWithCatagorys:(NSArray *)catagoryArray
                                   modify:(BOOL)modify
                                  success:(void(^)(NSArray<KKSectionItem *> *itemArray))success
                                  failure:(void (^)(NSError *error))failure
{
    dispatch_async(self.fetchDataQueue, ^{
//        if([KKLocation locationStatus]){
//            NSInteger count = 0 ;
//            while (![KKLocation shareInstance].curtCity.length && count <= 3) {
//                usleep(1 * 1000 * 1000);
//                count ++ ;
//            }
//        }
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://lf.snssdk.com/article/category/get_subscribed/v2/?version_code=6.3.4&aid=13&app_name=news_article&channel=App Store&device_platform=iphone&ssmix=a&ab_client=a1,f2,f7,e1"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
//        NSString *city = [KKLocation shareInstance].curtCity;
//        if(!city.length){
//            city = @"";
//        }
        
        NSString *modifyStr = @"0";
        if(modify){
            modifyStr = @"1";
        }
        
//        NSString *latitude = [KKLocation shareInstance].latitude;
//        if(!latitude.length){
//            latitude = @"";
//        }
//        NSString *longitude = [KKLocation shareInstance].longitude;
//        if(!longitude.length){
//            longitude = @"";
//        }
//        if(![KKLocation locationStatus]){
//            city = @"";
//            latitude = @"";
//            longitude = @"";
//        }
        
        NSString *catagoryStr = [catagoryArray mj_JSONString];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",/*city,@"city",city,@"server_city",*/os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",KKIdfa,@"idfa",catagoryStr,@"categories",modifyStr ,@"user_modify",/*latitude,@"latitude",longitude,@"longitude",*/nil];
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKFavSecFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            if(responseObject && ![responseObject isKindOfClass:[NSNull class]]){
                NSDictionary *data = responseObject[@"data"];
                NSArray *itemArray = data[@"data"];
                if(itemArray.count && ![itemArray isKindOfClass:[NSNull class]]){
                    NSMutableArray *array = [NSMutableArray new];
                    for(NSDictionary *dic in itemArray){
                        KKSectionItem *item = [KKSectionItem mj_objectWithKeyValues:dic];
                        [array safeAddObject:item];
                    }
                    if(success){
                        success(array);
                    }
                }else{
                    if(success){
                        success(nil);
                    }
                }
            }else{
                if(success){
                    success(nil);
                }
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取推荐的板块数据  对应模型 KKSectionItem
- (void)fetchRecomonSectionWithSuccess:(void(^)(NSArray<KKSectionItem *> *itemArray))success
                               failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
//        if([KKLocation locationStatus]){
//            NSInteger count = 0 ;
//            while (![KKLocation shareInstance].curtCity.length && count <= 3) {
//                usleep(1 * 1000 * 1000);
//                count ++ ;
//            }
//        }
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://lf.snssdk.com/article/category/get_extra/v1/?version_code=6.3.4&app_name=news_article&channel=App Store&aid=13&ab_feature=z2&ab_group=z2&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",KKIdfa,@"idfa",nil];
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKRecommonSecFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            if(responseObject && ![responseObject isKindOfClass:[NSNull class]]){
                NSDictionary *data = responseObject[@"data"];
                NSArray *itemArray = data[@"data"];
                if(itemArray.count && ![itemArray isKindOfClass:[NSNull class]]){
                    NSMutableArray *array = [NSMutableArray new];
                    for(NSDictionary *dic in itemArray){
                        KKSectionItem *item = [KKSectionItem mj_objectWithKeyValues:dic];
                        [array safeAddObject:item];
                    }
                    if(success){
                        success(array);
                    }
                }else{
                    if(success){
                        success(nil);
                    }
                }
                
            }else{
                if(success){
                    success(nil);
                }
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取西瓜板块的catagory数据  对应模型 KKSectionItem
- (void)fetchXiGuaSectionWithSuccess:(void(^)(NSArray<KKSectionItem *> *itemArray))success
                             failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
//        if([KKLocation locationStatus]){
//            NSInteger count = 0 ;
//            while (![KKLocation shareInstance].curtCity.length && count <= 3) {
//                usleep(1 * 1000 * 1000);
//                count ++ ;
//            }
//        }
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://lf.snssdk.com/article/category/get_subscribed/v2/?version_code=6.3.4&aid=13&app_name=news_article&channel=App Store&device_platform=iphone&ssmix=a&ab_client=a1,f2,f7,e1"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
//        NSString *city = [KKLocation shareInstance].curtCity;
//        if(!city.length){
//            city = @"";
//        }
        
//        NSString *latitude = [KKLocation shareInstance].latitude;
//        if(!latitude.length){
//            latitude = @"";
//        }
//        NSString *longitude = [KKLocation shareInstance].longitude;
//        if(!longitude.length){
//            longitude = @"";
//        }
//        if(![KKLocation locationStatus]){
//            city = @"";
//            latitude = @"";
//            longitude = @"";
//        }
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",/*city,@"city",city,@"server_city",*/os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",KKIdfa,@"idfa",/*latitude,@"latitude",longitude,@"longitude",*/nil];
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKXiGuaCatagoryFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            if(responseObject && ![responseObject isKindOfClass:[NSNull class]]){
                NSArray *itemArray = responseObject[@"data"];
                if(itemArray.count && ![itemArray isKindOfClass:[NSNull class]]){
                    NSMutableArray *array = [NSMutableArray new];
                    for(NSDictionary *dic in itemArray){
                        KKSectionItem *item = [KKSectionItem mj_objectWithKeyValues:dic];
                        [array safeAddObject:item];
                    }
                    if(success){
                        success(array);
                    }
                }else{
                    if(success){
                        success(nil);
                    }
                }
            }else{
                if(success){
                    success(nil);
                }
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取新闻简介数据  对应模型 KKCommonDataModel
- (void)fetchSummaryWithSectionItem:(KKSectionItem *)secItem
                            success:(void(^)(KKSummaryDataModel *modal))success
                            failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
//        if([KKLocation locationStatus]){
//            NSInteger count = 0 ;
//            while (![KKLocation shareInstance].curtCity.length && count <= 3) {
//                usleep(1 * 1000 * 1000);
//                count ++ ;
//            }
//        }
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSString *catagory = secItem.category ;
        NSString *concernId = secItem.concern_id;
        if(!catagory.length){
            catagory = @"";
        }
        if(!concernId.length){
            concernId = @"";
        }
        
        NSDictionary *parameters = [self getURLParameters:@"https://lf.snssdk.com/api/news/feed/v64/?version_code=6.3.4&app_name=news_article&channel=App%20Store&aid=13&ab_feature=z1&live_sdk_version=1.6.5&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1&count=20&cp=5497A7Ce13240q1&detail=1&image=1&loc_mode=1&refer=1&strict=0"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *lbsStatus = [KKLocation locationStatusString];
        NSString *language = [KKCommonDevice deviceCurrentLanguage];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        //        NSString *loc_time = [NSString getNowTimeTimestamp];//当前时间戳
        //        NSString *last_refresh_sub_entrance_interval = [loc_time copy];//本次请求时间的时间戳
        //NSString *min_behot_time = [[NSUserDefaults standardUserDefaults]objectForKey:catagory];//上次请求的时间戳
        //        if(!min_behot_time.length){
        //            min_behot_time = loc_time ;
        //        }
        //        [[NSUserDefaults standardUserDefaults]setObject:last_refresh_sub_entrance_interval forKey:catagory];//记录上次请求的时间
        
//        NSString *city = [KKLocation shareInstance].curtCity;
//        if(!city.length){
//            city = @"";
//        }
//        NSString *latitude = [KKLocation shareInstance].latitude;
//        if(!latitude.length){
//            latitude = @"";
//        }
//        NSString *longitude = [KKLocation shareInstance].longitude;
//        if(!longitude.length){
//            longitude = @"";
//        }
//        if(![KKLocation locationStatus]){
//            city = @"";
//            latitude = @"";
//            longitude = @"";
//        }
        
        NSMutableDictionary *param = nil;
        
        if([catagory isEqualToString:@"novel_channel"]){
            
        }else if([catagory isEqualToString:@"jinritemai"]){
            
        }else{
            param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",lbsStatus,@"LBS_status",catagory,@"category",language,@"language"/*,city,@"city"*/,/*latitude,@"latitude",longitude,@"longitude",*/os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",concernId,@"concern_id",/*loc_time,@"loc_time",min_behot_time,@"min_behot_time",last_refresh_sub_entrance_interval,@"last_refresh_sub_entrance_interval",KKIdfa,@"idfa", */nil];
        }
        
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKNewsFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKSummaryDataModel *model = [KKSummaryDataModel mj_objectWithKeyValues:responseObject];
            if(success){
                success(model);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取新闻详情数据 对应模型 KKArticleModal
- (void)fetchDetailNewsWithCatagory:(NSString *)catagoryStr
                            groupId:(NSString *)groupId
                             itemId:(NSString *)itemId
                            success:(void(^)(KKArticleModal *modal))success
                            failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
//        if([KKLocation locationStatus]){
//            NSInteger count = 0 ;
//            while (![KKLocation shareInstance].curtCity.length && count <= 3) {
//                usleep(1 * 1000 * 1000);
//                count ++ ;
//            }
//        }
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSString *catagory = catagoryStr ;
        if(!catagory.length || [catagory isEqualToString:@"推荐"]){
            catagory = @"__all__";
        }
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/2/article/information/v23/?version_code=6.3.4&app_name=news_article&channel=App%20Store&aid=13&ab_feature=z2&ab_group=z2&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1&article_page=1&flags=64"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
//        NSString *city = [KKLocation shareInstance].curtCity;
//        if(!city.length){
//            city = @"";
//        }
//        NSString *latitude = [KKLocation shareInstance].latitude;
//        if(!latitude.length){
//            latitude = @"";
//        }
//        NSString *longitude = [KKLocation shareInstance].longitude;
//        if(!longitude.length){
//            longitude = @"";
//        }
//        if(![KKLocation locationStatus]){
//            city = @"";
//            latitude = @"";
//            longitude = @"";
//        }
        
        NSString *group_id = groupId;
        if(group_id == nil){
            group_id = @"";
        }
        NSString *item_id = itemId;
        if(item_id == nil){
            item_id = @"";
        }
        
        NSMutableDictionary *param = nil;
        
        if([catagory isEqualToString:@"novel_channel"]){
            
        }else if([catagory isEqualToString:@"jinritemai"]){
            
        }else{
            param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",catagory,@"from_category"/*,city,@"city"*/,/*latitude,@"latitude",longitude,@"longitude",*/os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",group_id,@"group_id",item_id,@"item_id",nil];
        }
        
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKArticleFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKArticleModal *data = [KKArticleModal mj_objectWithKeyValues:responseObject];
            if(success){
                success(data);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取新闻评论数据 对应模型 KKCommentModal
- (void)fetchCommentWithCatagory:(NSString *)category
                         groupId:(NSString *)groupId
                          itemId:(NSString *)itemId
                          offset:(NSInteger)offset
                       sortIndex:(NSInteger)sortIndex//段子评论的排序，0,热门,1,最新
                         success:(void(^)(KKCommentModal *modal))success
                         failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/article/v2/tab_comments/?version_code=6.3.4&app_name=news_article&channel=App%20Store&aid=13&ab_feature=z2&ab_group=z2&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1&count=20&fold=1"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSString *group_id = groupId;
        if(group_id == nil){
            group_id = @"";
        }
        NSString *item_id = itemId;
        if(item_id == nil){
            item_id = @"";
        }
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",group_id,@"group_id",item_id,@"item_id",@(offset),@"offset",nil];
        
        if([category isEqualToString:@"essay_joke"]){
            [param setObject:@(sortIndex) forKey:@"tab_index"];
        }
        if([category isEqualToString:@"hotsoon_video"]){
            [param setObject:@(1128) forKey:@"service_id"];
        }
        
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKCommentFeedV2];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKCommentModal *model = [KKCommentModal mj_objectWithKeyValues:responseObject];
            if(success){
                success(model);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取个人评论详情 对应模型KKUserCommentDetail
- (void)fetchPersonalCommentWithCommentId:(NSString *)commentId
                                  success:(void(^)(KKUserCommentDetail *modal))success
                                  failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/2/comment/v1/detail/?version_code=6.3.4&app_name=news_article&channel=App%20Store&aid=13&ab_feature=z2&ab_group=z2&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1&source=5"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",commentId,@"comment_id",nil];
        
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKUserCommentFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKUserCommentDetail *modal = [KKUserCommentDetail mj_objectWithKeyValues:responseObject];
            if(success){
                success(modal);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取个人评论的全部回复 对应模型KKCommentReply
- (void)fetchReplyWithCommentId:(NSString *)commentId
                         offset:(NSInteger)offset
                        success:(void(^)(KKCommentReply *modal))success
                        failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/2/comment/v1/detail/?version_code=6.3.4&app_name=news_article&channel=App%20Store&aid=13&ab_feature=z2&ab_group=z2&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1&source=5"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",commentId,@"id",@(offset),@"offset",nil];
        
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKUserCommentReplyFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKCommentReply *model = [KKCommentReply mj_objectWithKeyValues:responseObject];
            if(success){
                success(model);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取个人评论的点赞数据 对应模型KKCommentDigg
- (void)fetchCommentDiggWithCommentId:(NSString *)commentId
                               offset:(NSInteger)offset
                                count:(NSInteger)count
                              success:(void(^)(KKCommentDigg *modal))success
                              failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/2/comment/v1/digg_list/?version_code=6.3.4&app_name=news_article&channel=App%20Store&aid=13&ab_feature=z2&ab_group=z2&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",commentId,@"id",@(offset),@"offset",@(count),@"count",nil];
        
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKUserCommentDiggFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKCommentDigg *modal = [KKCommentDigg mj_objectWithKeyValues:responseObject];
            if(success){
                success(modal);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取视频的播放信息  对应模型KKVideoPlayInfo
- (void)fetchVideoInfoWithVideoId:(NSString *)videoId
                          success:(void(^)(KKVideoPlayInfo *modal))success
                          failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        uint32_t r = 167311424;//arc4random();
        NSString *url = [NSString stringWithFormat:@"/%@%@?r=%d",KKFetchVideoFeed,videoId,r];
        NSData *data = [url dataUsingEncoding:NSUTF8StringEncoding];
        long crc32 = [data getCRC32]; // 使用 crc32 校验
        if (crc32 < 0) { // crc32 的值可能为负数
            crc32 += 0x100000000;
        }
        
        NSDictionary *param = @{@"r":@(r),@"s":@(crc32)};
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@%@",KKNewsHost,KKFetchVideoFeed,videoId];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            if(responseObject && responseObject[@"data"]){
                KKVideoPlayInfo *playInfo = [KKVideoPlayInfo mj_objectWithKeyValues:responseObject[@"data"]];
                if(success){
                    success(playInfo);
                }
            }else{
                if(success){
                    success(nil);
                }
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取微头条详情信息
- (void)fetchWTTDetailInfoWithThreadId:(NSString *)threadId
                               success:(void(^)(KKWTTDetailModel *modal))success
                               failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://it.snssdk.com/ttdiscuss/v1/thread/detail/info/?version_code=6.4.0&app_name=news_article&channel=App%20Store&aid=13&ab_feature=z2&ab_group=z2&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",threadId,@"thread_id",nil];
        
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKWTTDetailFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKWTTDetailModel *modal = [KKWTTDetailModel mj_objectWithKeyValues:responseObject];
            if(success){
                success(modal);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取微头条评论数据
- (void)fetchWTTCommentWithModal:(KKWTTDetailModel *)model
                          offset:(NSInteger)offset
                         success:(void(^)(KKCommentModal *modal))success
                         failure:(void (^)(NSError *error))failure{
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/article/v2/tab_comments/?version_code=6.3.4&app_name=news_article&channel=App%20Store&aid=13&ab_feature=z2&ab_group=z2&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1&fold=1&count=20&group_type=2"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSString *group_id = model.thread.thread_id;
        if(group_id == nil){
            group_id = @"";
        }
        NSString *forum_id = model.forum_info.forum_id;
        if(forum_id == nil){
            forum_id = @"";
        }
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",forum_id,@"forum_id",group_id,@"group_id",@(offset),@"offset",nil];
        
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKCommentFeedV2];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKCommentModal *model = [KKCommentModal mj_objectWithKeyValues:responseObject];
            if(success){
                success(model);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取个人主页信息
- (void)fetchPersonalInfoWithUserId:(NSString *)userId
                            success:(void(^)(KKPersonalModel *modal))success
                            failure:(void (^)(NSError *error))failure{
    if(!userId.length){
        if(failure){
            failure(nil);
        }
        return ;
    }
    
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/user/profile/homepage/v4/?version_code=6.4.2&app_name=news_article&channel=App%20Store&aid=13&ab_feature=z2&ab_group=z2&ssmix=a&device_platform=iphone&ab_client=a1,f2,f7,e1"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",userId,@"user_id",nil];
        
        [param addEntriesFromDictionary:parameters];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKUserCenterFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKPersonalModel *model = [KKPersonalModel mj_objectWithKeyValues:responseObject];
            if(success){
                success(model);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取个人主页动态信息
- (void)fetchPersonalDongTaiInfoWithUserId:(NSString *)userId
                                    cursor:(NSString *)cursor
                                   success:(void(^)(KKDongTaiModel *modal))success
                                   failure:(void (^)(NSError *error))failure{
    if(!userId.length){
        if(failure){
            failure(nil);
        }
        return ;
    }
    
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/dongtai/list/v14/?aweme_plugin_enable=1&api_version=&aid=13&app_name=news_article&version_code=6.4.2&device_platform=iphone"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",userId,@"user_id",nil];
        [param addEntriesFromDictionary:parameters];
        if(cursor.length){
            [param addEntriesFromDictionary:@{@"max_cursor":cursor}];
        }
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKUserDongTaiFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKDongTaiModel *model = [KKDongTaiModel mj_objectWithKeyValues:responseObject];
            if(success){
                success(model);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

//获取个人主页问答信息
- (void)fetchPersonalWengDaWithUserId:(NSString *)userId
                               cursor:(NSString *)cursor
                              success:(void(^)(KKPersonalWenDaModel *modal))success
                              failure:(void (^)(NSError *error))failure{
    if(!userId.length){
        if(failure){
            failure(nil);
        }
        return ;
    }
    
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/wenda/profile/wendatab/loadmore/?format=json&from_channel=media_channel&count=10&offset=undefined"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSString *as = @"";
        NSString *cp = @"";
        [KKAppTools generateAs:&as cp:&cp];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",userId,@"other_id",as,@"as",cp,@"cp",nil];
        [param addEntriesFromDictionary:parameters];
        if(cursor.length){
            [param addEntriesFromDictionary:@{@"max_cursor":cursor}];
        }
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKUserWenDaMoreFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKPersonalWenDaModel *model = [KKPersonalWenDaModel mj_objectWithKeyValues:responseObject];
            if(success){
                success(model);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

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
                                 failure:(void (^)(NSError *error))failure{
    if(!mediaId.length || !userId.length){
        if(failure){
            failure(nil);
        }
        return ;
    }
    
    dispatch_async(self.fetchDataQueue, ^{
        
        KKNetworkTool *netTool = [KKNetworkTool shareInstance];
        
        NSDictionary *parameters = [self getURLParameters:@"https://is.snssdk.com/pgc/ma/?output=json&is_json=1&count=20&from=user_profile_app&version=2"];
        
        CGSize size = [KKCommonDevice deviceResolution];
        NSString *resolution = [NSString stringWithFormat:@"%lld*%lld",(long long)size.width,(long long)size.height];
        
        NSString *netType = [KKCommonDevice getCurrentNetworkType];
        
        NSString *devType = [KKCommonDevice devicePlatForm];
        NSString *os_version = [KKCommonDevice deviceSystemVersion];
        
        NSString *as = @"";
        NSString *cp = @"";
        [KKAppTools generateAs:&as cp:&cp];
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc]initWithObjectsAndKeys:resolution,@"resolution",netType,@"ac",devType,@"device_type",os_version,@"os_version",KKVid,@"vid",KKDeviceId,@"device_id",KKOpenudid,@"openudid",KKIdfv,@"idfv",KKIid,@"iid",mediaId,@"media_id",userId,@"uid",@(pageType),@"page_type",as,@"as",cp,@"cp",nil];
        [param addEntriesFromDictionary:parameters];
        [param addEntriesFromDictionary:@{@"max_behot_time":behotTime.length?behotTime:@""}];
        
        NSString *hostUrl = [NSString stringWithFormat:@"%@%@",KKNewsHost,KKUserPgcFeed];
        [netTool get:hostUrl parameters:param success:^(id responseObject) {
            KKPersonalArticalModel *model = [KKPersonalArticalModel mj_objectWithKeyValues:responseObject];
            if(success){
                success(model);
            }
        } failure:^(NSError *error) {
            if(failure){
                failure(error);
            }
        }];
    });
}

#pragma mark -- URL参数转字典

- (NSDictionary *)getURLParameters:(NSString *)urlStr {
    // 查找参数
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    // 以字典形式将参数返回
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            if (existValue != nil) {
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
            } else {
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}

#pragma mark -- 获取数据队列

- (dispatch_queue_t)fetchDataQueue{
    if(!_fetchDataQueue){
        _fetchDataQueue = dispatch_queue_create("fetchDataQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _fetchDataQueue;
}

@end
