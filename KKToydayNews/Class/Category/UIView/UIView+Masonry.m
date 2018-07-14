//
//  UIView+Masonry.m
//  TXMedicalCircle
//
//  Created by kkfinger on 2018/6/20.
//  Copyright © 2018年 kkfinger. All rights reserved.
//

#import "UIView+Masonry.h"

@implementation UIView(Masonry)

- (NSArray *)masMakeConstraints:(void(^)(MASConstraintMaker *make))block {
    if(!self.superview){
        return nil;
    }
    return [self mas_makeConstraints:block];
}

- (NSArray *)masUpdateConstraints:(void(^)(MASConstraintMaker *make))block {
    if(!self.superview){
        return nil;
    }
    return [self mas_updateConstraints:block];
}

- (NSArray *)masRemakeConstraints:(void(^)(MASConstraintMaker *make))block {
    if(!self.superview){
        return nil;
    }
    return [self mas_remakeConstraints:block];
}

@end
