//
//  KKHomeSectionManager.h
//  KKToydayNews
//
//  Created by finger on 2017/9/12.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKSectionItem.h"

@interface KKHomeSectionManager : NSObject

+ (instancetype)shareInstance;

#pragma mark -- 获取/更新用户感兴趣的板块

- (void)fetchFavSectionWithComplete:(void(^)(NSArray<KKSectionItem *> *))block ;

#pragma mark -- 获取推荐的板块

- (void)fetchRecommonSectionWithComplete:(void(^)(NSArray<KKSectionItem *> *))block;

#pragma mark -- 更新用户感兴趣的板块

- (void)updateFavoriteSection;

#pragma mark -- 保存用户感兴趣的板块到本地

- (void)saveFavSection ;

#pragma mark -- 获取板块的索引

- (NSInteger)fetchIndexOfItem:(KKSectionItem *)item;
- (NSInteger)fetchIndexOfCatagory:(NSString *)catagory;

#pragma mark -- 获取某个索引对应的catagory

- (NSString *)fetchCatagoryAtIndex:(NSInteger)index;

#pragma mark -- 数据变更

- (void)addFavoriteItem:(KKSectionItem *)item;
- (void)addRecommonItem:(KKSectionItem *)item;
- (void)insertFavoriteItem:(KKSectionItem *)item atIndex:(NSInteger)index;
- (void)insertRecommonItem:(KKSectionItem *)item atIndex:(NSInteger)index;
- (void)removeFavItemAtIndex:(NSInteger)index;
- (void)removeRecommonItemAtIndex:(NSInteger)index;

#pragma mark --

- (NSArray *)getFavoriteSection;
- (NSArray *)getRecommonSection;
- (NSInteger)getFavoriteCount;
- (NSInteger)getRecommonCount;
- (KKSectionItem *)favItemAtIndex:(NSInteger)index;
- (KKSectionItem *)recommonItemAtIndex:(NSInteger)index;

@end
