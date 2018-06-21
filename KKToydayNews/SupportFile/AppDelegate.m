//
//  AppDelegate.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "AppDelegate.h"
#import "KKTabBarController.h"
#import "KKThirdTools.h"
#import "AppDelegate+KKPush.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    KKTabBarController *tabCtrl = [[KKTabBarController alloc]init];
    self.window.rootViewController = tabCtrl;
    
    //第三方平台注册
    [KKThirdTools registerPlatform:@[@(KKThirdPlatformWX),@(KKThirdPlatformQQ),@(KKThirdPlatformWeiBo)]];
    
    //注册通知
    [self registerPushNotification];
    
    //Bugly
    [Bugly startWithAppId:BuglyAppId];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
}

#pragma mark -- 第三方回调

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [KKThirdTools handlerOpenUrl:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation{
    return [KKThirdTools handlerOpenUrl:url];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    return [KKThirdTools handlerOpenUrl:url];
}

@end
