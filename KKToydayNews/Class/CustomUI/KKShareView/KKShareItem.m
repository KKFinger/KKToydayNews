//
//  KKShareItem.m
//  KKShareView
//
//  Created by finger on 2017/8/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKShareItem.h"

@implementation KKShareItem

- (instancetype)initWithShareType:(KKShareType)shareType iconImageName:(NSString *)iconImageName title:(NSString *)title{
    if(self = [super init]){
        self.shareType = shareType;
        self.shareIconName = iconImageName;
        self.title = title;
    }
    return self ;
}

@end
