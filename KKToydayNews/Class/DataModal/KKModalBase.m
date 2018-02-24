//
//  KKModalBase.m
//  KKToydayNews
//
//  Created by finger on 2017/9/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKModalBase.h"

@implementation KKModalBase

- (id)initWithCoder:(NSCoder *)decoder{
    if (self = [super init]) {
        [self mj_decode:decoder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    [self mj_encode:encoder];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return @"";
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
}

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    if ([oldValue isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return oldValue;
}

@end
