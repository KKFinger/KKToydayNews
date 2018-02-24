//
//  KKAttriTextData.h
//  KKToydayNews
//
//  Created by finger on 2017/10/1.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKAttriTextData : NSObject
@property(nonatomic,copy)NSString *originalText;
@property(nonatomic,assign)CGFloat maxAttriTextWidth;//由外部传入，最大的文本宽度，用于计算文本的高度
@property(nonatomic)UIFont *textFont;//由外部传入，文本的字体
@property(nonatomic)UIColor *textColor;//由外部传入，文本的字体
@property(nonatomic,assign)CGFloat lineSpace;//行间隔，由外部传入
@property(nonatomic,assign)NSTextAlignment alignment;
@property(nonatomic,assign)CGFloat attriTextHeight;//文本的高度
@property(nonatomic,assign)NSLineBreakMode lineBreak;
@property(nonatomic,assign)CGFloat textHeightOffset;//文本高度的偏移量，高度计算不准确，需要偏移特定高度才能完整显示
@property(nonatomic,readonly)NSMutableAttributedString *attriText;


/**
 设置一段文字中部分文字的属性
 @param subStr 文字
 @param attriInfo 文字属性，包括字体、颜色、背景色等
 */
- (void)setSubstringAttribute:(NSString *)subStr attributed:(NSDictionary *)attriInfo;

@end
