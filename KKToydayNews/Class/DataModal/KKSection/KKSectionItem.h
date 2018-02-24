//
//  KKSectionItem.h
//  KKToydayNews
//
//  Created by finger on 2017/8/8.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKModalBase.h"

@interface KKSectionItem : KKModalBase
@property(nonatomic,copy) NSString *category;
@property(nonatomic,copy) NSString *web_url;
@property(nonatomic,copy) NSString *flags;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *tip_new;
@property(nonatomic,copy) NSString *default_add;
@property(nonatomic,copy) NSString *concern_id;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,copy) NSString *icon_url;
@property(nonatomic,assign) CGSize titleSize;
@end
