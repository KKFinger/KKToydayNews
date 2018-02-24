//
//  KKPerson.h
//  KKToydayNews
//
//  Created by finger on 2017/11/28.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "KKModalBase.h"

@class KKPhone, KKEmail, KKAddress, KKBirthday, KKMessage, KKSocialProfile, KKContactRelation, KKUrlAddress;

/**
 联系人类型
 */
typedef NS_ENUM(NSUInteger, KKContactType){
    KKContactTypePerson = 0,//个人
    KKContactTypeOrigination,//组织
};

@interface KKPerson : KKModalBase

/**
 联系人的唯一标识
 */
@property (nonatomic, copy) NSString *identifiler;

/**
 联系人类型
 */
@property (nonatomic) KKContactType contactType;
/**
 姓名
 */
@property (nonatomic, copy) NSString *fullName;
/**
 姓
 */
@property (nonatomic, copy) NSString *familyName;
/**
 名
 */
@property (nonatomic, copy) NSString *givenName;
/**
 姓名前缀
 */
@property (nonatomic, copy) NSString *namePrefix;
/**
 姓名后缀
 */
@property (nonatomic, copy) NSString *nameSuffix;
/**
 昵称
 */
@property (nonatomic, copy) NSString *nickname;
/**
 中间名
 */
@property (nonatomic, copy) NSString *middleName;
/**
 公司
 */
@property (nonatomic, copy) NSString *organizationName;
/**
 部门
 */
@property (nonatomic, copy) NSString *departmentName;
/**
 职位
 */
@property (nonatomic, copy) NSString *jobTitle;
/**
 备注
 */
@property (nonatomic, copy) NSString *note;
/**
 名的拼音或音标
 */
@property (nonatomic, copy) NSString *phoneticGivenName;
/**
 中间名的拼音或音标
 */
@property (nonatomic, copy) NSString *phoneticMiddleName;
/**
 姓的拼音或音标
 */
@property (nonatomic, copy) NSString *phoneticFamilyName;
/**
 头像 Data
 */
@property (nonatomic, copy) NSData *imageData;
/**
 头像图片
 */
@property (nonatomic, strong) UIImage *image;
/**
 头像的缩略图 Data
 */
@property (nonatomic, copy) NSData *thumbnailImageData;
/**
 头像缩略图片
 */
@property (nonatomic, strong) UIImage *thumbnailImage;
/**
 获取创建当前联系人的时间
 */
@property (nonatomic, strong) NSDate *creationDate;
/**
 获取最近一次修改当前联系人的时间
 */
@property (nonatomic, strong) NSDate *modificationDate;
/**
 电话号码数组
 */
@property (nonatomic, copy) NSArray <KKPhone *> *phoneArray;
/**
 邮箱数组
 */
@property (nonatomic, copy) NSArray <KKEmail *> *emails;
/**
 地址数组
 */
@property (nonatomic, copy) NSArray <KKAddress *> *addresses;
/**
 生日对象
 */
@property (nonatomic, strong) KKBirthday *birthday;
/**
 即时通讯数组
 */
@property (nonatomic, copy) NSArray <KKMessage *> *messages;
/**
 社交数组
 */
@property (nonatomic, copy) NSArray <KKSocialProfile *> *socials;
/**
 关联人数组
 */
@property (nonatomic, copy) NSArray <KKContactRelation *> *relations;
/**
 url数组
 */
@property (nonatomic, copy) NSArray <KKUrlAddress *> *urls;

/**
 @param contact 通讯录
 @return 对象
 */
- (instancetype)initWithCNContact:(CNContact *)contact;

/**
 @param record 记录
 @return 对象
 */
- (instancetype)initWithRecord:(ABRecordRef)record;

@end




//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////





#pragma mark -- 电话号码

@interface KKPhone : KKModalBase

/**
 电话号码的唯一标识符，通讯录中同一个人可存在多个相同号码的情况
 */
@property(nonatomic,copy)NSString *identifier;

/**
 电话
 */
@property (nonatomic, copy) NSString *phoneNumber;

/**
 标签
 */
@property (nonatomic, copy) NSString *label;

/**
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;

/**
 @param multiValue 标签和值
 @param index 下标
 @return 对象
 */
- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index;

@end




//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////





#pragma mark -- 电子邮件

@interface KKEmail : KKModalBase

/**
 邮箱
 */
@property (nonatomic, copy) NSString *email;

/**
 标签
 */
@property (nonatomic, copy) NSString *label;

/**
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;

/**
 @param multiValue 标签和值
 @param index 下标
 @return 对象
 */
- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index;

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////





#pragma mark -- 地址

@interface KKAddress : KKModalBase

/**
 标签
 */
@property (nonatomic, copy) NSString *label;

/**
 街道
 */
@property (nonatomic, copy) NSString *street;

/**
 城市
 */
@property (nonatomic, copy) NSString *city;

/**
 州
 */
@property (nonatomic, copy) NSString *state;

/**
 邮政编码
 */
@property (nonatomic, copy) NSString *postalCode;

/**
 城市
 */
@property (nonatomic, copy) NSString *country;

/**
 国家代码
 */
@property (nonatomic, copy) NSString *ISOCountryCode;

/**
 标准格式化地址
 */
@property (nonatomic, copy) NSString *formatterAddress NS_AVAILABLE_IOS(9_0);

/**
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;

/**
 @param multiValue 标签和值
 @param index 下标
 @return 对象
 */
- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index;

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////




#pragma mark -- 生日

@interface KKBirthday : KKModalBase

/**
 生日日期
 */
@property (nonatomic, strong) NSDate *brithdayDate;

/**
 农历标识符（chinese）
 */
@property (nonatomic, copy) NSString *calendarIdentifier;

/**
 纪元
 */
@property (nonatomic, assign) NSInteger era;

/**
 年
 */
@property (nonatomic, assign) NSInteger year;

/**
 月
 */
@property (nonatomic, assign) NSInteger month;

/**
 日
 */
@property (nonatomic, assign) NSInteger day;

/**
 @param contact 通讯录
 @return 对象
 */
- (instancetype)initWithCNContact:(CNContact *)contact;

/**
 @param record 记录
 @return 对象
 */
- (instancetype)initWithRecord:(ABRecordRef)record;

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////




#pragma mark -- 即时通讯

@interface KKMessage : KKModalBase

/**
 即时通讯名字（QQ）
 */
@property (nonatomic, copy) NSString *service;

/**
 账号
 */
@property (nonatomic, copy) NSString *userName;

/**
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;

/**
 @param multiValue 标签和值
 @param index 下标
 @return 对象
 */
- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index;

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////




#pragma mark -- 社交

@interface KKSocialProfile : KKModalBase

/**
 社交名字（Facebook）
 */
@property (nonatomic, copy) NSString *service;

/**
 账号
 */
@property (nonatomic, copy) NSString *username;

/**
 url字符串
 */
@property (nonatomic, copy) NSString *urlString;

/**
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;

/**
 @param multiValue 标签和值
 @param index 下标
 @return 对象
 */
- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index;

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////




#pragma mark -- URL

@interface KKUrlAddress : KKModalBase

/**
 标签
 */
@property (nonatomic, copy) NSString *label;

/**
 url字符串
 */
@property (nonatomic, copy) NSString *urlString;

/**
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;

/**
 @param multiValue 标签和值
 @param index 下标
 @return 对象
 */
- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index;

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////




#pragma mark -- 关联人

@interface KKContactRelation : KKModalBase

/**
 标签（父亲，朋友等）
 */
@property (nonatomic, copy) NSString *label;

/**
 名字
 */
@property (nonatomic, copy) NSString *name;

/**
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;

/**
 @param multiValue 标签和值
 @param index 下标
 @return 对象
 */
- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index;

@end






//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////




#pragma mark -- 排序分组模型

@interface KKSectionPerson : KKModalBase
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSArray <KKPerson *> *persons;
@end








//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////选择联系人相关//////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

@interface KKPerson (BKSelectContact)
@property(nonatomic,assign)BOOL isMulitSelected;//该用户选择了多个号码
@end

@interface KKPhone (BKSelectContact)

/**
 同一个人可能对应有多个电话
 */
@property(nonatomic,assign)BOOL isSelected;

/**
 是否是手动添加
 */
@property(nonatomic,assign)BOOL isManualAdd;

@end
