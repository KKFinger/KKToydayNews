//
//  UIView+Masonry.h
//  TXMedicalCircle
//
//  Created by kkfinger on 2018/6/20.
//  Copyright © 2018年 kkfinger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Masonry)
- (NSArray *)masMakeConstraints:(void(^)(MASConstraintMaker *make))block;
- (NSArray *)masUpdateConstraints:(void(^)(MASConstraintMaker *make))block;
- (NSArray *)masRemakeConstraints:(void(^)(MASConstraintMaker *make))block;
@end
