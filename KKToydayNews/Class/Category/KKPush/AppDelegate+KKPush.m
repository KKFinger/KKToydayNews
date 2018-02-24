//
//  AppDelegate+Push.m
//  KKToydayNews
//
//  Created by finger on 2018/2/21.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "AppDelegate+KKPush.h"
#import "KKThirdTools.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
@interface AppDelegate()<UNUserNotificationCenterDelegate>
@end
#endif

@implementation AppDelegate(KKPush)

#pragma mark -- 注册远程与本地通知

- (void)registerPushNotification{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue] ;
    if(systemVersion >= 10.0){
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center setDelegate:self];
        //请求通知授权
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {// 点击允许
                NSLog(@"注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    NSLog(@"%@", settings);
                }];

                //注册通知
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });

            } else {// 点击不允许
                NSLog(@"注册失败");
            }
        }];
    }else if(systemVersion >= 8.0 && systemVersion < 10.0){
        if([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
            // 定义用户通知类型(Remote.远程 - Badge.标记 Alert.提示 Sound.声音)
            UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            // 定义用户通知设置
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
            // 注册用户通知 - 根据用户通知设置
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }else{
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        // 注册远程通知 -根据远程通知类型
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
}

#pragma mark -- 注册远程通知（iOS8和iOS9,允许远程通知后调用）

/**/
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // 注册远程通知（推送）
    [application registerForRemoteNotifications];
}

#pragma mark -- 远程通知deviceToken回调

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(token.length){
        [[NSUserDefaults standardUserDefaults]setObject:token forKey:KKDeviceToken];
    }
    NSLog(@"******deviceToken:%@********", token);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"******deviceToken error:%@********", error.description);
}

#pragma mark -- iOS7 after & iOS10 before 接收到消息

//远程推送消息
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    if (application.applicationState == UIApplicationStateActive) {
        //app在前台，不会有声音和弹框
        NSLog(@"********app在前台:接收到通知:%@\n", userInfo);
    }else if(application.applicationState == UIApplicationStateInactive){
        //app在后台接收到通知，点击通知，唤醒app
        NSLog(@"********app在后台:接收到通知:%@\n", userInfo);
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

//本地消息
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSDictionary *userInfo = notification.userInfo ;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {//app处于前台
        NSLog(@"********app在前台:接收到本地通知:%@\n", userInfo);
    }else{//app处于后台
        NSLog(@"********app在后台:接收到本地通知:%@\n", userInfo);
    }
}

#pragma mark -- UNUserNotificationCenterDelegate(接收到消息，iOS10及以上)

//前台接收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //远程推送
        NSLog(@"app在前台，收到远程通知:{\n body:%@，\n title:%@,\n subtitle:%@,\n badge：%@，\n sound：%@，\n userInfo：%@ \n}",body,title,subtitle,badge,sound,userInfo);
    }else{
        //本地通知
        NSLog(@"app在前台，收到本地通知:{\n body:%@，\n title:%@,\n subtitle:%@,\n badge：%@，\n sound：%@，\n userInfo：%@ \n}",body,title,subtitle,badge,sound,userInfo);
        if([notification.request.trigger isKindOfClass:[UNTimeIntervalNotificationTrigger class]]){
            
        }else if([notification.request.trigger isKindOfClass:[UNCalendarNotificationTrigger class]]){
            
        }else if([notification.request.trigger isKindOfClass:[UNLocationNotificationTrigger class]]){
            
        }
    }
    
    //功能：可设置是否在应用内弹出通知
    completionHandler(UNNotificationPresentationOptionAlert|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound);
}

//用户点击通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //远程推送
        NSLog(@"app在后台，收到远程通知:{\n body:%@，\n title:%@,\n subtitle:%@,\n badge：%@，\n sound：%@，\n userInfo：%@ \n}",body,title,subtitle,badge,sound,userInfo);
    }else {
        //本地通知
        NSLog(@"app在后台，收到本地通知:{\n body:%@，\n title:%@,\n subtitle:%@,\n badge：%@，\n sound：%@，\n userInfo：%@ \n}",body,title,subtitle,badge,sound,userInfo);
        if([response.notification.request.trigger isKindOfClass:[UNTimeIntervalNotificationTrigger class]]){
            
        }else if([response.notification.request.trigger isKindOfClass:[UNCalendarNotificationTrigger class]]){
            
        }else if([response.notification.request.trigger isKindOfClass:[UNLocationNotificationTrigger class]]){
            
        }
    }
    
    completionHandler();
}

//#pragma mark -- 本地消息测试
//
//- (void)localNotify{
//    // 1.创建一个本地通知
//    UILocalNotification *localNote = [[UILocalNotification alloc] init];
//
//    // 1.1.设置通知发出的时间
//    localNote.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
//
//    // 1.2.设置通知内容
//    localNote.alertBody = @"这是一个推送这是一个推送";
//
//    // 1.3.设置锁屏时,字体下方显示的一个文字
//    localNote.alertAction = @"赶紧!!!!!";
//    localNote.hasAction = YES;
//
//    // 1.4.设置启动图片(通过通知打开的)
//    localNote.alertLaunchImage = @"../Documents/IMG_0024.jpg";
//
//    // 1.5.设置通过到来的声音
//    localNote.soundName = UILocalNotificationDefaultSoundName;
//
//    // 1.6.设置应用图标左上角显示的数字
//    localNote.applicationIconBadgeNumber = 999;
//
//    // 1.7.设置一些额外的信息
//    localNote.userInfo = @{@"qq" : @"704711253", @"msg" : @"success"};
//
//    // 2.执行通知
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
//}

//- (void)localNotifyIOS10{
//    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//    content.title = @"Introduction to Notifications";
//    content.subtitle = @"Session 707";
//    content.body = @"Woah! These new notifications look amazing! Don’t you agree?";
//    content.badge = @1;
//    content.sound = [UNNotificationSound defaultSound];
//    content.userInfo = @{@"qq" : @"704711253", @"msg" : @"success"};
//
//    //5秒后提醒，不重复
//    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
//
////    //每60秒提醒一次
////    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:60 repeats:YES];
//
////    //每周一早上 8：00 提醒我
////    NSDateComponents *components = [[NSDateComponents alloc] init];
////    components.weekday = 2;
////    components.hour = 8;
////    UNCalendarNotificationTrigger *trigger3 = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
////
////    CLRegion *region = [[CLRegion alloc] init];
////    UNLocationNotificationTrigger *trigger4 = [UNLocationNotificationTrigger triggerWithRegion:region repeats:NO];
//
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//
//    NSString *requestIdentifier = @"sampleRequest";
//    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier
//                                                                          content:content
//                                                                          trigger:trigger];
//    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//
//    }];
//}

@end
