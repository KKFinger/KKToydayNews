//
//  NSDate+MC.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "NSDate+KK.h"
#include <sys/sysctl.h>
#import <objc/runtime.h>

@implementation NSDate (KK)

- (NSString *)stringWithFormat:(NSString *)aFormat{
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:aFormat];
    NSString *dateStr = [timeFormat stringFromDate:self];
    return dateStr;
}

+ (long long)uptimeFun{
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;
    (void)time(&now);
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptime = now - boottime.tv_sec;
    }
    return uptime;
}

- (NSDate *)localTimeDate{
    NSTimeZone *nowTimeZone = [NSTimeZone localTimeZone];
    long timeOffset = [nowTimeZone secondsFromGMTForDate:self];
    NSDate *newDate = [self dateByAddingTimeInterval:timeOffset];
    return newDate;
}

- (NSUInteger)year{
    return [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitYear inUnit:NSCalendarUnitEra forDate:self];
}

- (NSUInteger)month{
    return [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitMonth inUnit:NSCalendarUnitYear forDate:self];
}

- (NSUInteger)monthday{
    return [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self];
}

- (BOOL)isSameDay:(NSDate *)date{
    if (date == nil) {
        return NO;
    }
    return ([self year] == [date year]) && ([self month] == [date month]) && ([self monthday] == [date monthday]);
}

//判断是否 今天，明天，后天，不是 返回星期 eg:2014-04-16，星期三，16:40
- (NSString *)detailDateStringWithDate:(NSDate *)todayDate{
    NSString *dayStr = @"";
    if ([self isSameDay:todayDate]) {
        dayStr = @"yyyy-MM-dd,今天,HH:mm";
    } else if ([self isSameDay:[todayDate dateByAddingTimeInterval:60 * 60 *24]]) {
        dayStr = @"yyyy-MM-dd,明天,HH:mm";
    } else if ([self isSameDay:[todayDate dateByAddingTimeInterval:60 * 60 *24 *2]]) {
        dayStr = @"yyyy-MM-dd,后天,HH:mm";
    } else {
        dayStr = @"yyyy-MM-dd,EEEE,HH:mm";
    }
    NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:dayStr];
    NSString *dayDetail = [timeFormat stringFromDate:self];
    NSString *subStr = [dayDetail substringFromIndex:11];
    NSString *comPareStr = [subStr substringToIndex:[subStr length] - 6];
    if ([comPareStr isEqualToString:@"Monday"]) {
        dayDetail = [dayDetail stringByReplacingOccurrencesOfString:comPareStr withString:@"星期一"];
    } else if ([comPareStr isEqualToString:@"Tuesday"]) {
        dayDetail = [dayDetail stringByReplacingOccurrencesOfString:comPareStr withString:@"星期二"];
    } else if ([comPareStr isEqualToString:@"Wednesday"]) {
        dayDetail = [dayDetail stringByReplacingOccurrencesOfString:comPareStr withString:@"星期三"];
    } else if ([comPareStr isEqualToString:@"Thursday"]) {
        dayDetail = [dayDetail stringByReplacingOccurrencesOfString:comPareStr withString:@"星期四"];
    } else if ([comPareStr isEqualToString:@"Friday"]) {
        dayDetail = [dayDetail stringByReplacingOccurrencesOfString:comPareStr withString:@"星期五"];
    } else if ([comPareStr isEqualToString:@"Saturday"]) {
        dayDetail = [dayDetail stringByReplacingOccurrencesOfString:comPareStr withString:@"星期六"];
    } else if ([comPareStr isEqualToString:@"Sunday"]) {
        dayDetail = [dayDetail stringByReplacingOccurrencesOfString:comPareStr withString:@"星期日"];
    }
    return dayDetail;
}

@end

@implementation NSDate (XY)

@dynamic year;
@dynamic month;
@dynamic day;
@dynamic hour;
@dynamic minute;
@dynamic second;
@dynamic weekday;
@dynamic stringWeekday;

+ (void)load{
    XY_weekdays = @[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
}

#pragma mark - private

+ (NSCalendar *)AZ_currentCalendar {
    // 你使用NSThread的threadDictionary方法来检索一个NSMutableDictionary对象，你可以在它里面添加任何线程需要的键。每个线程都维护了一个键-值的字典，它可以在线程里面的任何地方被访问。你可以使用该字典来保存一些信息，这些信息在整个线程的执行过程中都保持不变。
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSCalendar *currentCalendar     = [dictionary objectForKey:@"AZ_currentCalendar"];
    if (currentCalendar == nil){
        currentCalendar = [NSCalendar currentCalendar];
        [dictionary setObject:currentCalendar forKey:@"AZ_currentCalendar"];
    }
    
    return currentCalendar;
}

#pragma mark -

- (NSInteger)year{
    return [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                           fromDate:self].year;
}

- (NSInteger)month{
    return [[NSCalendar currentCalendar] components:NSCalendarUnitMonth
                                           fromDate:self].month;
}

- (NSInteger)day{
    return [[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                           fromDate:self].day;
}

- (NSInteger)hour{
    return [[NSCalendar currentCalendar] components:NSCalendarUnitHour
                                           fromDate:self].hour;
}

- (NSInteger)minute{
    return [[NSCalendar currentCalendar] components:NSCalendarUnitMinute
                                           fromDate:self].minute;
}

- (NSInteger)second{
    return [[NSCalendar currentCalendar] components:NSCalendarUnitSecond
                                           fromDate:self].second;
}

- (NSInteger)weekday{
    return [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday
                                           fromDate:self].weekday;
}

-(NSString *) stringWeekday{
    return XY_weekdays[self.weekday - 1];
}


+ (NSDate *)dateWithString:(NSString *)string{
    return nil;
}

+ (NSDate *)now{
    return [NSDate date];
}

@end
