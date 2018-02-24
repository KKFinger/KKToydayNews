//
//  UIColor+Standard.h
//  KKToydayNews
//
//  Created by finger on 2017/9/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

//颜色值
#define Color255(x,y,z) Color255a(x,y,z,1.0f)
//颜色值
#define Color255a(x,y,z,a) [UIColor colorWithRed:(float)x/255.0f green:(float)y/255.0f blue:(float)z/255.0f alpha:a]

//eg:0xFFFFFF代表白色
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                                                 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
                                                  blue:((float)(rgbValue & 0xFF))/255.0 \
                                                 alpha:1.0]

#define UIColorFromRGBA(rgbaValue) [UIColor colorWithRed:((float)((rgbaValue & 0xFF000000) >> 24))/255.0 \
                                                   green:((float)((rgbaValue & 0xFF0000) >> 16))/255.0 \
                                                    blue:((float)((rgbaValue & 0xFF00) >> 8))/255.0 \
                                                   alpha:((float)(rgbaValue & 0xFF))/255.0]

/**
 *  色彩规范
 */
@interface UIColor (Standard)

/* 提示 */
+ (UIColor *)kkColorOnline;
+ (UIColor *)kkColorAlert;
+ (UIColor *)kkColorDone;

/* 主色/重要 */
+ (UIColor *)kkColorOrange;
+ (UIColor *)kkColorDarkgray;

/* 常规 */
+ (UIColor *)kkColorDeepgray;
+ (UIColor *)kkColorLightgray;
+ (UIColor *)kkColorSpaceline;

/* 较弱 */
+ (UIColor *)kkColorTabbarbackground;

/* 黑白 */
+ (UIColor *)kkColorBlack;
+ (UIColor *)kkColorWhite;

/* 黄色 */
+ (UIColor *)kkColorY1;
+ (UIColor *)kkColorY2;
+ (UIColor *)kkColorY3;
+ (UIColor *)kkColorY4;
+ (UIColor *)kkColorY5;

/* 橙色 */
+ (UIColor *)kkColorO1;
+ (UIColor *)kkColorO2;
+ (UIColor *)kkColorO3;

/* 红色 */
+ (UIColor *)kkColorR1;
+ (UIColor *)kkColorR2;

/* 紫色 */
+ (UIColor *)kkColorP1;
+ (UIColor *)kkColorP2;
+ (UIColor *)kkColorP3;

/* 蓝色 */
+ (UIColor *)kkColorB1;
+ (UIColor *)kkColorB2;
+ (UIColor *)kkColorB3;
+ (UIColor *)kkColorB4;
+ (UIColor *)kkColorB5;

/* 绿色 */
+ (UIColor *)kkColorG1;
+ (UIColor *)kkColorG2;
+ (UIColor *)kkColorG3;
+ (UIColor *)kkColorG4;

@end
