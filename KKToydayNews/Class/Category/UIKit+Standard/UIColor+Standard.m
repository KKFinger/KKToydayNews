//
//  UIColor+Standard.m
//  KKToydayNews
//
//  Created by finger on 2017/9/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "UIColor+Standard.h"

#define ColorImplement(COLOR_NAME,RED,GREEN,BLUE)    \
+ (UIColor *)COLOR_NAME{    \
    static UIColor* COLOR_NAME##_color;    \
    static dispatch_once_t COLOR_NAME##_onceToken;   \
    dispatch_once(&COLOR_NAME##_onceToken, ^{    \
        COLOR_NAME##_color = [UIColor colorWithRed:(float)RED/255 green:(float)GREEN/255 blue:(float)BLUE/255 alpha:1.0];  \
    });\
    return COLOR_NAME##_color;  \
}

@implementation UIColor (Standard)

/* 提示 */
ColorImplement(kkColorOnline, 0x79, 0xea, 0x00);
ColorImplement(kkColorAlert, 0xff, 0x40, 0x00);
ColorImplement(kkColorDone, 0x33, 0xb8, 0x33);

/* 主色/重要 */
ColorImplement(kkColorOrange, 0xff, 0xa2, 0x00);
ColorImplement(kkColorDarkgray, 0x1c, 0x1c, 0x1c);

/* 常规 */
ColorImplement(kkColorDeepgray, 0x72, 0x72, 0x72);
ColorImplement(kkColorLightgray, 0x8a, 0x8a, 0x8a);
ColorImplement(kkColorSpaceline, 0x8c, 0x8c, 0x8c);

/* 较弱 */
ColorImplement(kkColorTabbarbackground, 0xf0, 0xf0, 0xf0);

/* 黑白 */
ColorImplement(kkColorBlack, 0x00, 0x00, 0x00);
ColorImplement(kkColorWhite, 0xff, 0xff, 0xff);

/* 黄色 */
ColorImplement(kkColorY1, 0xff, 0xcd, 0x00);
ColorImplement(kkColorY2, 0xff, 0xc5, 0x60);
ColorImplement(kkColorY3, 0xff, 0xdf, 0x60);
ColorImplement(kkColorY4, 0xff, 0xe1, 0xac);
ColorImplement(kkColorY5, 0xff, 0xef, 0xac);

/* 橙色 */
ColorImplement(kkColorO1, 0xff, 0x73, 0x00);
ColorImplement(kkColorO2, 0xff, 0xa0, 0x60);
ColorImplement(kkColorO3, 0xff, 0xce, 0xac);

/* 红色 */
ColorImplement(kkColorR1, 0xff, 0x99, 0xaa);
ColorImplement(kkColorR2, 0xff, 0xc2, 0xd0);

/* 紫色 */
ColorImplement(kkColorP1, 0x93, 0x3d, 0xcc);
ColorImplement(kkColorP2, 0x80, 0x6b, 0xeb);
ColorImplement(kkColorP3, 0xb4, 0xa8, 0xeb);

/* 蓝色 */
ColorImplement(kkColorB1, 0x52, 0x6c, 0xaf);
ColorImplement(kkColorB2, 0x4c, 0xa3, 0xff);
ColorImplement(kkColorB3, 0x66, 0xd9, 0xff);
ColorImplement(kkColorB4, 0xa3, 0xc0, 0xee);
ColorImplement(kkColorB5, 0xc2, 0xd9, 0xfd);

/* 绿色 */
ColorImplement(kkColorG1, 0x14, 0xcc, 0xca);
ColorImplement(kkColorG2, 0x57, 0xe8, 0xcf);
ColorImplement(kkColorG3, 0x9b, 0xd4, 0xcb);
ColorImplement(kkColorG4, 0x9c, 0xe8, 0xdb);

@end
