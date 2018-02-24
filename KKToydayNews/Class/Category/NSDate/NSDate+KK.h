//
//  NSDate+KK.h
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (KK)
//转为时间字符串 , // @"yyyy-MM-dd HH:mm:ss"
- (NSString *)stringWithFormat:(NSString *)aFormat;

//系统开机距离当前时间的时间间隔
+ (long long)uptimeFun;

//将日期转换为当前时区的日期
- (NSDate *)localTimeDate;

//是否是同一天
- (BOOL)isSameDay:(NSDate *)date;

//判断是否 今天，明天，后天，不是 返回星期 eg:2014-04-16，星期三，16:40
- (NSString *)detailDateStringWithDate:(NSDate *)todayDate;

@end

#define SECOND	(1)
#define MINUTE	(60 * SECOND)
#define HOUR	(60 * MINUTE)
#define DAY		(24 * HOUR)
#define MONTH	(30 * DAY)
#define YEAR	(365 * DAY)
static NSArray *XY_weekdays = nil;

@interface NSDate (XY)

@property (nonatomic, readonly) NSInteger	year;
@property (nonatomic, readonly) NSInteger	month;
@property (nonatomic, readonly) NSInteger	day;
@property (nonatomic, readonly) NSInteger	hour;
@property (nonatomic, readonly) NSInteger	minute;
@property (nonatomic, readonly) NSInteger	second;
@property (nonatomic, readonly) NSInteger	weekday;

@property (nonatomic, readonly) NSString	*stringWeekday;

+ (NSDate *)dateWithString:(NSString *)string;
+ (NSDate *)now;

@end
