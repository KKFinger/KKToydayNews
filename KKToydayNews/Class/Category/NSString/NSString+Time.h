//
//  NSString+Time.h
//  KKToydayNews
//
//  Created by finger on 14-5-4.
//  Copyright (c) 2014年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Time)

/**
 时间通用规则一

 ·发布时间＜10分钟，显示：刚刚
 ·10分钟≤发布时间＜60分钟，以分钟为单位显示
    ·文本格式：[分钟数]分钟前
 ·1小时≤发布时间＜24小时，以小时为单位显示
    ·文本格式：[小时数]小时前
 ·1天≤发布时间＜7天，显示日期
    ·文本格式：[天数]天前
 ·7天≤发布时间＜365天，显示日期
    ·文本格式：[月份]-[日期]
 ·发布时间≥365天，显示月
    ·文本格式：[年份]-[月份]
 
 @param interval 1970时间戳
 */
+ (NSString *)stringIntervalSince1970RuleOne:(double)interval;

/**
 时间通用规则二

 ·时间为当天，显示：[时：分]
 ·时间不在当天，显示：[月-日 时：分]
 ·时间不在当年，显示：[年-月-日 时：分]
 
 @param interval 1970时间戳
 */
+ (NSString *)stringIntervalSince1970RuleTwo:(double)interval;

/**
 时间通用规则三

 ·时间为当天，显示：[时：分]
 ·时间不在当天，显示：[月/日 时：分]
 ·时间不在当年，显示：[年/月/日 时：分]
 
 @param interval 1970时间戳
 */
+ (NSString *)stringIntervalSince1970RuleThree:(double)interval;

/**
 时间通用规则四
 
 ·显示：[YYYY/MM/DD hh：mm]

 @param interval 1970时间戳
 */
+ (NSString *)stringIntervalSince1970RuleFour:(double)interval;

/**
 时间通用规则五

 ·显示：[YYYY-MM-DD hh：mm]
 
 @param interval 1970时间戳
 */
+ (NSString *)stringIntervalSince1970RuleFive:(double)interval;

/**
 时间通用规则六

 ·时间在当天的，显示：[hh：mm]
 ·时间不在当天但在当前的，显示：[月份]月[日期]日 [hh：mm]
 ·时间不在当年的，显示：[年份]年[月份]月[日期]日 [hh：mm]
 ·数值无需用0补位，例如：4月9日，无需显示04月09日
 
 @param interval 1970时间戳
 */
+ (NSString *)stringIntervalSince1970RuleSix:(double)interval;

/**
 时间通用规则倒计时

 ·时间≥1小时，以小时为单位显示：[小时数]小时
 ·时间＜1小时，以分钟为单位显示：[分钟数]分钟
 ·若时间不为整数，时间取整数，并+1
 
 @param interval 倒计时秒数
 */
+ (NSString *)stringIntervalCountdownRule:(double)interval;

// 如:type 0:返回 20130828153322  type 1:返回 2013-08-28 15:33:22  2:返回 2013-08-28  3:返回 2013年8月28日 15时33分22秒 4:返回2013年8月28日
+(NSString *)getNowDateForall:(int)type;
//与当前时间做比较  返回(几个月前,几周前,几天前,几小时前,几分钟前,几秒前)
+ (NSString *)intervalFromLastDate: (NSDate *) date;
+ (NSString *)intervalFromLastDateWithInterval:(double)secs;
//+ (NSString *)intervalStringAllLastDateWithInterval:(double)secs; //(几年前...)
//根据当前时间生成文件名称   格式为(20138291746985071.mp3)    suffix 代表文件后缀名
+ (NSString *)getNowDateFileName:(NSString *)suffix;
//根据字符串生成时间
+ (NSDate *) getDateFormat:(NSString *)str Format:(NSString *)format;
//根据时间生成字符串
+ (NSString *)getStringFormat:(NSDate *)date Format:(NSString *)format;
//时间字符串转时间字符串 2010-10-27 10:22:15 转化为 2010-10-27 10:22
+ (NSString *)stringFormatYearAndMonthAndDayInterval:(NSString*)str;


//时间戳时间  2013:12:11 11:11:11
+ (NSString *)stringIntervalSince1970:(double)interval;
//输出格式为：2010-10-27 10:22
+ (NSString *)stringFormatIntervalSince1970:(double)interval;
//输出格式为：2010/10/27 10:22
+ (NSString *)stringFormatSlashIntervalSince1970:(double)interval;
//输出格式为：10/27 10:22 或者 6/5 10:22
+ (NSString *)stringFormatMDHMIntervalSince1970:(double)interval;
//输出格式为：10/27 10:22 或者 06/05 10:22
+ (NSString *)stringFormatMDHM2IntervalSince1970:(double)interval;
//输出格式为：10-27
+ (NSString *)stringFormatMonthAndDayIntervalSince1970ForUnderline:(double)interval;
//根据时间戳格式化月日   10月27日
+ (NSString *)stringFormatMonthAndDayIntervalSince1970:(double)interval;
//根据时间戳格式化月日   9月1日（不是 09月02日）
+ (NSString *)stringFormatMonthAndDayIntervalSince:(double)interval;
//根据时间戳格式化年月 2010-10
+ (NSString *)stringFormatYearAndMonthIntervalSince1970:(double)interval;
//根据时间戳格式化年月日   2010-10-27
+ (NSString *)stringFormatYearAndMonthAndDayIntervalSince1970:(double)interval;
//根据时间戳格式化年月日   2010年10月27日
+ (NSString *)stringChinaFormatYearAndMonthAndDayIntervalSince1970:(double)interval;
//根据时间戳格式化时分   12:00
+ (NSString *)stringFormatHoursAndMinutesIntervalSince:(double)interval;
//根据时间戳格式化日   5日
+ (NSString *)stringFormatDayIntervalSince:(double)interval;
//获取当前格式化时间  2013:12:11 11:11:11
+ (NSString *)getNowDateFormatter;
//获取当前时间  2013105221034
+ (NSString *)getNowDate;
+ (NSString *)getNowYear;
+(double)getNowDateTimeInterval;

//随机数字字符串
+(NSString*)stringRandomNumberForm:(NSUInteger)from to:(NSUInteger)to;

//根据秒 获取几分钟
+ (NSString *)getDateFromSecond:(int)second;

//根据时间获取秒数  例如:(01:30)==90s
+ (float) getDSceond:(NSString *)strTime;

//根据秒获取分钟 不足一分钟按一分钟算
+ (NSString *)getMinuteFromSecond:(unsigned long long)second;

//输出格式为：2010-10-27 10:22:13
+ (NSString *)getTimeStringWithFormmatter;

+ (NSString *)getCreateTime:(NSString*)str;

+ (NSString *)intervalSinceNow:(NSString *)theDate;

//当前时间戳,以毫秒为单位
+(NSString*)getNowTimeTimestampSSS;

//获取当前时间戳(以秒为单位)
+(NSString *)getNowTimeTimestamp;

/**
 特殊处理，显示多久前，必须为13位时间戳;
 《通用设定》-通用时间显示格式-通用时间显示格式（一）
 */
+ (NSString *)stringWithTimestamp:(NSString *)timestamp;

/**
 倒计时返回时间差,时间戳必须为13位
 如果时间差为负，表示当前时间已经超过timestamp对应的时间
 */
+ (NSDateComponents *)timeIntervalWithTimestamp:(NSString *)timestamp;

/**
 NSDateComponents是否为负
 */
+ (BOOL)isOverTimeWithComponents:(NSDateComponents *)components;

//HH:MM:SS 秒数转成时分秒
+(NSString *)getHHMMSSFromSS:(NSString *)totalTime;
//HH:MM:SS.MM 秒数转成时分秒.毫秒
+(NSString *)getHHMMSSMMFromSS:(NSTimeInterval)totalTime;

@end
