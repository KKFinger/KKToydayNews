//
//  KKXiGuaSectionManager.h
//  KKToydayNews
//
//  Created by finger on 2017/10/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKXiGuaSectionManager : NSObject

+ (instancetype)shareInstance;

#pragma mark -- 获取西瓜视频板块的Section

- (void)fetchSectionWithComplete:(void(^)(NSArray<KKSectionItem *> *))block;
#pragma mark -- 保存用户感兴趣的板块到本地

- (void)saveSection;

#pragma mark -- 获取板块的索引

- (NSInteger)fetchIndexOfItem:(KKSectionItem *)item;

- (NSInteger)fetchIndexOfCatagory:(NSString *)catagory;

#pragma mark -- 获取某个索引对应的catagory

- (NSString *)fetchCatagoryAtIndex:(NSInteger)index;

#pragma mark -- 数据变更

- (void)addSectionItem:(KKSectionItem *)item;

- (void)insertSectionItem:(KKSectionItem *)item atIndex:(NSInteger)index;

- (void)removeSectionItemAtIndex:(NSInteger)index;

#pragma mark --

- (NSArray *)getSection;

- (NSInteger)getSectionCount;

- (KKSectionItem *)sectionItemAtIndex:(NSInteger)index;

@end
