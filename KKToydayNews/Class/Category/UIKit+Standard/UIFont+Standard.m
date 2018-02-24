//
//  UIFont+Standard.m
//  KKToydayNews
//
//  Created by finger on 2017/9/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "UIFont+Standard.h"

#define MCFontImplement(FONT_NAME,FONT_SIZE,ISBOLD) \
+ (UIFont *)FONT_NAME { \
    static UIFont *FONT_NAME##_font;    \
    static dispatch_once_t FONT_NAME##_onceToken;   \
    dispatch_once(&FONT_NAME##_onceToken, ^{    \
        if (ISBOLD) {   \
            FONT_NAME##_font = [UIFont boldSystemFontOfSize:FONT_SIZE];  \
        } else {  \
            FONT_NAME##_font = [UIFont systemFontOfSize:FONT_SIZE];  \
        }   \
    }); \
    return FONT_NAME##_font;\
}

@implementation UIFont (Standard)

//细黑
MCFontImplement(kkFontMax, 36, NO);
MCFontImplement(kkFontHuge, 27, NO);
MCFontImplement(kkFontMedium, 24, NO);
MCFontImplement(kkFontLarge, 20, NO);
MCFontImplement(kkFontNormal, 18, NO);
MCFontImplement(kkFontSmall, 15, NO);
MCFontImplement(kkFontSmaller, 14, NO);
MCFontImplement(kkFontMini, 12, NO);
MCFontImplement(kkFontTiny, 11, NO);
MCFontImplement(kkFontMinimum, 10, NO);

//黑体
MCFontImplement(kkFontBoldMax, 36, YES);
MCFontImplement(kkFontBoldHuge, 27, YES);
MCFontImplement(kkFontBoldMedium, 24, YES);
MCFontImplement(kkFontBoldLarge, 20, YES);
MCFontImplement(kkFontBoldNormal, 18, YES);
MCFontImplement(kkFontBoldSmall, 15, YES);
MCFontImplement(kkFontBoldSmaller, 14, YES);
MCFontImplement(kkFontBoldMini, 12, YES);
MCFontImplement(kkFontBoldTiny, 11, YES);
MCFontImplement(kkFontBoldMinimum, 10, YES);

+(UIFont *)kkFontOfSize:(CGFloat)fontSize isBold:(BOOL)aIsBold{
    if (aIsBold) {
        return [UIFont boldSystemFontOfSize:fontSize];
    }
    else {
        return [UIFont systemFontOfSize:fontSize];
    }
}

@end
