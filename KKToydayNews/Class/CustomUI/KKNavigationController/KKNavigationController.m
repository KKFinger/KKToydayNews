//
//  KKNavigationController.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKNavigationController.h"
#import "KKCommonDevice.h"

@interface KKNavigationController ()

@end

@implementation KKNavigationController

+(void)initialize{
    UINavigationBar *navigationBar = [UINavigationBar appearance];
    //设置文字样式
    [navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"Helvetica Blod" size:18],NSFontAttributeName, nil]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationBar setShadowImage:[[UIImage alloc]init]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -- 压入视图

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [super pushViewController:viewController animated:animated];
    
    if (viewController.navigationItem.leftBarButtonItem == nil && self.viewControllers.count>1){
        NSArray *controllers = self.viewControllers;
        NSString *parentTitle = [[[controllers objectAtIndex:controllers.count - 2] navigationItem] title];
        viewController.navigationItem.leftBarButtonItem = [self createBackItemWithTitle:parentTitle];
    }
}

#pragma mark -- 返回按钮

- (UIBarButtonItem *)createBackItemWithTitle:(NSString *)title{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.frame = CGRectMake(0, 0, 12, 20);
    if (title != nil){
        backButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        [backButton setTitle:title forState:UIControlStateNormal];
        [backButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    }
    [backButton setImage:[UIImage imageNamed:@"backItem"] forState:UIControlStateNormal];
    [backButton setImage:[[UIImage imageNamed:@"backItem"] imageWithAlpha:0.5] forState:UIControlStateHighlighted];
    [backButton setTitleEdgeInsets:UIEdgeInsetsMake(0,5,0, 0)];
    [backButton setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin];
    [backButton addTarget:self action:@selector(popSelf) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    return backItem;
}

- (void)popSelf{
    [self popViewControllerAnimated:YES];
}

#pragma mark -- 视频播放器，屏幕旋转相关

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

@end

@implementation UINavigationController (KKNavigationNavUI)

#pragma mark -- 设置导航栏背景色

- (void)setNavBackgroundColor:(UIColor *)color{
    UIImage *image = [UIImage imageWithColor:KKColor(212, 60, 61, 1.0)];
    
    float iosVersion = [[KKCommonDevice systemVersion] floatValue];
    if (iosVersion<8.0 && iosVersion >= 7.0){
        [self.navigationBar setBackgroundImage:image forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    }else{
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
}

@end
