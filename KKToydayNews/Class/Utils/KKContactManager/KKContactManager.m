//
//  KKContactManager.m
//  KKToydayNews
//
//  Created by finger on 2017/11/28.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKContactManager.h"
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>

#define KKSelectPersonData @"KKSelectPersonData"

@interface KKContactManager ()
@property (nonatomic) ABAddressBookRef addressBook;
@property (nonatomic, copy) NSArray *keys;//获取通讯录详情的key
@end

@implementation KKContactManager

+ (instancetype)sharedInstance{
    static id shared_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared_instance = [[self alloc] init];
    });
    return shared_instance;
}

- (instancetype)init{
    if(self = [super init]){
        if (IOS9_OR_LATER){
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(contactStoreDidChange)
                                                         name:CNContactStoreDidChangeNotification
                                                       object:nil];
        }else{
            self.addressBook = ABAddressBookCreate();
            ABAddressBookRegisterExternalChangeCallback(self.addressBook, addressBookChangeCallback, (__bridge void *)self);
        }
        self.maxSelectCount = 50 ;
    }
    return self;
}

- (void)dealloc{
    ABAddressBookUnregisterExternalChangeCallback(self.addressBook, addressBookChangeCallback, (__bridge void *)self);
    CFRelease(self.addressBook);
}

#pragma mark -- 获取通讯录详情的key

- (NSArray *)keys{
    if (!_keys){
        _keys = @[[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
                  CNContactPhoneNumbersKey,
                  CNContactOrganizationNameKey,
                  CNContactDepartmentNameKey,
                  CNContactJobTitleKey,
                  CNContactNoteKey,
                  CNContactPhoneticGivenNameKey,
                  CNContactPhoneticFamilyNameKey,
                  CNContactPhoneticMiddleNameKey,
                  CNContactImageDataKey,
                  CNContactThumbnailImageDataKey,
                  CNContactEmailAddressesKey,
                  CNContactPostalAddressesKey,
                  CNContactBirthdayKey,
                  CNContactNonGregorianBirthdayKey,
                  CNContactInstantMessageAddressesKey,
                  CNContactSocialProfilesKey,
                  CNContactRelationsKey,
                  CNContactUrlAddressesKey];
    }
    return _keys;
}

#pragma mark -- 请求授权

- (void)requestContactBookAuthorization:(void(^)(BOOL authorization))completion{
    __block BOOL authorization;
    if (IOS9_OR_LATER){
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined){
            [self authorizationContactBook:^(BOOL succeed) {
                authorization = succeed;
            }];
        }else if (status == CNAuthorizationStatusAuthorized){
            authorization = YES;
        }else{
            authorization = NO;
        }
    }else{
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined){
            [self authorizationContactBook:^(BOOL succeed) {
                authorization = succeed;
            }];
        }else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
            authorization = YES;
        }else{
            authorization = NO;
        }
    }
    if (completion){
        completion(authorization);
    }
}

- (void)authorizationContactBook:(void(^)(BOOL succeed))completion{
    if (IOS9_OR_LATER){
        CNContactStore *store = [CNContactStore new];
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (completion){
                completion(granted);
            }
        }];
    }else{
        ABAddressBookRef addressBook = ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            CFRelease(addressBook);
            if (completion){
                completion(granted);
            }
        });
    }
}

#pragma mark -- 查询授权状态

- (KKContactAuthorizationStatus)fetchContactAuthorizationStatus{
    if (IOS9_OR_LATER){
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        return [self convertStatusWithCNAuthorizationStatus:status];
    }else{
        ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
        return [self convertStatusWithABAuthorizationStatus:status];
    }
}

- (KKContactAuthorizationStatus)convertStatusWithCNAuthorizationStatus:(CNAuthorizationStatus)status{
    switch (status){
        case CNAuthorizationStatusNotDetermined:
            return KKContactAuthorizationStatusNotDetermined;
        case CNAuthorizationStatusRestricted:
            return KKContactAuthorizationStatusRestricted;
        case CNAuthorizationStatusDenied:
            return KKContactAuthorizationStatusDenied;
        case CNAuthorizationStatusAuthorized:
            return KKContactAuthorizationStatusAuthorized;
        default:
            return KKContactAuthorizationStatusRestricted;
    }
}

- (KKContactAuthorizationStatus)convertStatusWithABAuthorizationStatus:(ABAuthorizationStatus)status{
    switch (status){
        case kABAuthorizationStatusNotDetermined:
            return KKContactAuthorizationStatusNotDetermined;
        case kABAuthorizationStatusRestricted:
            return KKContactAuthorizationStatusRestricted;
        case kABAuthorizationStatusDenied:
            return KKContactAuthorizationStatusDenied;
        case kABAuthorizationStatusAuthorized:
            return KKContactAuthorizationStatusAuthorized;
        default:
            return KKContactAuthorizationStatusRestricted;
    }
}

#pragma mark -- 获取通讯录数据(未分组)

- (void)fetchContactsComplection:(void (^)(BOOL, NSArray<KKPerson *> *))completcion{
    [self requestContactBookAuthorization:^(BOOL authorization) {
        if (authorization){
            if (IOS9_OR_LATER){
                [self asynFetchContactWithSort:NO completcion:^(NSArray *datas, NSArray *keys) {
                    //同步数据
                    NSMutableArray *tempSelArray = [NSMutableArray arrayWithCapacity:0];
                    for(KKPerson *person in self.selPersonArray){
                        if(person.phoneArray.firstObject.isManualAdd){
                            [tempSelArray safeAddObject:person];
                            continue;
                        }
                        for(KKPerson *target in datas){
                            if([target.identifiler isEqualToString:person.identifiler]){
                                target.isMulitSelected = person.isMulitSelected;
                                for(KKPhone *phone in person.phoneArray){
                                    for(KKPhone *targetPhone in target.phoneArray){
                                        if([phone.identifier isEqualToString:targetPhone.identifier]){
                                            targetPhone.isSelected = phone.isSelected;
                                            targetPhone.isManualAdd = phone.isManualAdd;
                                            break;
                                        }
                                    }
                                }
                                [tempSelArray safeAddObject:target];
                                break;
                            }
                        }
                    }
                    [self.selPersonArray removeAllObjects];
                    [self.selPersonArray addObjectsFromArray:tempSelArray];
                    [tempSelArray removeAllObjects];
                    
                    if (completcion){
                        completcion(YES, datas);
                    }
                }];
            }else{
                [self asynFetchAddressBookWithSort:NO completcion:^(NSArray *datas, NSArray *keys) {
                    //同步数据
                    NSMutableArray *tempSelArray = [NSMutableArray arrayWithCapacity:0];
                    for(KKPerson *person in self.selPersonArray){
                        if(person.phoneArray.firstObject.isManualAdd){
                            [tempSelArray safeAddObject:person];
                            continue;
                        }
                        for(KKPerson *target in datas){
                            if([target.identifiler isEqualToString:person.identifiler]){
                                target.isMulitSelected = person.isMulitSelected;
                                for(KKPhone *phone in person.phoneArray){
                                    for(KKPhone *targetPhone in target.phoneArray){
                                        if([phone.identifier isEqualToString:targetPhone.identifier]){
                                            targetPhone.isSelected = phone.isSelected;
                                            targetPhone.isManualAdd = phone.isManualAdd;
                                            break ;
                                        }
                                    }
                                }
                                [tempSelArray safeAddObject:target];
                                break;
                            }
                        }
                    }
                    [self.selPersonArray removeAllObjects];
                    [self.selPersonArray addObjectsFromArray:tempSelArray];
                    [tempSelArray removeAllObjects];
                    
                    if (completcion){
                        completcion(YES, datas);
                    }
                }];
            }
        }else{
            if (completcion){
                completcion(NO, nil);
            }
        }
    }];
}

#pragma mark -- 获取通讯录数据(分组数据)

- (void)fetchSectionContactsComplection:(void (^)(BOOL suc, NSArray<KKSectionPerson *> *secPersonArray, NSArray<NSString *> *keyArray))completcion{
    [self requestContactBookAuthorization:^(BOOL authorization) {
        if (authorization){
            if (IOS9_OR_LATER){
                [self asynFetchContactWithSort:YES completcion:^(NSArray *datas, NSArray *keys) {
                    //同步数据
                    NSMutableArray *tempSelArray = [NSMutableArray arrayWithCapacity:0];
                    for(KKPerson *person in self.selPersonArray){
                        if(person.phoneArray.firstObject.isManualAdd){
                            [tempSelArray safeAddObject:person];
                            continue;
                        }
                        for(KKSectionPerson *targetSec in datas){
                            BOOL shouldBreak = NO ;
                            for(KKPerson *target in targetSec.persons){
                                if([target.identifiler isEqualToString:person.identifiler]){
                                    target.isMulitSelected = person.isMulitSelected;
                                    for(KKPhone *phone in person.phoneArray){
                                        for(KKPhone *targetPhone in target.phoneArray){
                                            if([phone.identifier isEqualToString:targetPhone.identifier]){
                                                targetPhone.isSelected = phone.isSelected;
                                                targetPhone.isManualAdd = phone.isManualAdd;
                                                break ;
                                            }
                                        }
                                    }
                                    
                                    shouldBreak = YES ;
                                    
                                    [tempSelArray safeAddObject:target];
                                    
                                    break;
                                }
                            }
                            if(shouldBreak){
                                break ;
                            }
                        }
                    }
                    
                    [self.selPersonArray removeAllObjects];
                    [self.selPersonArray addObjectsFromArray:tempSelArray];
                    [tempSelArray removeAllObjects];
                    
                    if (completcion){
                        completcion(YES, datas, keys);
                    }
                }];
            }else{
                [self asynFetchAddressBookWithSort:YES completcion:^(NSArray *datas, NSArray *keys) {
                    //同步数据
                    NSMutableArray *tempSelArray = [NSMutableArray arrayWithCapacity:0];
                    for(KKPerson *person in self.selPersonArray){
                        if(person.phoneArray.firstObject.isManualAdd){
                            [tempSelArray safeAddObject:person];
                            continue;
                        }
                        for(KKSectionPerson *targetSec in datas){
                            BOOL shouldBreak = NO ;
                            for(KKPerson *target in targetSec.persons){
                                if([target.identifiler isEqualToString:person.identifiler]){
                                    target.isMulitSelected = person.isMulitSelected;
                                    for(KKPhone *phone in person.phoneArray){
                                        for(KKPhone *targetPhone in target.phoneArray){
                                            if([phone.identifier isEqualToString:targetPhone.identifier]){
                                                targetPhone.isSelected = phone.isSelected;
                                                targetPhone.isManualAdd = phone.isManualAdd;
                                                break ;
                                            }
                                        }
                                    }
                                    
                                    shouldBreak = YES ;
                                    
                                    [tempSelArray safeAddObject:target];
                                    
                                    break;
                                }
                            }
                            if(shouldBreak){
                                break ;
                            }
                        }
                    }
                    
                    [self.selPersonArray removeAllObjects];
                    [self.selPersonArray addObjectsFromArray:tempSelArray];
                    [tempSelArray removeAllObjects];
                    
                    if (completcion){
                        completcion(YES, datas, keys);
                    }
                }];
            }
        }else{
            if (completcion){
                completcion(NO, nil, nil);
            }
        }
    }];
}

#pragma mark -- iOS9之后的获取方式

/**
 iOS9之后获取通讯录数据
 @param isSort 是否需要分组
 @param completcion completcion description
 */
- (void)asynFetchContactWithSort:(BOOL)isSort completcion:(void (^)(NSArray *, NSArray *))completcion{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *datas = [NSMutableArray array];
        CNContactStore *contactStore = [CNContactStore new];
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:self.keys];
        
        [contactStore enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            KKPerson *person = [[KKPerson alloc] initWithCNContact:contact];
            if(person.phoneArray.count){
                [datas addObject:person];
            }
        }];
        
        if (!isSort){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completcion){
                    completcion(datas, nil);
                }
            });
        }else{
            [self sortContactWithDatas:datas completcion:^(NSArray *persons, NSArray *keys) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completcion){
                        completcion(persons, keys);
                    }
                });
            }];
        }
    });
}

#pragma mark -- iOS9之前的获取方式

/**
 iOS9之前的获取方式
 @param isSort 是否需要分组
 @param completcion completcion description
 */
- (void)asynFetchAddressBookWithSort:(BOOL)isSort completcion:(void (^)(NSArray *, NSArray *))completcion{
    NSMutableArray *datas = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ABAddressBookRef addressBook = ABAddressBookCreate();
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex count = CFArrayGetCount(allPeople);
        for (int i = 0; i < count; i++){
            ABRecordRef record = CFArrayGetValueAtIndex(allPeople, i);
            KKPerson *personModel = [[KKPerson alloc] initWithRecord:record];
            if(personModel.phoneArray.count){
                [datas addObject:personModel];
            }
        }
        CFRelease(addressBook);
        CFRelease(allPeople);
        
        if (!isSort){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completcion){
                    completcion(datas, nil);
                }
            });
        }else{
            [self sortContactWithDatas:datas completcion:^(NSArray *persons, NSArray *keys) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completcion){
                        completcion(persons, keys);
                    }
                });
                
            }];
        }
    });
}

#pragma mark -- 将通讯录根据名字的第一个字母排序

- (void)sortContactWithDatas:(NSArray *)datas completcion:(void (^)(NSArray *, NSArray *))completcion{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (KKPerson *person in datas){
        NSString *firstLetter = [self firstCharacterWithString:person.fullName];
        if (dict[firstLetter]){
            [dict[firstLetter] addObject:person];
        }else{
            NSMutableArray *arr = [NSMutableArray arrayWithObjects:person, nil];
            [dict setValue:arr forKey:firstLetter];
        }
    }
    
    NSMutableArray *keys = [[[dict allKeys] sortedArrayUsingSelector:@selector(compare:)] mutableCopy];
    if ([keys.firstObject isEqualToString:@"#"]){
        [keys addObject:keys.firstObject];
        [keys removeObjectAtIndex:0];
    }
    
    NSMutableArray *persons = [NSMutableArray array];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
        KKSectionPerson *person = [KKSectionPerson new];
        person.key = key;
        person.persons = dict[key];
        [persons addObject:person];
    }];
    
    if (completcion){
        completcion(persons, keys);
    }
}

#pragma mark -- 获取第一个字母

- (NSString *)firstCharacterWithString:(NSString *)string{
    if (string.length == 0){
        return @"#";
    }
    
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    
    NSMutableString *pinyinString = [[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]] mutableCopy];
    NSString *str = [string substringToIndex:1];
    
    // 多音字处理http://blog.csdn.net/qq_29307685/article/details/51532147
    if ([str compare:@"长"] == NSOrderedSame){
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 5) withString:@"chang"];
    }
    if ([str compare:@"沈"] == NSOrderedSame){
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 4) withString:@"shen"];
    }
    if ([str compare:@"厦"] == NSOrderedSame){
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 3) withString:@"xia"];
    }
    if ([str compare:@"地"] == NSOrderedSame){
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 2) withString:@"di"];
    }
    if ([str compare:@"重"] == NSOrderedSame){
        [pinyinString replaceCharactersInRange:NSMakeRange(0, 5) withString:@"chong"];
    }
    
    NSString *upperStr = [[pinyinString substringToIndex:1] uppercaseString];
    
    NSString *regex = @"^[A-Z]$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    NSString *firstCharacter = [predicate evaluateWithObject:upperStr] ? upperStr : @"#";
    
    return firstCharacter;
}

#pragma mark -- 通讯录变化回调(iOS9之前)

void addressBookChangeCallback(ABAddressBookRef addressBook, CFDictionaryRef info, void *context){
    KKContactManager *mgr = (__bridge KKContactManager *)context;
    
    __weak typeof(mgr)weakMgr = mgr ;
    [mgr fetchContactsComplection:^(BOOL succeed, NSArray *contacts) {
        __strong typeof(weakMgr)strongMgr = weakMgr ;
        if (strongMgr.contactChangeHanlder){
            strongMgr.contactChangeHanlder(succeed, contacts);
        }
    }];
    [mgr fetchSectionContactsComplection:^(BOOL succeed, NSArray<KKSectionPerson *> *contacts, NSArray<NSString *> *keys) {
        __strong typeof(weakMgr)strongMgr = weakMgr ;
        if (strongMgr.sectionContactChangeHanlder){
            strongMgr.sectionContactChangeHanlder(succeed, contacts, keys);
        }
    }];
}

#pragma mark -- 通讯录变化通知(iOS9之后)

- (void)contactStoreDidChange{
    __weak typeof(self)weakSelf = self ;
    [self fetchContactsComplection:^(BOOL succeed, NSArray *contacts) {
        __strong typeof(weakSelf)strongSelf = weakSelf ;
        if (strongSelf.contactChangeHanlder){
            strongSelf.contactChangeHanlder(succeed, contacts);
        }
    }];
    [self fetchSectionContactsComplection:^(BOOL succeed, NSArray<KKSectionPerson *> *contacts, NSArray<NSString *> *keys) {
        __strong typeof(weakSelf)strongSelf = weakSelf ;
        if (strongSelf.sectionContactChangeHanlder){
            strongSelf.sectionContactChangeHanlder(succeed, contacts, keys);
        }
    }];
}

@end













@implementation KKContactManager(BKSelectContact)

- (BOOL)checkCanAddPerson{
    NSInteger selCount = 0 ;
    for(KKPerson *person in self.selPersonArray){
        for(KKPhone *phone in person.phoneArray){
            if(phone.isSelected){
                selCount ++ ;
            }
        }
    }
    return selCount < self.maxSelectCount;
}

//检查是否已经添加
- (BOOL)checkExistWithNumberId:(NSString *)numberIdStr phoneNumber:(NSString *)phoneNumber{
    for(KKPerson *person in self.selPersonArray){
        for(KKPhone *phone in person.phoneArray){
            if(phone.isSelected && [phone.phoneNumber isEqualToString:phoneNumber]){
                return YES ;
            }
        }
    }
    return NO ;
}

- (void)selectPersonWithPerson:(KKPerson *)person{
    for(KKPerson *targetPerson in self.selPersonArray){
        if([targetPerson.identifiler isEqualToString:person.identifiler]){
            return ;
        }
    }
    [self.selPersonArray safeAddObject:person];
}

- (void)deletePersonWithPerson:(KKPerson *)person{
    for(NSInteger i = 0 ; i < self.selPersonArray.count ; i++){
        KKPerson *targetPerson = [self.selPersonArray safeObjectAtIndex:i];
        if([targetPerson.identifiler isEqualToString:person.identifiler]){
            [self.selPersonArray safeRemoveObjectAtIndex:i];
            break ;
        }
    }
}

- (void)deletePersonWithIndex:(NSInteger)index{
    [self.selPersonArray safeRemoveObjectAtIndex:index];
}

- (void)deletePersonWithIdentifiler:(NSString *)identifiler numberId:(NSString *)numberId{
    for(NSInteger i = 0 ; i < self.selPersonArray.count ; i++){
        KKPerson *person = [self.selPersonArray safeObjectAtIndex:i];
        if([person.identifiler isEqualToString:identifiler]){
            for(KKPhone *phone in person.phoneArray){
                if([phone.identifier isEqualToString:numberId]){
                    phone.isSelected = NO ;
                }
            }
            //如果没有了选择的号码，需要从选择的联系人数组中删除
            BOOL shouldDelPerson = YES;
            for(KKPhone *phone in person.phoneArray){
                if(phone.isSelected){
                    shouldDelPerson = NO;
                    break ;
                }
            }
            if(shouldDelPerson){
                [self.selPersonArray safeRemoveObjectAtIndex:i];
            }
            break ;
        }
    }
}

- (void)savaSelectPersonToLocal{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.selPersonArray];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:KKSelectPersonData];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (NSArray<KKPerson *> *)getSelectPersonFromLocal{
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:KKSelectPersonData];
    NSArray *array = nil;
    if(data){
        array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return array;
}

- (NSArray<NSString *> *)getSelectPhoneNumber{
    NSMutableArray *array = [NSMutableArray new];
    for(KKPerson *person in self.selPersonArray){
        for(KKPhone *phone in person.phoneArray){
            if(phone.isSelected){
                [array safeAddObject:phone.phoneNumber];
            }
        }
    }
    return array;
}

//手动添加的人数
- (NSInteger)numberOfManualAdd{
    NSInteger manualAddCnt = 0 ;
    for(KKPerson *person in self.selPersonArray){
        for(KKPhone *phone in person.phoneArray){
            if(phone.isSelected){
                if(phone.isManualAdd){
                    manualAddCnt ++ ;
                }
            }
        }
    }
    return manualAddCnt;
}

//通讯录添加的人数
- (NSInteger)numberOfContactAdd{
    NSInteger contactAddCnt = 0 ;
    for(KKPerson *person in self.selPersonArray){
        for(KKPhone *phone in person.phoneArray){
            if(phone.isSelected){
                if(!phone.isManualAdd){
                    contactAddCnt ++ ;
                }
            }
        }
    }
    return contactAddCnt;
}

#pragma mark -- @property

static char maxSelectCountKey;
-(void)setMaxSelectCount:(NSInteger)maxSelectCount{
    objc_setAssociatedObject(self, &maxSelectCountKey, [NSNumber numberWithInteger:maxSelectCount], OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)maxSelectCount{
    return [(NSNumber *)objc_getAssociatedObject(self, &maxSelectCountKey) integerValue];
}

static char selPersonArrayKey;
- (void)setSelPersonArray:(NSMutableArray<KKPerson *> *)selPersonArray{
    if (selPersonArray) {
        objc_setAssociatedObject(self, &selPersonArrayKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &selPersonArrayKey, selPersonArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(NSMutableArray<KKPerson *> *)selPersonArray{
    NSMutableArray<KKPerson *> *array = objc_getAssociatedObject(self, &selPersonArrayKey);
    if(!array){
        array = [NSMutableArray arrayWithCapacity:0];
        NSArray *localArray = [self getSelectPersonFromLocal];
        if(localArray.count){
            [array addObjectsFromArray:localArray];
        }
        objc_setAssociatedObject(self, &selPersonArrayKey, array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

@end
