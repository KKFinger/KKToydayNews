//
//  KKXiGuaSectionManager.m
//  KKToydayNews
//
//  Created by finger on 2017/10/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKXiGuaSectionManager.h"
#import "KKFetchNewsTool.h"

@interface KKXiGuaSectionManager ()
@property(nonatomic,strong)NSMutableArray *sectionArr ;
@property(nonatomic)dispatch_semaphore_t semaphore ;
@property(nonatomic)dispatch_queue_t queue ;
@end

@implementation KKXiGuaSectionManager

+ (instancetype)shareInstance{
    static KKXiGuaSectionManager *share = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[KKXiGuaSectionManager alloc]init];
    });
    return share ;
}

- (instancetype)init{
    self = [super init];
    if(self){
        self.semaphore = dispatch_semaphore_create(0);
        self.queue = dispatch_queue_create("KKXiGuaSectionManager", DISPATCH_QUEUE_SERIAL);
    }
    return self ;
}

#pragma mark -- 获取西瓜视频板块的Section

- (void)fetchSectionWithComplete:(void(^)(NSArray<KKSectionItem *> *))block{
    dispatch_async(self.queue, ^{
        [[KKFetchNewsTool shareInstance]fetchXiGuaSectionWithSuccess:^(NSArray<KKSectionItem *> *itemArray) {
            if(itemArray.count){
                [self.sectionArr removeAllObjects];
                [self.sectionArr addObjectsFromArray:itemArray];
                //推荐板块
                KKSectionItem *item = [[KKSectionItem alloc]init];
                item.category = @"video";
                item.name = @"推荐";
                item.concern_id = @"";
                [self.sectionArr insertObject:item atIndex:0];
                
                [self saveSection];
            }else{
                NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:KKXiGuaSectionData];
                NSArray *array = nil;
                if(data){
                    array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                }
                if(array.count){
                    [self.sectionArr removeAllObjects];
                    [self.sectionArr addObjectsFromArray:array];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(block){
                    block(self.sectionArr);
                }
            });
            dispatch_semaphore_signal(self.semaphore);
            
        } failure:^(NSError *error) {
            NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:KKXiGuaSectionData];
            NSArray *array = nil;
            if(data){
                array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            if(array.count){
                [self.sectionArr removeAllObjects];
                [self.sectionArr addObjectsFromArray:array];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(block){
                    block(self.sectionArr);
                }
            });
            dispatch_semaphore_signal(self.semaphore);
        }];
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark -- 保存到本地

- (void)saveSection {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.sectionArr];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:KKXiGuaSectionData];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

#pragma mark -- 获取板块的索引

- (NSInteger)fetchIndexOfItem:(KKSectionItem *)item{
    __block NSInteger index = 0 ;
    [self.sectionArr enumerateObjectsUsingBlock:^(KKSectionItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([item.category isEqualToString:obj.category]){
            index = idx ;
            *stop = YES ;
        }
    }];
    return index;
}

- (NSInteger)fetchIndexOfCatagory:(NSString *)catagory{
    __block NSInteger index = 0 ;
    [self.sectionArr enumerateObjectsUsingBlock:^(KKSectionItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([catagory isEqualToString:obj.category]){
            index = idx ;
            *stop = YES ;
        }
    }];
    return index;
}

#pragma mark -- 获取某个索引对应的catagory

- (NSString *)fetchCatagoryAtIndex:(NSInteger)index{
    KKSectionItem *item = [self.sectionArr safeObjectAtIndex:index];
    return item.category;
}

#pragma mark -- 数据变更

- (void)addSectionItem:(KKSectionItem *)item{
    [self.sectionArr safeAddObject:item];
}

- (void)insertSectionItem:(KKSectionItem *)item atIndex:(NSInteger)index{
    [self.sectionArr insertObject:item atIndex:index];
}

- (void)removeSectionItemAtIndex:(NSInteger)index{
    [self.sectionArr safeRemoveObjectAtIndex:index];
}

#pragma mark --

- (NSArray *)getSection{
    return self.sectionArr ;
}

- (NSInteger)getSectionCount{
    return self.sectionArr.count;
}

- (KKSectionItem *)sectionItemAtIndex:(NSInteger)index{
    return [self.sectionArr safeObjectAtIndex:index];
}

#pragma mark -- @property

- (NSMutableArray *)sectionArr{
    if(!_sectionArr){
        _sectionArr = [NSMutableArray new];
    }
    return _sectionArr;
}

@end
