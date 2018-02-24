//
//  UIFont+Standard.h
//  KKToydayNews
//
//  Created by finger on 2017/9/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  字体规范
 *  note: 文本中文字体参数获取 大小:max 36 huge 24, large 18, normal 16, small 14, min 12 tiny 11 minimum 10
 */
@interface UIFont (Standard)

//细黑
+(UIFont *)kkFontMax;
+(UIFont *)kkFontHuge;
+(UIFont *)kkFontMedium;
+(UIFont *)kkFontLarge;
+(UIFont *)kkFontNormal;
+(UIFont *)kkFontSmall;
+(UIFont *)kkFontSmaller;
+(UIFont *)kkFontMini;
+(UIFont *)kkFontTiny;
+(UIFont *)kkFontMinimum;

//粗体
+(UIFont *)kkFontBoldMax;
+(UIFont *)kkFontBoldHuge;
+(UIFont *)kkFontBoldMedium;
+(UIFont *)kkFontBoldLarge;
+(UIFont *)kkFontBoldNormal;
+(UIFont *)kkFontBoldSmall;
+(UIFont *)kkFontBoldSmaller;
+(UIFont *)kkFontBoldMini;
+(UIFont *)kkFontBoldTiny;
+(UIFont *)kkFontBoldMinimum;

/**
 *  使用非规范情况下的字体
 *
 *  @param fontSize 字体大小
 *  @param aIsBold  是否粗
 *
 *  @return return value description
 */
+(UIFont *)kkFontOfSize:(CGFloat)fontSize isBold:(BOOL)aIsBold;

@end
