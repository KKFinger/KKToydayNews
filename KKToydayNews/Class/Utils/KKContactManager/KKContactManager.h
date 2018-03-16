//
//  KKContactManager.h
//  KKToydayNews
//
//  Created by finger on 2017/11/28.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKPerson.h"

typedef NS_ENUM(NSInteger, KKContactAuthorizationStatus){
    /*! The user has not yet made a choice regarding whether the application may access contact data. */
    KKContactAuthorizationStatusNotDetermined = 0,
    /*! The application is not authorized to access contact data.
     *  The user cannot change this application’s status, possibly due to active restrictions such as parental controls being in place. */
    KKContactAuthorizationStatusRestricted,
    /*! The user explicitly denied access to contact data for the application. */
    KKContactAuthorizationStatusDenied,
    /*! The application is authorized to access contact data. */
    KKContactAuthorizationStatusAuthorized
};

/**
 通讯录变更回调（未分组的通讯录）
 
 @param succeed 是否成功
 @param newContacts  联系人列表（未分组）
 */
typedef void (^KKContactChangeHanlder) (BOOL succeed, NSArray <KKPerson *> *newContacts);

/**
 通讯录变更回调（已分组的通讯录）
 
 @param succeed 是否成功
 @param newSectionContacts 联系人列表（已分组）
 @param keys 所有联系人的分区标题
 */
typedef void (^KKSectionContactChangeHanlder) (BOOL succeed, NSArray <KKSectionPerson *> *newSectionContacts, NSArray <NSString *> *keys);


@interface KKContactManager : NSObject

/**
 通讯录变更回调（未分组的通讯录）
 */
@property (nonatomic, copy) KKContactChangeHanlder contactChangeHanlder;

/**
 通讯录变更回调（已分组的通讯录）
 */
@property (nonatomic, copy) KKSectionContactChangeHanlder sectionContactChangeHanlder;

+ (instancetype)sharedInstance;

#pragma mark -- 请求授权

- (void)requestContactBookAuthorization:(void(^)(BOOL authorization))completion;

#pragma mark -- 查询授权状态

- (KKContactAuthorizationStatus)fetchContactAuthorizationStatus;

#pragma mark -- 获取通讯录数据(未分组)

- (void)fetchContactsComplection:(void (^)(BOOL, NSArray<KKPerson *> *))completcion;

#pragma mark -- 获取通讯录数据(分组数据)

- (void)fetchSectionContactsComplection:(void (^)(BOOL suc, NSArray<KKSectionPerson *> *secPersonArray, NSArray<NSString *> *keyArray))completcion;

@end













@interface KKContactManager(BKSelectContact)
/**
 选择的人
 */
@property(nonatomic)NSMutableArray<KKPerson *> *selPersonArray;

/**
 最多选择的人
 */
@property(nonatomic,assign)NSInteger maxSelectCount ;

//检查是否可以添加
- (BOOL)checkCanAddPerson;
//检查是否已经添加
- (BOOL)checkExistWithNumberId:(NSString *)numberIdStr phoneNumber:(NSString *)phoneNumber;
//选择某个联系人
- (void)selectPersonWithPerson:(KKPerson *)person;
//取消选择某个联系人
- (void)deletePersonWithPerson:(KKPerson *)person;
//取消选择某个联系人 index索引
- (void)deletePersonWithIndex:(NSInteger)index;
//取消选择某个联系人 联系人的唯一标识 phoneNumber电话号码 某个可能联系人有多个电话号码  需要做区分
- (void)deletePersonWithIdentifiler:(NSString *)identifiler numberId:(NSString *)numberId;
//将选择的数据保存到本地
- (void)savaSelectPersonToLocal;
//获取保存在本地的联系人
- (NSArray<KKPerson *> *)getSelectPersonFromLocal;
//获取全部选择的电话号码
- (NSArray<NSString *> *)getSelectPhoneNumber;
//手动添加的人数
- (NSInteger)numberOfManualAdd;
//通讯录添加的人数
- (NSInteger)numberOfContactAdd;

@end
