//
//  KKImageDescView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKAttriTextData.h"

@interface KKImageDescView : UIScrollView
- (void)refreshViewAttriData:(KKAttriTextData *)data;
+ (CGFloat)descTextWidth;
@end
