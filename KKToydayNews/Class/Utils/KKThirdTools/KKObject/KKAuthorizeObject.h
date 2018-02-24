//
//  KKAuthorizeObject.h
//  KKToydayNews
//
//  Created by finger on 2018/2/16.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKAuthorizeObject : NSObject
@property(nonatomic,copy)NSString *userId;//用户唯一标识
@property(nonatomic,copy)NSString *gender;//性别
@property(nonatomic,copy)NSString *nickName;//用户名
@property(nonatomic,copy)NSString *headImgUrl;//用户头像链接
@end
