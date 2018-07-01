//
//  KKImageDescView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYTextContainer.h"

@interface KKImageDescView : UIScrollView
- (void)refreshViewAttriData:(TYTextContainer *)data;
+ (CGFloat)descTextWidth;
@end
