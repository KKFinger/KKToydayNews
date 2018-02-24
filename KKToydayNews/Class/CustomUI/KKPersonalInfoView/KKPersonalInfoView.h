//
//  KKPersonalInfoView.h
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDragableNavBaseView.h"

typedef void(^willDissmissBlock)(void);

@interface KKPersonalInfoView : KKDragableNavBaseView
- (instancetype)initWithUserId:(NSString *)userId willDissmissBlock:(willDissmissBlock)willDissmissBlock;
@end
