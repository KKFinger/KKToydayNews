//
//  UIView+ActivityIndicatorView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/3.
//  Copyright © 2017年 finger All rights reserved.
//

#import "UIView+ActivityIndicatorView.h"
#import <objc/runtime.h>
#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger,HUDState) {
    HUDStateNone,
    HUDStateLoading,
    HUDStateFinished,
};

@interface MBProgressHUD (CKAfterDelay)

@property(nonatomic,assign)HUDState state;

-(void)ck_show:(BOOL)animated afterDelay:(NSTimeInterval)delay duration:(NSTimeInterval)duration;
-(void)ck_hide:(BOOL)animated;
-(void)ck_hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;

@end


@implementation MBProgressHUD (CKAfterDelay)

SYNTHESIZE_CATEGORY_VALUE_PROPERTY(HUDState, state, setState:);

-(void)ck_show:(BOOL)animated afterDelay:(NSTimeInterval)delay duration:(NSTimeInterval)duration{
    if (delay > 0) {
        [self performSelector:@selector(ck_showDelayed:duration:)
                   withObject:[NSNumber numberWithBool:animated]
                   afterDelay:delay];
    }else{
        [self showAnimated:animated];
        if(duration != -1){
            [self performSelector:@selector(ck_hide:)
                       withObject:[NSNumber numberWithBool:animated]
                       afterDelay:duration];
        }
    }
}

- (void)ck_showDelayed:(NSNumber *)animated duration:(NSTimeInterval)duration{
    if (self.state == HUDStateFinished) {
        self.state = HUDStateNone;
    }else{
        self.state = HUDStateLoading;
        [self showAnimated:[animated boolValue]];
        if(duration != -1){
            [self performSelector:@selector(ck_hide:)
                       withObject:[NSNumber numberWithBool:animated]
                       afterDelay:duration];
        }
    }
}

-(void)ck_hide:(BOOL)animated{
    self.state = HUDStateFinished;
    [self hideAnimated:animated];
}

-(void)ck_hide:(BOOL)animated afterDelay:(NSTimeInterval)delay{
    self.state = HUDStateFinished;
    [self hideAnimated:animated afterDelay:delay];
}

@end


@implementation UIView (ActivityIndicatorView)

#pragma mark --提示消息

-(void)promptMessage:(NSString *)text{
    
    if (text.length == 0) {
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabel.text = text;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    hud.dimBackground=NO;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [UIColor blackColor];//背景色
    hud.contentColor = [UIColor whiteColor];//文字颜色
    
    [hud hideAnimated:YES afterDelay:1.f];
}

#pragma mark -- 开始加载提示(使用默认的加载样式，转菊花,背景色为黑色)

- (void)showActivityViewWithTitle:(NSString *)text{
    [self showActivityViewWithTitle:text enabled:YES afterDelay:0 duration:-1];
}

- (void)showActivityViewWithTitle:(NSString *)text afterDelay:(NSTimeInterval)delay{
    [self showActivityViewWithTitle:text enabled:YES afterDelay:delay duration:-1];
}

- (void)showActivityViewWithTitle:(NSString *)text enabled:(BOOL)enabled{
    [self showActivityViewWithTitle:text enabled:enabled afterDelay:0 duration:-1];
}

- (void)showActivityViewWithTitle:(NSString *)text enabled:(BOOL)enabled afterDelay:(NSTimeInterval)delay duration:(NSTimeInterval)duration{
    [self.activity hideAnimated:YES];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
    hud.detailsLabel.text = text;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    hud.removeFromSuperViewOnHide = YES;
    hud.backgroundColor = [UIColor clearColor];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [UIColor blackColor];//背景色
    hud.contentColor = [UIColor whiteColor];//文字颜色
    [self addSubview:hud];
    [hud ck_show:YES afterDelay:delay duration:duration];
    hud.userInteractionEnabled = enabled;
    self.activity=hud;
}

#pragma mark --  停止加载提示

- (void)hiddenActivity{
    [self hiddenActivityWithTitle:nil];
}

- (void)hiddenActivityWithTitle:(NSString *)text{
    [self hiddenActivityWithTitle:text afterDelay:1.f];
}

- (void)hiddenActivityWithTitle:(NSString *)text afterDelay:(NSTimeInterval)delay {
    if (text.length) {
        self.activity.mode = MBProgressHUDModeText;
        self.activity.detailsLabel.text = text;
        self.activity.detailsLabel.font = [UIFont systemFontOfSize:15];
        self.activity.backgroundColor = [UIColor clearColor];
        self.activity.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        self.activity.bezelView.color = [UIColor blackColor];//背景色
        [self.activity ck_hide:YES afterDelay:delay];
    }else{
        [self.activity ck_hide:YES];
    }
    self.activity = nil;
}

#pragma mark -- 加载自定义图片(图片旋转方式)

- (void)showActivityViewWithImage:(NSString *)imageName{
    [self showActivityViewWithImage:imageName text:nil];
}

- (void)showActivityViewWithImage:(NSString *)imageName text:(NSString *)text{
    [self showActivityViewWithImage:imageName text:text animate:YES duration:-1];
}

- (void)showActivityViewWithImage:(NSString *)imageName text:(NSString *)text animate:(BOOL)animate duration:(NSTimeInterval)duration{
    
    [self.activity hideAnimated:YES];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
    hud.mode = MBProgressHUDModeCustomView;
    hud.removeFromSuperViewOnHide = YES;
    hud.label.text = text;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    hud.backgroundColor = [UIColor clearColor];
    hud.userInteractionEnabled = YES;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    if(text.length){
        hud.bezelView.color = [UIColor blackColor];//背景色
    }else{
        hud.bezelView.color = [UIColor clearColor];//背景色
    }
    hud.contentColor = [UIColor whiteColor];//文字颜色
    hud.animationType = MBProgressHUDAnimationFade;
    
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    imgView.frame = CGRectMake(0, 0, 15, 15);
    if(animate){
        CABasicAnimation *anima = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        anima.toValue = @(M_PI*2);
        anima.duration = 1.0f;
        anima.repeatCount = MAXFLOAT;
        [imgView.layer addAnimation:anima forKey:nil];
    }
    hud.customView = imgView;
    
    [hud ck_show:YES afterDelay:0 duration:duration];
    
    self.activity = hud;
    
    [self addSubview:hud];
}

#pragma mark -- 加载系统样式

- (void)showSysActivityWithStyle:(UIActivityIndicatorViewStyle)style{
    [self.activity hideAnimated:YES];
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self];
    hud.mode = MBProgressHUDModeCustomView;
    hud.removeFromSuperViewOnHide = YES;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [UIColor clearColor];//背景色
    hud.animationType = MBProgressHUDAnimationFade;
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:style];
    [indicatorView startAnimating];
    hud.customView = indicatorView;
    
    [hud ck_show:YES afterDelay:0 duration:-1];
    
    self.activity = hud;
    
    [self addSubview:hud];
    
}

#pragma mark -- rumtime

static char activityKey;
-(void)setActivity:(MBProgressHUD *)activity{
    if (activity) {
        objc_setAssociatedObject(self, &activityKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &activityKey, activity, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(MBProgressHUD *)activity{
    MBProgressHUD *activity = objc_getAssociatedObject(self, &activityKey);
    return activity;
}

@end
