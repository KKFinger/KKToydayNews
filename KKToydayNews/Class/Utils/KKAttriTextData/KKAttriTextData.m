//
//  KKAttriTextData.m
//  KKToydayNews
//
//  Created by finger on 2017/10/1.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKAttriTextData.h"

@interface KKAttriTextData ()
@property(nonatomic,readwrite)NSMutableAttributedString *attriText;
@end

@implementation KKAttriTextData

- (instancetype)init{
    self = [super init];
    if(self){
        self.textFont = [UIFont systemFontOfSize:13];
        self.lineSpace = 1 ;
        self.maxAttriTextWidth = UIDeviceScreenWidth;
        self.textColor = [UIColor blackColor];
        self.alignment = NSTextAlignmentLeft;
        self.textHeightOffset = 5 ;
    }
    return self;
}

- (CGFloat)attriTextHeight{
    if(_attriTextHeight == 0){
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = self.lineSpace;
        paraStyle.alignment = self.alignment;
        
        NSDictionary *dic = @{NSFontAttributeName:self.textFont,NSParagraphStyleAttributeName:paraStyle};
        CGSize size = [self.originalText boundingRectWithSize:CGSizeMake(self.maxAttriTextWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
        _attriTextHeight = size.height + self.textHeightOffset;
    }
    return _attriTextHeight;
}

- (NSAttributedString *)attriText{
    if(!_attriText){
        NSString *comment = self.originalText ;
        if(!comment.length){
            comment = @"";
        }
        NSRange range = NSMakeRange(0, comment.length) ;
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]initWithString:comment];
        [attriStr setAttributedString:[[NSAttributedString alloc]initWithString:comment attributes:nil]];
        [attriStr addAttribute:NSForegroundColorAttributeName value:self.textColor range:range];
        [attriStr addAttribute:NSFontAttributeName value:self.textFont range:range];
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.lineSpacing = self.lineSpace;
        paraStyle.alignment = self.alignment;
        [attriStr addAttribute:NSParagraphStyleAttributeName value:paraStyle range:range];
        _attriText = attriStr;
    }
    return _attriText;
}

- (void)setSubstringAttribute:(NSString *)subStr attributed:(NSDictionary *)attriInfo{
    NSInteger fromIndex = 0 ;
    NSString *tempString = self.originalText;
    NSRange range = [tempString rangeOfString:subStr];
    while (range.location != NSNotFound) {
        range.location += fromIndex;
        for(NSString *key in attriInfo.allKeys){
            [self.attriText removeAttribute:key range:range];
            [self.attriText addAttribute:key value:attriInfo[key] range:range];
        }
        fromIndex = range.length + range.location ;
        tempString = [self.originalText substringFromIndex:fromIndex];
        range = [tempString rangeOfString:subStr];
    }
}

@end
