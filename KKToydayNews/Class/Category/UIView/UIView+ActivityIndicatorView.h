//
//  UIView+ActivityIndicatorView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/3.
//  Copyright © 2017年 finger All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ActivityIndicatorView)

@property(nonatomic,strong)MBProgressHUD *activity;

#pragma mark --提示消息

-(void)promptMessage:(NSString *)text;//当前显示

#pragma mark -- 开始加载提示(使用默认的加载样式，转菊花,背景色为黑色)

- (void)showActivityViewWithTitle:(NSString *)text afterDelay:(NSTimeInterval)delay;
- (void)showActivityViewWithTitle:(NSString *)text;//当前显示
- (void)showActivityViewWithTitle:(NSString *)text enabled:(BOOL)enabled;
- (void)showActivityViewWithTitle:(NSString *)text enabled:(BOOL)enabled afterDelay:(NSTimeInterval)delay duration:(NSTimeInterval)duration;//当前显示

#pragma mark -- 加载自定义图片(图片旋转方式)

- (void)showActivityViewWithImage:(NSString *)imageName;
- (void)showActivityViewWithImage:(NSString *)imageName text:(NSString *)text;
- (void)showActivityViewWithImage:(NSString *)imageName text:(NSString *)text animate:(BOOL)animate duration:(NSTimeInterval)duration;

#pragma mark -- 停止加载提示

- (void)hiddenActivity;
- (void)hiddenActivityWithTitle:(NSString *)text;
- (void)hiddenActivityWithTitle:(NSString *)text afterDelay:(NSTimeInterval)delay;

#pragma mark -- 加载系统样式

- (void)showSysActivityWithStyle:(UIActivityIndicatorViewStyle)style;

@end
