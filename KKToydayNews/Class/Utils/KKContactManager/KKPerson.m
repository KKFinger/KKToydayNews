//
//  KKPerson.m
//  KKToydayNews
//
//  Created by finger on 2017/11/28.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPerson.h"

@implementation KKPerson

- (instancetype)initWithCNContact:(CNContact *)contact{
    self = [super init];
    if (self){
        self.identifiler = contact.identifier;
        self.contactType = contact.contactType == CNContactTypePerson ? KKContactTypePerson : KKContactTypeOrigination;
        self.familyName = contact.familyName;
        self.givenName = contact.givenName;
        self.nameSuffix = contact.nameSuffix;
        self.namePrefix = contact.namePrefix;
        self.nickname = contact.nickname;
        self.middleName = contact.middleName;
        self.fullName = [CNContactFormatter stringFromContact:contact style:CNContactFormatterStyleFullName];
        if(!self.fullName.length){
            self.fullName = @"未知";
        }
        
        if ([contact isKeyAvailable:CNContactOrganizationNameKey]){
            self.organizationName = contact.organizationName;
        }

        if ([contact isKeyAvailable:CNContactDepartmentNameKey]){
            self.departmentName = contact.departmentName;
        }
        
        if ([contact isKeyAvailable:CNContactJobTitleKey]){
            self.jobTitle = contact.jobTitle;
        }
        
        if ([contact isKeyAvailable:CNContactNoteKey]){
            self.note = contact.note;
        }
        
        if ([contact isKeyAvailable:CNContactPhoneticFamilyNameKey]){
            self.phoneticFamilyName = contact.phoneticFamilyName;
        }
        
        if ([contact isKeyAvailable:CNContactPhoneticGivenNameKey]){
            self.phoneticGivenName = contact.phoneticGivenName;
        }
        
        if ([contact isKeyAvailable:CNContactPhoneticMiddleNameKey]){
            self.phoneticMiddleName = contact.phoneticMiddleName;
        }
        
        if ([contact isKeyAvailable:CNContactImageDataKey]){
            self.imageData = contact.imageData;
            self.image = [UIImage imageWithData:contact.imageData];
        }
        
        if ([contact isKeyAvailable:CNContactThumbnailImageDataKey]){
            self.thumbnailImageData = contact.thumbnailImageData;
            self.thumbnailImage = [UIImage imageWithData:contact.thumbnailImageData];
        }
        
        if ([contact isKeyAvailable:CNContactPhoneNumbersKey]){
            // 号码
            NSMutableArray *phones = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.phoneNumbers){
                KKPhone *phoneModel = [[KKPhone alloc] initWithLabeledValue:labeledValue];
                [phones addObject:phoneModel];
            }
            self.phoneArray = phones;
        }
        
        if ([contact isKeyAvailable:CNContactEmailAddressesKey]){
            // 电子邮件
            NSMutableArray *emails = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.emailAddresses){
                KKEmail *emailModel = [[KKEmail alloc] initWithLabeledValue:labeledValue];
                [emails addObject:emailModel];
            }
            self.emails = emails;
        }
        
        if ([contact isKeyAvailable:CNContactPostalAddressesKey]){
            // 地址
            NSMutableArray *addresses = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.postalAddresses){
                KKAddress *addressModel = [[KKAddress alloc] initWithLabeledValue:labeledValue];
                [addresses addObject:addressModel];
            }
            self.addresses = addresses;
        }
        
        // 生日
        KKBirthday *birthday = [[KKBirthday alloc] initWithCNContact:contact];
        self.birthday = birthday;
        
        if ([contact isKeyAvailable:CNContactInstantMessageAddressesKey]){
            // 即时通讯
            NSMutableArray *messages = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.instantMessageAddresses){
                KKMessage *messageModel = [[KKMessage alloc] initWithLabeledValue:labeledValue];
                [messages addObject:messageModel];
            }
            self.messages = messages;
        }
        
        if ([contact isKeyAvailable:CNContactSocialProfilesKey]){
            // 社交
            NSMutableArray *socials = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.socialProfiles){
                KKSocialProfile *socialModel = [[KKSocialProfile alloc] initWithLabeledValue:labeledValue];
                [socials addObject:socialModel];
            }
            self.socials = socials;
        }
        
        if ([contact isKeyAvailable:CNContactRelationsKey]){
            // 关联人
            NSMutableArray *relations = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.contactRelations){
                KKContactRelation *relationModel = [[KKContactRelation alloc] initWithLabeledValue:labeledValue];
                [relations addObject:relationModel];
            }
            self.relations = relations;
        }
        
        if ([contact isKeyAvailable:CNContactUrlAddressesKey]){
            // URL
            NSMutableArray *urlAddresses = [NSMutableArray array];
            for (CNLabeledValue *labeledValue in contact.urlAddresses){
                KKUrlAddress *urlModel = [[KKUrlAddress alloc] initWithLabeledValue:labeledValue];
                [urlAddresses addObject:urlModel];
            }
            self.urls = urlAddresses;
        }
    }
    return self;
}

- (instancetype)initWithRecord:(ABRecordRef)record{
    self = [super init];
    if (self){
        CFNumberRef type = ABRecordCopyValue(record, kABPersonKindProperty);
        self.contactType = type == kABPersonKindPerson ? KKContactTypePerson : KKContactTypeOrigination;
        CFRelease(type);
        
        NSString *fullName = CFBridgingRelease(ABRecordCopyCompositeName(record));
        NSString *firstName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNameProperty));
        NSString *lastName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNameProperty));
        NSString *namePrefix = CFBridgingRelease(ABRecordCopyValue(record, kABPersonPrefixProperty));
        NSString *nameSuffix = CFBridgingRelease(ABRecordCopyValue(record, kABPersonSuffixProperty));
        NSString *nickname = CFBridgingRelease(ABRecordCopyValue(record, kABPersonNicknameProperty));
        NSString *middleName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonMiddleNameProperty));
        NSString *organizationName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonOrganizationProperty));
        NSString *departmentName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonDepartmentProperty));
        NSString *jobTitle = CFBridgingRelease(ABRecordCopyValue(record, kABPersonJobTitleProperty));
        NSString *note = CFBridgingRelease(ABRecordCopyValue(record, kABPersonNoteProperty));
        NSString *phoneticFamilyName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonFirstNamePhoneticProperty));
        NSString *phoneticGivenName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonLastNamePhoneticProperty));
        NSString *phoneticMiddleName = CFBridgingRelease(ABRecordCopyValue(record, kABPersonMiddleNamePhoneticProperty));
        NSData *imageData = CFBridgingRelease(ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatOriginalSize));
        NSData *thumbnailImageData = CFBridgingRelease(ABPersonCopyImageDataWithFormat(record, kABPersonImageFormatThumbnail));
        NSDate *creationDate = CFBridgingRelease(ABRecordCopyValue(record, kABPersonCreationDateProperty));
        NSDate *modificationDate = CFBridgingRelease(ABRecordCopyValue(record, kABPersonModificationDateProperty));
        NSInteger lookupforkey =(NSInteger)ABRecordGetRecordID(record);//读取通讯录中联系人的唯一标识
        
        self.familyName = firstName;
        self.givenName = lastName;
        self.namePrefix = namePrefix;
        self.nameSuffix = nameSuffix;
        self.nickname = nickname;
        self.middleName = middleName;
        self.organizationName = organizationName;
        self.departmentName = departmentName;
        self.jobTitle = jobTitle;
        self.note = note;
        self.phoneticFamilyName = phoneticFamilyName;
        self.phoneticMiddleName = phoneticMiddleName;
        self.phoneticGivenName = phoneticGivenName;
        self.imageData = imageData;
        self.image = [UIImage imageWithData:imageData];
        self.thumbnailImageData = thumbnailImageData;
        self.thumbnailImage = [UIImage imageWithData:thumbnailImageData];
        self.creationDate = creationDate;
        self.modificationDate = modificationDate;
        self.identifiler = [NSString stringWithFormat:@"%ld",lookupforkey];
        self.fullName = fullName;
        if(!self.fullName.length){
            self.fullName = @"未知";
        }
        
        // 号码
        ABMultiValueRef multiPhones = ABRecordCopyValue(record, kABPersonPhoneProperty);
        CFIndex phoneCount = ABMultiValueGetCount(multiPhones);
        NSMutableArray *phones = [NSMutableArray array];
        for (CFIndex i = 0; i < phoneCount; i++){
            KKPhone *phoneModel = [[KKPhone alloc] initWithMultiValue:multiPhones index:i];
            [phones addObject:phoneModel];
        }
        CFRelease(multiPhones);
        self.phoneArray = phones;
        
        // 电子邮件
        ABMultiValueRef multiEmails = ABRecordCopyValue(record, kABPersonEmailProperty);
        CFIndex emailCount = ABMultiValueGetCount(multiEmails);
        NSMutableArray *emails = [NSMutableArray array];
        for (CFIndex i = 0; i < emailCount; i++){
            KKEmail *emailModel = [[KKEmail alloc] initWithMultiValue:multiEmails index:i];
            [emails addObject:emailModel];
        }
        CFRelease(multiEmails);
        self.emails = emails;
        
        // 地址
        ABMultiValueRef multiAddresses = ABRecordCopyValue(record, kABPersonAddressProperty);
        CFIndex addressCount = ABMultiValueGetCount(multiAddresses);
        NSMutableArray *addresses = [NSMutableArray array];
        for (CFIndex i = 0; i < addressCount; i++){
            KKAddress *addressModel = [[KKAddress alloc] initWithMultiValue:multiAddresses index:i];
            [addresses addObject:addressModel];
        }
        CFRelease(multiAddresses);
        self.addresses = addresses;
        
        // 生日
        KKBirthday *birthday = [[KKBirthday alloc] initWithRecord:record];
        self.birthday = birthday;
        
        // 即时通讯
        ABMultiValueRef multiMessages = ABRecordCopyValue(record, kABPersonInstantMessageProperty);
        CFIndex messageCount = ABMultiValueGetCount(multiMessages);
        NSMutableArray *messages = [NSMutableArray array];
        for (CFIndex i = 0; i < messageCount; i++){
            KKMessage *messageModel = [[KKMessage alloc] initWithMultiValue:multiMessages index:i];
            [messages addObject:messageModel];
        }
        CFRelease(multiMessages);
        self.messages = messages;
        
        // 社交
        ABMultiValueRef multiSocials = ABRecordCopyValue(record, kABPersonSocialProfileProperty);
        CFIndex socialCount = ABMultiValueGetCount(multiSocials);
        NSMutableArray *socials = [NSMutableArray array];
        for (CFIndex i = 0; i < socialCount; i++){
            KKSocialProfile *socialModel = [[KKSocialProfile alloc] initWithMultiValue:multiSocials index:i];
            [socials addObject:socialModel];
        }
        CFRelease(multiSocials);
        self.socials = socials;
        
        // 关联人
        ABMultiValueRef multiRelations = ABRecordCopyValue(record, kABPersonRelatedNamesProperty);
        CFIndex relationCount = ABMultiValueGetCount(multiRelations);
        NSMutableArray *relations = [NSMutableArray array];
        for (CFIndex i = 0; i < relationCount; i++){
            KKContactRelation *relationModel = [[KKContactRelation alloc] initWithMultiValue:multiRelations index:i];
            [relations addObject:relationModel];
        }
        CFRelease(multiRelations);
        self.relations = relations;
        
        // URL
        ABMultiValueRef multiURLs = ABRecordCopyValue(record, kABPersonURLProperty);
        CFIndex urlCount = ABMultiValueGetCount(multiURLs);
        NSMutableArray *urls = [NSMutableArray array];
        for (CFIndex i = 0; i < urlCount; i ++){
            KKUrlAddress *urlModel = [[KKUrlAddress alloc] initWithMultiValue:multiURLs index:i];
            [urls addObject:urlModel];
        }
        CFRelease(multiURLs);
        self.urls = urls;
    }
    return self;
}

#pragma mark -- 联系人的唯一标识

- (NSString *)identifiler{
    if(!_identifiler){
        _identifiler = [NSString stringWithFormat:@"%@-%@",self.fullName,self.phoneArray.firstObject.phoneNumber];
    }
    return _identifiler;
}

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////





#pragma mark -- 电话号码

@implementation KKPhone

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue{
    self = [super init];
    if (self){
        CNPhoneNumber *phoneValue = labeledValue.value;
        NSString *phoneNumber = phoneValue.stringValue;
        self.identifier = labeledValue.identifier;
        self.phoneNumber = [self filterSpecialString:phoneNumber];
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
    }
    return self;
}

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index{
    self = [super init];
    if (self){
        CFStringRef label = ABMultiValueCopyLabelAtIndex(multiValue, index);
        self.label = CFBridgingRelease(ABAddressBookCopyLocalizedLabel(label));
        NSString *phoneNumber = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiValue, index));
        self.phoneNumber = [self filterSpecialString:phoneNumber];
        self.identifier = [NSString stringWithFormat:@"%d",ABMultiValueGetIdentifierAtIndex(multiValue,index)];
        CFRelease(label);
    }
    return self;
}

- (NSString *)filterSpecialString:(NSString *)string{
    if (string == nil){
        return @"";
    }
    string = [string stringByReplacingOccurrencesOfString:@"+86" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return string;
}

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////





#pragma mark -- 电子邮件

@implementation KKEmail

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue{
    self = [super init];
    if (self){
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
        self.email = labeledValue.value;
    }
    return self;
}

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index{
    self = [super init];
    if (self){
        CFStringRef label = ABMultiValueCopyLabelAtIndex(multiValue, index);
        CFStringRef localLabel = ABAddressBookCopyLocalizedLabel(label);
        CFRelease(label);
        self.label = CFBridgingRelease(localLabel);
        NSString *emial = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiValue, index));
        self.email = emial;
    }
    return self;
}

@end






//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////





#pragma mark -- 地址

@implementation KKAddress

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue{
    self = [super init];
    if (self){
        CNPostalAddress *addressValue = labeledValue.value;
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
        self.street = addressValue.street;
        self.state = addressValue.state;
        self.city = addressValue.city;
        self.postalCode = addressValue.postalCode;
        self.country = addressValue.country;
        self.ISOCountryCode = addressValue.ISOCountryCode;
        self.formatterAddress = [CNPostalAddressFormatter stringFromPostalAddress:addressValue style:CNPostalAddressFormatterStyleMailingAddress];
    }
    return self;
}

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index{
    self = [super init];
    if (self){
        CFStringRef label = ABMultiValueCopyLabelAtIndex(multiValue, index);
        CFStringRef localLabel = ABAddressBookCopyLocalizedLabel(label);
        CFRelease(label);
        self.label = CFBridgingRelease(localLabel);
        
        NSDictionary *dict = CFBridgingRelease((ABMultiValueCopyValueAtIndex(multiValue, index)));
        self.country = [dict valueForKey:(__bridge NSString *)kABPersonAddressCountryKey];
        self.city = [dict valueForKey:(__bridge NSString *)kABPersonAddressCityKey];
        self.state = [dict valueForKey:(__bridge NSString *)kABPersonAddressStateKey];
        self.street = [dict valueForKey:(__bridge NSString *)kABPersonAddressStreetKey];
        self.postalCode = [dict valueForKey:(__bridge NSString *)kABPersonAddressZIPKey];
        self.ISOCountryCode = [dict valueForKey:(__bridge NSString *)kABPersonAddressCountryCodeKey];
    }
    return self;
}

@end







//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////





#pragma mark -- 生日

@implementation KKBirthday

- (instancetype)initWithCNContact:(CNContact *)contact{
    self = [super init];
    if (self){
        if ([contact isKeyAvailable:CNContactBirthdayKey]){
            self.brithdayDate = contact.birthday.date;
        }
        if ([contact isKeyAvailable:CNContactNonGregorianBirthdayKey]){
            self.calendarIdentifier = contact.nonGregorianBirthday.calendar.calendarIdentifier;
            self.era = contact.nonGregorianBirthday.era;
            self.day = contact.nonGregorianBirthday.day;
            self.month = contact.nonGregorianBirthday.month;
            self.year = contact.nonGregorianBirthday.year;
        }
    }
    return self;
}

- (instancetype)initWithRecord:(ABRecordRef)record{
    self = [super init];
    if (self){
        self.brithdayDate = CFBridgingRelease(ABRecordCopyValue(record, kABPersonBirthdayProperty));
        
        NSDictionary *dict = CFBridgingRelease((ABRecordCopyValue(record, kABPersonAlternateBirthdayProperty)));
        self.calendarIdentifier = [dict valueForKey:@"calendarIdentifier"];
        self.era = [(NSNumber *)[dict valueForKey:@"era"] integerValue];
        self.year = [(NSNumber *)[dict valueForKey:@"year"] integerValue];
        self.month = [(NSNumber *)[dict valueForKey:@"month"] integerValue];
        self.day = [(NSNumber *)[dict valueForKey:@"day"] integerValue];
    }
    return self;
}

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////





#pragma mark -- 即时通信

@implementation KKMessage

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue{
    self = [super init];
    if (self){
        CNInstantMessageAddress *messageValue = labeledValue.value;
        self.service = messageValue.service;
        self.userName = messageValue.username;
    }
    return self;
}

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index{
    self = [super init];
    if (self){
        NSDictionary *dict = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiValue, index));
        self.service = [dict valueForKey:@"service"];
        self.userName = [dict valueForKey:@"username"];
    }
    return self;
}

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////





#pragma mark -- 社交

@implementation KKSocialProfile

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue{
    self = [super init];
    if (self){
        CNSocialProfile *socialValue = labeledValue.value;
        self.service = socialValue.service;
        self.username = socialValue.username;
        self.urlString = socialValue.urlString;
    }
    return self;
}

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index{
    self = [super init];
    if (self){
        NSDictionary *dict = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiValue, index));
        self.service = [dict valueForKey:@"service"];
        self.username = [dict valueForKey:@"username"];
        self.urlString = [dict valueForKey:@"url"];
    }
    return self;
}

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////




#pragma mark -- URL

@implementation KKUrlAddress

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue{
    self = [super init];
    if (self){
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];
        self.urlString = labeledValue.value;
    }
    return self;
}

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index{
    self = [super init];
    if (self){
        CFStringRef label = ABMultiValueCopyLabelAtIndex(multiValue, index);
        CFStringRef localLabel = ABAddressBookCopyLocalizedLabel(label);
        CFRelease(label);
        self.label = CFBridgingRelease(localLabel);
        self.urlString = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiValue, index));
    }
    return self;
}

@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////




#pragma mark -- 关联人

@implementation KKContactRelation

- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue{
    self = [super init];
    if (self){
        CNContactRelation *relationValue = labeledValue.value;
        self.label = [CNLabeledValue localizedStringForLabel:labeledValue.label];;
        self.name = relationValue.name;
    }
    return self;
}

- (instancetype)initWithMultiValue:(ABMultiValueRef)multiValue index:(CFIndex)index{
    self = [super init];
    if (self){
        CFStringRef label = ABMultiValueCopyLabelAtIndex(multiValue, index);
        CFStringRef localLabel = ABAddressBookCopyLocalizedLabel(label);
        CFRelease(label);
        self.label = CFBridgingRelease(localLabel);
        self.name = CFBridgingRelease(ABMultiValueCopyValueAtIndex(multiValue, index));
    }
    return self;
}

@end

@implementation KKSectionPerson


@end





//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////选择联系人相关//////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////

@implementation KKPerson(BKSelectContact)

static char isMulitSelectedKey;

-(void)setIsMulitSelected:(BOOL)isMulitSelected{
    objc_setAssociatedObject(self, &isMulitSelectedKey, [NSNumber numberWithBool:isMulitSelected], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isMulitSelected{
    return [(NSNumber *)objc_getAssociatedObject(self, &isMulitSelectedKey) boolValue];
}

@end

@implementation KKPhone(BKSelectContact)

static char isSelectedKey;
static char isManualAddKey;

-(void)setIsSelected:(BOOL)isSelected{
    objc_setAssociatedObject(self, &isSelectedKey, [NSNumber numberWithBool:isSelected], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isSelected{
    return [(NSNumber *)objc_getAssociatedObject(self, &isSelectedKey) boolValue];
}

- (void)setIsManualAdd:(BOOL)isManualAdd{
    objc_setAssociatedObject(self, &isManualAddKey, [NSNumber numberWithBool:isManualAdd], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isManualAdd{
    return [(NSNumber *)objc_getAssociatedObject(self, &isManualAddKey) boolValue];
}

@end
