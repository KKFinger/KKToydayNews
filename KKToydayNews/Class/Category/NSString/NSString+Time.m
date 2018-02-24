//
//  NSString+Time.m
//  KKToydayNews
//
//  Created by finger on 14-5-4.
//  Copyright (c) 2014年 finger. All rights reserved.
//

#import "NSString+Time.h"

#define SECONDS_PER_DAY (24*60*60)
#define SECONDS_PER_MONTH (30*24*60*60)
#define SECONDS_PER_YEAR (365*24*60*60)

@implementation NSString (Time)

+ (NSString *)stringIntervalSince1970RuleOne:(double)interval {
    return [self intervalFromLastDateWithInterval:interval];
}

+ (NSString *)stringIntervalSince1970RuleTwo:(double)interval {
    NSMutableString *formatedString = [NSString stringFormatIntervalSince1970:interval placeholderByZero:YES].mutableCopy;
    NSString *now = [NSString stringFormatIntervalSince1970:[self getNowDateTimeInterval] placeholderByZero:YES];
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"- "];
    NSArray<NSString *> *timeOfNow = [now componentsSeparatedByCharactersInSet:set];
    
    // 包含年后面的‘-’
    NSString *year = [NSString stringWithFormat:@"%@-", timeOfNow.firstObject];
    if ([formatedString hasPrefix:year]) { // 同年
        [formatedString deleteCharactersInRange:[formatedString rangeOfString:year]];
        // 包含日后面的' '
        NSString *today = [NSString stringWithFormat:@"%@-%@ ", timeOfNow[1], timeOfNow[2]];
        if ([formatedString hasPrefix:today]) { // 当天
            [formatedString deleteCharactersInRange:[formatedString rangeOfString:today]];
        }
    }
    
    return formatedString;
}

+ (NSString *)stringIntervalSince1970RuleThree:(double)interval {
    NSMutableString *formatedString = [NSString stringFormatSlashIntervalSince1970:interval placeholderByZero:NO].mutableCopy;
    NSString *now = [NSString stringFormatSlashIntervalSince1970:[self getNowDateTimeInterval] placeholderByZero:NO];
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"/ "];
    NSArray<NSString *> *timeOfNow = [now componentsSeparatedByCharactersInSet:set];
    
    // 包含年后面的‘-’
    NSString *year = [NSString stringWithFormat:@"%@/", timeOfNow.firstObject];
    if ([formatedString hasPrefix:year]) { // 同年
        [formatedString deleteCharactersInRange:[formatedString rangeOfString:year]];
        // 包含日后面的' '
        NSString *today = [NSString stringWithFormat:@"%@/%@ ", timeOfNow[1], timeOfNow[2]];
        if ([formatedString hasPrefix:today]) { // 当天
            [formatedString deleteCharactersInRange:[formatedString rangeOfString:today]];
        }
    }
    
    return formatedString;
}

+ (NSString *)stringIntervalSince1970RuleFour:(double)interval {
    return [self stringFormatSlashIntervalSince1970:interval];
}

+ (NSString *)stringIntervalSince1970RuleFive:(double)interval {
    return [self stringFormatIntervalSince1970:interval placeholderByZero:YES];
}

+ (NSString *)stringIntervalSince1970RuleSix:(double)interval {
    NSString *time = [NSString stringFormatIntervalSince1970:interval placeholderByZero:NO];
    NSString *now = [NSString stringFormatIntervalSince1970:[self getNowDateTimeInterval] placeholderByZero:NO];
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"/ "];
    NSArray<NSString *> *timeOfNow = [now componentsSeparatedByCharactersInSet:set];
    NSArray<NSString *> *timeWillFormat = [time componentsSeparatedByCharactersInSet:set];
    
    NSString *y, *m, *d, *h_m, *n_y, *n_m, *n_d, *n_h_m;
    y = timeWillFormat[0];
    m = timeWillFormat[1];
    d = timeWillFormat[2];
    h_m = timeWillFormat[3];
    
    n_y = timeOfNow[0];
    n_m = timeOfNow[1];
    n_d = timeOfNow[2];
    n_h_m = timeOfNow[3];
    
    if (![y isEqualToString:n_y]) { // 不同年
        return [NSString stringWithFormat:@"%@年%@月%@日 %@", y, m, d, h_m];
    }
    
    if (![m isEqualToString:n_m] || ![d isEqualToString:n_d]) { // 不在当天
        return [NSString stringWithFormat:@"%@月%@日 %@", m, d, h_m];
    }
    
    return h_m;
}

+ (NSString *)stringIntervalCountdownRule:(double)interval {
    NSInteger m = interval / 60;
    NSInteger h = m / 60;
    if (m > 0) {
        h++;
    }
    
    if (h > 0) {
        return [NSString stringWithFormat:@"%@小时", @(h)];
    }
    
    if (m > 0) {
        return [NSString stringWithFormat:@"%@分钟", @(m)];
    }
    
    return nil;
}

+ (NSString *)stringFormatSlashIntervalSince1970:(double)interval placeholderByZero:(BOOL)need {
    if (need) {
        return [self stringFormatSlashIntervalSince1970:interval];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/M/d HH:mm"];//输出格式为：2010/6/7 10:22
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)getNowDateForall:(int)type
{
    NSDate * now = [[NSDate alloc] init];
    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:now];
    NSUInteger seconds=[cps second];
    NSUInteger hour = [cps hour];
    NSUInteger minute = [cps minute];
    NSUInteger day = [cps day];
    NSUInteger month = [cps month];
    NSUInteger year =[cps year];
    if(type == 0){
        return  [NSString stringWithFormat:@"%d%d%d%2d%02d%02d", (int)year, (int)month, (int)day, (int)hour, (int)minute, (int)seconds];
    }
    if (type==1)
    {
        return [NSString stringWithFormat:@"%d-%d-%d %02d:%02d:%02d", (int)year, (int)month, (int)day, (int)hour, (int)minute, (int)seconds];
    }
    if (type==2)
    {
        return [NSString stringWithFormat:@"%d-%d-%d", (int)year, (int)month, (int)day];
        
    }
    if (type==3)
    {
        return [NSString stringWithFormat:@"%d年%d月%d日 %2d时:%2d分:%2d秒", (int)year, (int)month, (int)day, (int)hour, (int)minute, (int)seconds];
    }
    if (type==4)
    {
        return [NSString stringWithFormat:@"%d年%d月%d日 ", (int)year, (int)month, (int)day];
    }
    if (type==5)
    {
        return [NSString stringWithFormat:@"%d-%d-%d %02d:%02d", (int)year, (int)month, (int)day, (int)hour, (int)minute];
    }
    return nil;
}

+ (NSString *)intervalFromLastDate:(NSDate *) date;
{
    //两个时间的时间差
    int TimeDifference=fabs([date timeIntervalSinceDate:[NSDate date]]);
    if (TimeDifference/(60*60*24*30)>0) {
        return [NSString stringWithFormat:@"%d个月前",TimeDifference/(60*60*24*30)>0];
    }
    if (TimeDifference/(60*60*24*7)>0) {
        return [NSString stringWithFormat:@"%d周前",TimeDifference/(60*60*24*7)];
    }
    if (TimeDifference/(60*60*24)>0) {
        return [NSString stringWithFormat:@"%d天前",TimeDifference/(60*60*24)];
    }
    if (TimeDifference/(60*60)>0) {
        return [NSString stringWithFormat:@"%d小时前",TimeDifference/(60*60)];
    }
    if (TimeDifference/60>0) {
        return [NSString stringWithFormat:@"%d分钟前",TimeDifference/60];
    }
    if (TimeDifference%60>0) {
        return [NSString stringWithFormat:@"%d秒前",TimeDifference%60];
    }
    return nil;
}

+ (NSString *)intervalFromLastDateWithInterval:(double)secs
{
    //两个时间的时间差
    NSDate *serDate = [[NSDate alloc] initWithTimeIntervalSince1970:secs];
    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:[self getNowDateTimeInterval]];
    double delta = fabs([serDate timeIntervalSinceDate:curDate]);
    
    if (delta < 10 * MINUTE)
    {
        return @"刚刚";
    }
    else if (delta < 60 * MINUTE)
    {
        int minutes = floor((double)delta/MINUTE);
        return [NSString stringWithFormat:@"%d分钟前", minutes];
    }
    else if (delta < 24 * HOUR)
    {
        int hours = floor((double)delta/HOUR);
        return [NSString stringWithFormat:@"%d小时前", hours];
    }
    else if (delta < 7 * DAY)
    {
        int days = floor((double)delta/DAY);
        return [NSString stringWithFormat:@"%d天前", days];
    }
    else if (delta < YEAR)
    {
        return [self stringFormatMonthAndDayIntervalSince1970ForUnderline:secs];
    }
    
    return [self stringFormatYearAndMonthIntervalSince1970:secs];
}
//+ (NSString *)intervalStringAllLastDateWithInterval:(double)secs
//{
//    //两个时间的时间差
//    NSDate *serDate = [[NSDate alloc] initWithTimeIntervalSince1970:secs];
//    NSDate *curDate = [[NSDate alloc] initWithTimeIntervalSince1970:[AppUtils currentServiceTime]];
//    double delta = fabs([serDate timeIntervalSinceDate:curDate]);
//
//    if (delta < 1 * MINUTE)
//    {
//        return @"刚刚";
//    }
//    else if (delta < HOUR)
//    {
//        int minutes = floor((double)delta/MINUTE);
//        return [NSString stringWithFormat:@"%d分钟前", minutes];
//    }
//    else if (delta < DAY)
//    {
//        int hours = floor((double)delta/HOUR);
//        return [NSString stringWithFormat:@"%d小时前", hours];
//    }
//    else if (delta < MONTH)
//    {
//        int days = floor((double)delta/DAY);
//        return [NSString stringWithFormat:@"%d天前", days];
//    }
//    else if (delta < YEAR)
//    {
//        int months = floor((double)delta/MONTH);
//        return [NSString stringWithFormat:@"%d个月前", months];
//    } else {
//        int years = floor((double)delta/YEAR);
//        return [NSString stringWithFormat:@"%d年前", years];
//    }
//}
+ (NSString *)getNowDateFileName:(NSString *)suffix
{
    NSDate * now = [[NSDate alloc] init];
    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:now];
    NSUInteger hour = [cps hour];
    NSUInteger minute = [cps minute];
    NSUInteger day = [cps day];
    NSUInteger month = [cps month];
    NSUInteger year =[cps year];
    return [NSString stringWithFormat:@"%d%d%d%d%d%d.%@", (int)year, (int)month, (int)day, (int)hour, (int)minute,arc4random()%8888888,suffix];
}

//根据字符串生成时间
+ (NSDate *) getDateFormat:(NSString *)str Format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    if (str.length!=format.length) {
        
        return nil;
    }
    NSDate *tempdate=[NSDate dateWithTimeInterval:8*60*60 sinceDate:[formatter dateFromString:str]];
    if ([[tempdate.description substringFromIndex:tempdate.description.length-17] isEqualToString:@"596:-31:-23 +0000"]) {
        
        return nil;
    }
    return [NSDate dateWithTimeInterval:8*60*60 sinceDate:[formatter dateFromString:str]];
}

//根据时间生成字符串
+ (NSString *)getStringFormat:(NSDate *)date Format:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return [formatter stringFromDate:date];
}


+ (NSString *)getDateFromSecond:(int)second
{
    if (second>600&&second%60>=10) {
        return [NSString stringWithFormat:@"%d:%d",second/60,second%60];
    }else if (second>600&&second%60<10){
        return [NSString stringWithFormat:@"%d:0%d",second/60,second%60];
    }else if (second<600&&second%60>=10){
        return [NSString stringWithFormat:@"0%d:%d",second/60,second%60];
    }else if (second<600&&second%60<10){
        return [NSString stringWithFormat:@"0%d:0%d",second/60,second%60];
    }
    else if (second<60&&second%60>=10){
        return [NSString stringWithFormat:@"00:%d",second%60];
    }else{
        return [NSString stringWithFormat:@"00:0%d",second%60];
    }
}

+(NSString *)getNowDateFormatter
{
    NSDate * now = [[NSDate alloc] init];
    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:now];
    NSUInteger seconds=[cps second];
    NSUInteger hour = [cps hour];
    NSUInteger minute = [cps minute];
    NSUInteger day = [cps day];
    NSUInteger month = [cps month];
    NSUInteger year =[cps year];
    return [NSString stringWithFormat:@"%d-%d-%d %02d:%02d:%02d", (int)year, (int)month, (int)day, (int)hour, (int)minute, (int)seconds];
}

+(NSString *)getNowDate
{
    NSDate * now = [[NSDate alloc] init];
    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:now];
    NSUInteger hour = [cps hour];
    NSUInteger minute = [cps minute];
    NSUInteger seconds=[cps second];
    NSUInteger day = [cps day];
    NSUInteger month = [cps month];
    NSUInteger year =[cps year];
    return [NSString stringWithFormat:@"%d%d%d%d%d%d",(int)year, (int)month, (int)day, (int)hour, (int)minute, (int)seconds];
}

+(NSString *)getNowYear
{
    NSDate * now = [[NSDate alloc] init];
    NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:now];
    NSUInteger year =[cps year];
    return [NSString stringWithFormat:@"%d",(int)year];
}


+(double)getNowDateTimeInterval
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval =[dat timeIntervalSince1970];
    NSString    *time   = [[NSString stringWithFormat:@"%lf",timeInterval] componentsSeparatedByString:@"."][0];
    
    return [time doubleValue];
}

+(NSString*)getNowTimeTimestampSSS
{
    NSTimeInterval timeInterval =[[[NSDate alloc] init] timeIntervalSince1970];
    NSString    *time   = [NSString stringWithFormat:@"%lf",timeInterval];
    
    return [time stringByReplacingOccurrencesOfString:@"." withString:@""];
}

//获取当前时间戳有两种方法(以秒为单位)
+(NSString *)getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
    
}

+(NSString*)stringRandomNumberForm:(NSUInteger)from to:(NSUInteger)to
{
    NSUInteger number = from + (arc4random() % (to - from + 1));
    
    return [NSString stringWithFormat:@"%d", (int)number];
}

+ (float) getDSceond:(NSString *)strTime
{
    NSArray *ay=[strTime componentsSeparatedByString:@":"];
    return  [ay[0]intValue]*60+[ay[1]intValue];
}

+ (NSString *)getMinuteFromSecond:(unsigned long long)second {
    unsigned long long minute = second / 60;
    if (second % 60 > 0) {
        minute += 1;
    }
    return @(minute).stringValue;
}

+ (NSString *)getTimeStringWithFormmatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//输出格式为：2010-10-27 10:22:13
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return  currentDateStr;
}

+ (NSString *)getCreateTime:(NSString*)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd "];//输出格式为：2010-10-27
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:str.longLongValue]];
    return  currentDateStr;
}

+ (NSString *)stringFormatYearAndMonthAndDayInterval:(NSString*)str
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate* date    = [dateFormatter dateFromString:str];
    
    if (date == nil) return str;
    
    double interval = (long)[date timeIntervalSince1970];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];//输出格式为：2010-10-27 10:22
    
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    
    return  currentDateStr;
}

+ (NSString *)stringFormatYearAndMonthIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM"];//输出格式为：2010-10
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringFormatYearAndMonthAndDayIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//输出格式为：2010-10-27
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringChinaFormatYearAndMonthAndDayIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];//输出格式为：2010年10月27日
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//输出格式为：2010-10-27 10:22:13
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringFormatIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];//输出格式为：2010-10-27 10:22
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringFormatSlashIntervalSince1970:(double)interval
{
    if (interval <= 0) return @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];//输出格式为：2010/10/27 10:22
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    
    return  currentDateStr;
}

+ (NSString *)stringFormatMDHMIntervalSince1970:(double)interval
{
    if (interval <= 0) return @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd HH:mm"];//输出格式为：10/27 10:22
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    
    NSString *md = [[currentDateStr componentsSeparatedByString:@" "] firstObject];
    NSString *month = [[md componentsSeparatedByString:@"/"] firstObject];
    NSString *day = [[md componentsSeparatedByString:@"/"] lastObject];
    if (month.integerValue < 10) month = [NSString stringWithFormat:@"%@",@(month.integerValue)];
    if (day.integerValue < 10) day = [NSString stringWithFormat:@"%@",@(day.integerValue)];
    
    NSString *newMD = [NSString stringWithFormat:@"%@/%@",month,day];
    currentDateStr = [currentDateStr stringByReplacingOccurrencesOfString:md withString:newMD];
    
    return  currentDateStr;
}

+ (NSString *)stringFormatMDHM2IntervalSince1970:(double)interval
{
    if (interval <= 0) return @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd HH:mm"];//输出格式为：10/27 10:22
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringFormatMonthAndDayIntervalSince1970ForUnderline:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd"];//输出格式为：10-27
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}
+ (NSString *)stringFormatMonthAndDayIntervalSince1970:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日"];//输出格式为：10月27日
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}
+ (NSString *)stringFormatMonthAndDayIntervalSince:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"M月d日"];//输出格式为：9月2日  不是 09月02日
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}
+ (NSString *)stringFormatHoursAndMinutesIntervalSince:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];//输出格式为：12:00
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}
+ (NSString *)stringFormatDayIntervalSince:(double)interval
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd日"];//输出格式为：9日
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    
    NSString *day = [[currentDateStr componentsSeparatedByString:@"日"] firstObject];
    if (day.integerValue < 10) {
        currentDateStr = [NSString stringWithFormat:@"%@日",@(day.integerValue)];
    }
    
    return  currentDateStr;
}
//时间戳转换
+ (NSString *)intervalSinceNow:(NSString *)theDate
{
    //如果是以北京时间为准的，就用北京时间转换。如果是以GMT时间为准的，就不用转换了，看服务器
    //    转换成 北京时间
    NSTimeInterval late;
    //    NSTimeZone *zone = [NSTimeZone systemTimeZone];//系统时区
    NSDate *dateNow = [NSDate date];//获取GMT时间，和北京时间不同
    //    NSInteger interval = [zone secondsFromGMTForDate:dateNow];//以秒为单位返回GMT(格林威治)时区与系统时区时间的时差。
    //    NSDate *localeDate = [[NSDate date]dateByAddingTimeInterval:interval];//增加时间间隔生成新的NSDate对象
    NSTimeInterval now = [dateNow timeIntervalSince1970];
    //    NSLog(@"%@",localeDate);
    
    if ([theDate rangeOfString:@"-"].location != NSNotFound)
    {
        //把theDate格式转换为时间戳格式-转换成北京时间
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *laDate = [formatter dateFromString:theDate];//string型转换为NSDate型（GMT时间）
        NSTimeZone *zone1 = [NSTimeZone systemTimeZone];//系统时区
        NSInteger inter = [zone1 secondsFromGMTForDate:laDate];//以秒为单位返回GMT(格林威治)时区与系统时区时间的时差。
        NSDate *lateDate = [laDate dateByAddingTimeInterval:inter];//增加时间间隔生成新的NSDate对象
        //        NSLog(@"%@",lateDate);
        late = [lateDate timeIntervalSince1970] ;
    }
    else
    {
        //如果是直接的时间戳格式
        late = [theDate doubleValue];
    }
    
    NSString *timeString = @"";
    NSTimeInterval cha = now - late;
    if (cha/3600<1)
    {
        if (cha/60<1)
        {
            timeString = [NSString stringWithFormat:@"%d分钟前",1];
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f",cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
            timeString = [NSString stringWithFormat:@"%@分钟前",timeString];
        }
    }
    if (cha/3600>=1 && cha/3600<24)
    {
        timeString = [NSString stringWithFormat:@"%f",cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@小时前",timeString];
    }
    if (cha/SECONDS_PER_DAY>=1 && cha/SECONDS_PER_DAY <30)
    {
        timeString = [NSString stringWithFormat:@"%f",cha/SECONDS_PER_DAY];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@天前",timeString];
    }
    if (cha/SECONDS_PER_DAY>=30 && cha/SECONDS_PER_DAY <365)
    {
        timeString = [NSString stringWithFormat:@"%f",cha/SECONDS_PER_MONTH];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@个月前",timeString];
    }
    if(cha/SECONDS_PER_DAY>=365)
    {
        timeString = [NSString stringWithFormat:@"%f",cha/SECONDS_PER_YEAR];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@年前",timeString];
    }
    return timeString;
}

+ (NSString *)stringFormatIntervalSince1970:(double)interval placeholderByZero:(BOOL)need {
    if (need) {
        return [self stringFormatIntervalSince1970:interval];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-M-d HH:mm"];//输出格式为：2010-6-7 10:22
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
    return  currentDateStr;
}

+ (NSString *)stringWithTimestamp:(NSString *)timestamp
{
    NSString *timeStr = @"刚刚";
    
    if(timestamp.length != 13)
    {
        return timeStr;
    }
    
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    //    NSDate *date = [NSDate date];
    //
    //    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:logoutTime toDate:date options:NSCalendarWrapComponents];
    
    NSDate *logoutTime = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue] / 1000];//
    NSDateComponents *dateComponent = [NSString timeIntervalWithTimestamp:timestamp];//时间差
    
    //因为是过去时间，返回的时间差是负数
    NSInteger year      = 0 - [dateComponent year];
    NSInteger month     = 0 - [dateComponent month];
    NSInteger day       = 0 - [dateComponent day];
    NSInteger hour      = 0 - [dateComponent hour];
    NSInteger minute    = 0 - [dateComponent minute];
    
    if(year > 0)
    {
        timeStr = [NSString stringWithFormat:@"%ld年%ld月",logoutTime.year,logoutTime.month];
    }
    else
    {
        if(month > 0)
        {
            timeStr = [NSString stringWithFormat:@"%ld月%ld日",logoutTime.month,logoutTime.day];
        }
        else
        {
            if(day >= 7)
            {
                timeStr = [NSString stringWithFormat:@"%ld月%ld日",logoutTime.month,logoutTime.day];
            }
            else
            {
                if(day >= 1)
                {
                    timeStr = [NSString stringWithFormat:@"%ld天前",day];
                }
                else
                {
                    if(hour > 0)
                    {
                        timeStr = [NSString stringWithFormat:@"%ld小时前",hour];
                    }
                    else if(minute >= 10)
                    {
                        timeStr = [NSString stringWithFormat:@"%ld分钟前",minute];
                    }
                    else
                    {
                        timeStr = @"刚刚";
                    }
                }
            }
        }
    }
    
    return timeStr;
}

+ (NSDateComponents *)timeIntervalWithTimestamp:(NSString *)timestamp
{
    if(timestamp.length != 13)
    {
        return nil;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDate *endTime = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue] / 1000];
    NSDate *date = [NSDate date];
    
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date toDate:endTime options:NSCalendarWrapComponents];
    
    return dateComponent;
}

+ (BOOL)isOverTimeWithComponents:(NSDateComponents *)components
{
    if(components.year < 0 || components.month < 0 || components.day < 0 || components.hour < 0 || components.minute < 0 || components.second < 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//HH:MM:SS 秒数转成时分秒
+(NSString *)getHHMMSSFromSS:(NSString *)totalTime{
    
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    
    if([str_hour isEqualToString:@"00"]){
        return [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }
    
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
    
}

//HH:MM:SS.MM 秒数转成时分秒.毫秒
+(NSString *)getHHMMSSMMFromSS:(NSTimeInterval)totalTime{
    NSInteger seconds = (NSInteger)totalTime ;
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //毫秒
    NSString *str_millisecond = [NSString stringWithFormat:@"%ld",(NSInteger)((totalTime - seconds) * 10.0)];
    
    if([str_hour isEqualToString:@"00"]){
        return [NSString stringWithFormat:@"%@:%@.%@",str_minute,str_second,str_millisecond];
    }
    
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@.%@",str_hour,str_minute,str_second,str_millisecond];
    
    return format_time;
    
}

@end
