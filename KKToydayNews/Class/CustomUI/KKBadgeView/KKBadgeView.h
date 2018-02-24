//
//  KKBadgeView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKBadgeView : UIView
@property(nonatomic,assign)NSInteger badge;
@property(nonatomic,assign)BOOL showBadge;
@property(nonatomic)UIImage *image;
@property(nonatomic,copy)UIFont *badgeFont;
@property(nonatomic,copy)UIColor *badgeTextColor;
@property(nonatomic,copy)UIColor *badgeBgColor;
@end
