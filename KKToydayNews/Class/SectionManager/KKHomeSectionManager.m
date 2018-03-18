//
//  KKHomeSectionManager.m
//  KKToydayNews
//
//  Created by finger on 2017/9/12.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKHomeSectionManager.h"
#import "KKFetchNewsTool.h"

@interface KKHomeSectionManager ()
@property(nonatomic,strong)NSMutableArray *favSectionArr ;
@property(nonatomic,strong)NSMutableArray *recommonSectionArr ;
@property(nonatomic)dispatch_semaphore_t semaphore ;
@property(nonatomic)dispatch_queue_t queue ;
@end

@implementation KKHomeSectionManager

+ (instancetype)shareInstance{
    static KKHomeSectionManager *share = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[KKHomeSectionManager alloc]init];
    });
    return share ;
}

- (instancetype)init{
    self = [super init];
    if(self){
        self.semaphore = dispatch_semaphore_create(0);
        self.queue = dispatch_queue_create("fetchSectionQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self ;
}

#pragma mark -- 获取用户感兴趣的板块

- (void)fetchFavSectionWithComplete:(void(^)(NSArray<KKSectionItem *> *))block{
    dispatch_async(self.queue, ^{
        if(!self.favSectionArr.count){
            NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:KKUserFavSectionData];
            NSArray *array = nil;
            if(data){
                array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            
            NSMutableArray *catagorys = [NSMutableArray new];
            if(array.count){
                for(KKSectionItem *item in array){
                    [catagorys safeAddObject:item.category];
                }
            }else{
                for(NSInteger i = 0 ; i < 10 ; i++){
                    NSDictionary *itemDic = [kkCatagoryItem() safeObjectAtIndex:i];
                    KKSectionItem *item = [KKSectionItem mj_objectWithKeyValues:itemDic];
                    [catagorys safeAddObject:item.category];
                }
            }
            
            [[KKFetchNewsTool shareInstance]fetchFavoriteSectionWithCatagorys:catagorys modify:NO success:^(NSArray<KKSectionItem *> *itemArray) {
                if(itemArray.count){
                    [self.favSectionArr removeAllObjects];
                    [self.favSectionArr addObjectsFromArray:itemArray];
                    //推荐板块
                    /*KKSectionItem *item = [[KKSectionItem alloc]init];
                    item.category = @"推荐";
                    item.name = @"推荐";
                    item.concern_id = @"6286225228934679042";
                    [self.favSectionArr insertObject:item atIndex:0];*/
                    
                    [self saveFavSection];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(block){
                        block(self.favSectionArr);
                    }
                });
                dispatch_semaphore_signal(self.semaphore);
                
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(block){
                        block(self.favSectionArr);
                    }
                });
                dispatch_semaphore_signal(self.semaphore);
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(block){
                    block(self.favSectionArr);
                }
            });
            dispatch_semaphore_signal(self.semaphore);
        }
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark -- 获取推荐的板块

- (void)fetchRecommonSectionWithComplete:(void(^)(NSArray<KKSectionItem *> *))block{
    dispatch_async(self.queue, ^{
        if(!self.recommonSectionArr.count){
            [[KKFetchNewsTool shareInstance]fetchRecomonSectionWithSuccess:^(NSArray<KKSectionItem *> *itemArray) {
                if(itemArray.count){
                    [self.recommonSectionArr removeAllObjects];
                    [self.recommonSectionArr addObjectsFromArray:itemArray];
                    [self saveFavSection];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(block){
                        block(self.recommonSectionArr);
                    }
                });
                dispatch_semaphore_signal(self.semaphore);
                
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(block){
                        block(self.recommonSectionArr);
                    }
                });
                dispatch_semaphore_signal(self.semaphore);
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if(block){
                    block(self.recommonSectionArr);
                }
            });
            dispatch_semaphore_signal(self.semaphore);
        }
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark -- 更新用户感兴趣的板块

- (void)updateFavoriteSection{
    dispatch_async(self.queue, ^{
        NSMutableArray *catagorys = [NSMutableArray new];
        for(KKSectionItem *item in self.favSectionArr){
            [catagorys safeAddObject:item.category];
        }
        [[KKFetchNewsTool shareInstance]fetchFavoriteSectionWithCatagorys:catagorys modify:YES success:^(id responseObject) {
            dispatch_semaphore_signal(self.semaphore);
        } failure:^(NSError *error) {
            dispatch_semaphore_signal(self.semaphore);
        }];
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark -- 保存用户感兴趣的板块到本地

- (void)saveFavSection {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.favSectionArr];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:KKUserFavSectionData];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark -- 获取板块的索引

- (NSInteger)fetchIndexOfItem:(KKSectionItem *)item{
    __block NSInteger index = 0 ;
    [self.favSectionArr enumerateObjectsUsingBlock:^(KKSectionItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([item.category isEqualToString:obj.category]){
            index = idx ;
            *stop = YES ;
        }
    }];
    return index;
}

- (NSInteger)fetchIndexOfCatagory:(NSString *)catagory{
    __block NSInteger index = 0 ;
    [self.favSectionArr enumerateObjectsUsingBlock:^(KKSectionItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([catagory isEqualToString:obj.category]){
            index = idx ;
            *stop = YES ;
        }
    }];
    return index;
}

#pragma mark -- 获取某个索引对应的catagory

- (NSString *)fetchCatagoryAtIndex:(NSInteger)index{
    KKSectionItem *item = [self.favSectionArr safeObjectAtIndex:index];
    return item.category;
}

#pragma mark -- 数据变更

- (void)addFavoriteItem:(KKSectionItem *)item{
    [self.favSectionArr safeAddObject:item];
}

- (void)addRecommonItem:(KKSectionItem *)item{
    [self.recommonSectionArr safeAddObject:item];
}

- (void)insertFavoriteItem:(KKSectionItem *)item atIndex:(NSInteger)index{
    [self.favSectionArr insertObject:item atIndex:index];
}

- (void)insertRecommonItem:(KKSectionItem *)item atIndex:(NSInteger)index{
    [self.recommonSectionArr insertObject:item atIndex:index];
}

- (void)removeFavItemAtIndex:(NSInteger)index{
    [self.favSectionArr safeRemoveObjectAtIndex:index];
}

- (void)removeRecommonItemAtIndex:(NSInteger)index{
    [self.recommonSectionArr safeRemoveObjectAtIndex:index];
}

#pragma mark -- 

- (NSArray *)getFavoriteSection{
    return self.favSectionArr ;
}

- (NSArray *)getRecommonSection{
    return self.recommonSectionArr ;
}

- (NSInteger)getFavoriteCount{
    return self.favSectionArr.count;
}

- (NSInteger)getRecommonCount{
    return self.recommonSectionArr.count;
}

- (KKSectionItem *)favItemAtIndex:(NSInteger)index{
    return [self.favSectionArr safeObjectAtIndex:index];
}

- (KKSectionItem *)recommonItemAtIndex:(NSInteger)index{
    return [self.recommonSectionArr safeObjectAtIndex:index];
}

#pragma mark -- @property

- (NSMutableArray *)favSectionArr{
    if(!_favSectionArr){
        _favSectionArr = [NSMutableArray new];
    }
    return _favSectionArr;
}

- (NSMutableArray *)recommonSectionArr{
    if(!_recommonSectionArr){
        _recommonSectionArr = [NSMutableArray new];
    }
    return _recommonSectionArr;
}

@end
