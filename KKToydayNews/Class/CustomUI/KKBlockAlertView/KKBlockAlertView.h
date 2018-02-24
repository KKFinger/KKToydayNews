//
//  KKBlockAlertView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/13.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^KKAlertBlock)(NSInteger re_code , NSDictionary *userInfo);

@interface KKBlockAlertView : NSObject

- (void)showWithTitle:( NSString *)title
              message:( NSString *)message
    cancelButtonTitle:( NSString *)cancelButtonTitle
    otherButtonTitles:( NSString *)otherButtonTitles
                block:(KKAlertBlock)handler;

- (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSString *)otherButtonTitles
              timeout:(NSTimeInterval)timeout
                block:(KKAlertBlock)handler;

@end
