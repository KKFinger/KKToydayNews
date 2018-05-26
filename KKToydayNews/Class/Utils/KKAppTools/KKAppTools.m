//
//  KKAppTools.m
//  KKToydayNews
//
//  Created by finger on 2017/9/20.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKAppTools.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation KKAppTools

#pragma mark -- 返回当前类的所有属性

+ (NSArray *)getProperties:(Class)cls{
    // 获取当前类的所有属性
    unsigned int count;// 记录属性个数
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    // 遍历
    NSMutableArray *mArray = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        // 获取属性的名称 C语言字符串
        const char *cName = property_getName(property);
        // 转换为Objective C 字符串
        NSString *name = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        [mArray addObject:name];
    }
    
    return mArray.copy;
}

#pragma mark -- 跳转到设置界面

+ (void)jumpToSetting{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark -- 视图是push还是present显示的

+ (BOOL)isPushWithCtrl:(UIViewController *)ctrl{
    if ([ctrl respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        return NO;
    } else if ([ctrl.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
        return YES;
    }
    return YES ;
}

#pragma mark -- 字节大小转换

+ (NSString*)formatSizeFromByte:(long long)bytes{
    int multiplyFactor = 0;
    double convertedValue = bytes;
    NSArray *tokens = [NSArray arrayWithObjects:@"B",@"KB",@"MB",@"GB",@"TB",nil];
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%4.1f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

#pragma mark -- 时长转换

+ (NSString *)convertDurationToString:(NSTimeInterval)duration{
    NSInteger hour = duration / 3600;
    NSInteger minute = (duration - hour*3600) / 60;
    NSInteger seconds = (duration - hour *3600 - minute*60);
    NSString *strDuration  = @"";
    
    strDuration = [NSString stringWithFormat:@"%02ld:",hour];
    strDuration = [strDuration stringByAppendingFormat:@"%02ld:",minute];
    strDuration = [strDuration stringByAppendingFormat:@"%02ld",seconds];
    return strDuration;
}

#pragma mark -- Unicode转码

+ (NSString*)replaceUnicode:(NSString*)unicodeString{
    if(!unicodeString.length){
        return @"";
    }
    NSString*tempStr1 = [unicodeString stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
    NSString*tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    NSString*tempStr3 = [[@"\"" stringByAppendingString:tempStr2]stringByAppendingString:@"\""];
    
    NSData*tepData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString*axiba = [NSPropertyListSerialization propertyListWithData:tepData options:NSPropertyListMutableContainers format:NULL error:NULL];
    
    return [axiba stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

#pragma mark -- 生成as和cp,数据请求时会用到

+ (void)generateAs:(NSString **)asStr cp:(NSString **)cpStr{
    long long time = [[NSDate date]timeIntervalSince1970];
    NSString *key = [[self toHexString:time]uppercaseString];
    NSString *md5Key = [[self md5String:[NSString stringWithFormat:@"%lld",time]]uppercaseString];
    if (key.length != 8) {
        *asStr = @"479BB4B7254C150";
        *cpStr = @"7E0AC8874BB0985";
        return;
    } else {
        NSString *ascMd5 = [md5Key substringToIndex:5];
        NSString *descMd5 = [md5Key substringFromIndex:md5Key.length - 5];
        NSMutableString *as = [NSMutableString new];
        NSMutableString *cp = [NSMutableString new];
        
        for (int i=0; i<5; i++) {
            [as appendString:[ascMd5 substringWithRange:NSMakeRange(i, 1)]];
            [as appendString:[key substringWithRange:NSMakeRange(i, 1)]];
            [cp appendString:[key substringWithRange:NSMakeRange(i+3, 1)]];
            [cp appendString:[descMd5 substringWithRange:NSMakeRange(i, 1)]];
        }
        *asStr = [NSString stringWithFormat:@"A1%@%@",as,[key substringFromIndex:key.length-3]];
        *cpStr = [NSString stringWithFormat:@"%@%@E1",[key substringToIndex:3],cp];
    }
}

#pragma mark -- md5加密

+ (NSString *)md5String:(NSString *)content{
    const char *concat_str = [content UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

#pragma mark -- 十进制转16进制

+ (NSString *)toHexString:(long long)tmpid{
    NSString *nLetterValue;
    NSString *str =@"";
    uint16_t ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=tmpid%16;
        tmpid=tmpid/16;
        switch (ttmpig){
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}

@end


@implementation KKAppTools (KKFile)

#pragma mark -- 清除文件夹下的所有文件

+ (void)clearFileAtFolder:(NSString *)folderPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:folderPath error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])){
        BOOL isDir = NO ;
        NSString *filePath = [folderPath stringByAppendingPathComponent:filename] ;
        if([fileManager fileExistsAtPath:filePath isDirectory:&isDir]){
            if(isDir){
                [KKAppTools clearFileAtFolder:filePath];
            }else{
                [fileManager removeItemAtPath:filePath error:NULL];
            }
        }
    }
    [fileManager removeItemAtPath:folderPath error:nil];
}

#pragma mark -- 创建文件夹

+ (NSString *)createFolderIfNeed:(NSString *)folderPath{
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folderPath;
}

#pragma mark -- 生成视频名称，确保唯一性

+ (NSString *)formartFileName:(NSString *)name fileType:(NSString *)fileType{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSDate * NowDate = [NSDate dateWithTimeIntervalSince1970:now];
    ;
    NSString *timeStr = [formatter stringFromDate:NowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",name,timeStr,fileType];
    return fileName;
}

#pragma mark -- 获取ctrl最顶层的present出来的控制器

- (UIViewController *)presentedCttl:(UIViewController *)ctrl{
    UIViewController *presentedCttl = ctrl ;
    while(presentedCttl.presentedViewController){
        presentedCttl = presentedCttl.presentedViewController;
    }
    return presentedCttl;
}

#pragma mark -- 获取ctrl最底层的present出来的控制器

- (UIViewController *)presentingCttl:(UIViewController *)ctrl{
    UIViewController *presentingCttl = ctrl ;
    while(presentingCttl.presentingViewController){
        presentingCttl = presentingCttl.presentingViewController;
    }
    return presentingCttl;
}

@end
