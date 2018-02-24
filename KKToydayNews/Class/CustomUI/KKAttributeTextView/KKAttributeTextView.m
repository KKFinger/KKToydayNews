//
//  KKAttributeTextView.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKAttributeTextView.h"

#define  kCoverViewTag 111

@interface KKAttributeTextView()
@property (nonatomic, strong)NSMutableArray *rectsArray;
@property (nonatomic, strong)NSMutableAttributedString *attriContent;
@end

@implementation KKAttributeTextView
@synthesize textColor = _textColor;
@synthesize font = _font;
@synthesize textAlignment = _textAlignment;
@synthesize text = _text ;

- (id)init{
    self = [super init];
    if(self){
        // 如果说 UITextView 设置了不能编辑，并且又设置上了文字，直接运行第一次会发现文字加载不出来
        [self setEditable:NO];
        // 必须实现 ScrollView 禁止滚动才行
        [self setScrollEnabled:NO];
    }
    return self;
}

- (id)initWithText:(NSString *)text textColor:(UIColor *)textColor textFont:(UIFont *)font textAlignment:(NSTextAlignment)textAlignment lineSpace:(CGFloat)lineSpace{
    self = [super initWithFrame:CGRectZero];
    if(self){
        self.text = text;
        self.textColor = textColor;
        self.font = font;
        self.textAlignment = textAlignment;
        
        // 如果说 UITextView 设置了不能编辑，并且又设置上了文字，直接运行第一次会发现文字加载不出来
        [self setEditable:NO];
        // 必须实现 ScrollView 禁止滚动才行
        [self setScrollEnabled:NO];
        
        self.attriContent = [[NSMutableAttributedString alloc] initWithString:text];
        [self.attriContent addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, text.length)];
        [self.attriContent addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, text.length)];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = self.textAlignment;
        if(lineSpace){
            paragraphStyle.lineSpacing = lineSpace;
        }
        [self.attriContent addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    }
    return self ;
}

#pragma mark -- @property setter

- (void)setTextColor:(UIColor *)textColor{
    if(textColor == nil){
        return ;
    }
    _textColor = textColor ;
    [self.attriContent removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(0, self.text.length)];
    [self.attriContent addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, self.text.length)];
}

- (void)setText:(NSString *)text{
    _text = text;
    
    self.attriContent = [[NSMutableAttributedString alloc] initWithString:text];
    [self setTextColor:_textColor];
    [self setFont:_font];
    [self setTextAlignment:_textAlignment];
}

- (void)setFont:(UIFont *)font{
    if(!font){
        return ;
    }
    _font = font;
    [self.attriContent removeAttribute:NSFontAttributeName range:NSMakeRange(0, self.text.length)];
    [self.attriContent addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, self.text.length)];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment{
    _textAlignment = textAlignment ;
    [self.attriContent removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, self.text.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineSpacing = self.lineSpace;
    [self.attriContent addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
}

- (void)setLineSpace:(CGFloat)lineSpace{
    _lineSpace = lineSpace ;
    [self.attriContent removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, self.text.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.lineSpacing = _lineSpace;
    [self.attriContent addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
}

#pragma mark -- 设置textView的部分为下划线且可设置是否可以点击
/**
 *  设置textView的部分为下划线，并且使之可以点击
 *
 *  @param underlineTextRange 需要下划线的文字范围，如果NSRange范围超出总的内容，将过滤掉
 *  @param color              下划线的颜色，以及下划线上面文字的颜色
 *  @param coverColor         是否有点击的背景，如果设置相关颜色的话，将会有点击效果，如果为nil将没有点击效果
 *  @param block              点击文字的时候的回调
 */

- (void)setUnderlineTextWithRange:(NSRange)underlineTextRange
               withUnderlineColor:(UIColor *)color
              withClickCoverColor:(UIColor *)coverColor
                        withBlock:(clickTextViewPartBlock)block{
    
    if (self.text.length < underlineTextRange.location+underlineTextRange.length) {
        return;
    }
    
    // 设置下划线
    [self.attriContent addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:underlineTextRange];
    
    //设置文字颜色
    if (color) {
        [self.attriContent addAttribute:NSForegroundColorAttributeName value:color range:underlineTextRange];
    }
    self.attributedText = self.attriContent;
    
    // 设置下划线文字的点击事件
    // self.selectedRange  影响  self.selectedTextRange
    self.selectedRange = underlineTextRange;
    
    // 获取选中范围内的矩形框
    NSArray *selectionRects = [self selectionRectsForRange:self.selectedTextRange];
    // 清空选中范围
    self.selectedRange = NSMakeRange(0, 0);
    // 可能会点击的范围的数组
    NSMutableArray *selectedArray = [[NSMutableArray alloc] init];
    for (UITextSelectionRect *selectionRect in selectionRects) {
        CGRect rect = selectionRect.rect;
        if (rect.size.width == 0 || rect.size.height == 0) {
            continue;
        }
        // 将有用的信息打包<存放到字典中>存储到数组中
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        // 存储文字对应的frame，一段文字可能会有两个甚至多个frame，考虑到文字换行问题
        [dic setObject:[NSValue valueWithCGRect:rect] forKey:@"rect"];
        // 存储下划线对应的文字
        [dic setObject:[self.text substringWithRange:underlineTextRange] forKey:@"content"];
        // 存储相应的回调的block
        if(block){
            [dic setObject:block forKey:@"block"];
        }
        // 存储对应的点击效果背景颜色
        [dic setValue:coverColor forKey:@"coverColor"];
        [selectedArray addObject:dic];
    }
    // 将可能点击的范围的数组存储到总的数组中
    [self.rectsArray addObject:selectedArray];
}

#pragma mark -- 设置textView的部分背景色、字体大小、字体颜色、且可设置是否可以点击

- (void)setTextWithRange:(NSRange)range//范围
          backgroupColor:(UIColor *)bgColor//背景色
               textColor:(UIColor *)textColor//字体颜色
                textFont:(UIFont *)textFont//字体
         clickCoverColor:(UIColor *)coverColor//点击后的颜色
              clickBlock:(clickTextViewPartBlock)block{
    
    if (self.text.length < range.location+range.length) {
        return;
    }
    
    //设置文字颜色
    if (textColor) {
        [self.attriContent removeAttribute:NSForegroundColorAttributeName range:range];
        [self.attriContent addAttribute:NSForegroundColorAttributeName value:textColor range:range];
    }
    //设置背景色
    if (bgColor) {
        [self.attriContent removeAttribute:NSBackgroundColorAttributeName range:range];
        [self.attriContent addAttribute:NSBackgroundColorAttributeName value:bgColor range:range];
    }
    //设置字体
    if (textFont) {
        [self.attriContent removeAttribute:NSFontAttributeName range:range];
        [self.attriContent addAttribute:NSFontAttributeName value:textFont range:range];
    }
    
    [self.rectsArray removeAllObjects];
    
    self.attributedText = self.attriContent;
    
    // 设置下划线文字的点击事件
    // self.selectedRange  影响  self.selectedTextRange
    self.selectedRange = range;
    
    // 获取选中范围内的矩形框
    NSArray *selectionRects = [self selectionRectsForRange:self.selectedTextRange];
    // 清空选中范围
    self.selectedRange = NSMakeRange(0, 0);
    // 可能会点击的范围的数组
    NSMutableArray *selectedArray = [[NSMutableArray alloc] init];
    for (UITextSelectionRect *selectionRect in selectionRects) {
        CGRect rect = selectionRect.rect;
        if (rect.size.width == 0 || rect.size.height == 0) {
            continue;
        }
        // 将有用的信息打包<存放到字典中>存储到数组中
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        // 存储文字对应的frame，一段文字可能会有两个甚至多个frame，考虑到文字换行问题
        [dic setObject:[NSValue valueWithCGRect:rect] forKey:@"rect"];
        // 存储下划线对应的文字
        [dic setObject:[self.text substringWithRange:range] forKey:@"content"];
        // 存储相应的回调的block
        if(block){
            [dic setObject:block forKey:@"block"];
        }
        // 存储对应的点击效果背景颜色
        [dic setValue:coverColor forKey:@"coverColor"];
        
        [selectedArray addObject:dic];
    }
    // 将可能点击的范围的数组存储到总的数组中
    [self.rectsArray addObject:selectedArray];
}

#pragma mark -- 点击视图

// 点击textView的 touchesBegan 方法
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // 获取触摸对象
    UITouch *touch = [touches anyObject];
    // 触摸点
    CGPoint point = [touch locationInView:self];
    // 通过一个触摸点，查询点击的是不是在下划线对应的文字的frame
    NSArray *selectedArray = [self touchingSpecialWithPoint:point];
    for (NSDictionary *dic in selectedArray) {
        if(dic && dic[@"coverColor"]){
            UIView *cover = [[UIView alloc] init];
            cover.backgroundColor = dic[@"coverColor"];
            cover.frame = [dic[@"rect"] CGRectValue];
            cover.layer.cornerRadius = 5;
            cover.tag = kCoverViewTag;
            [self insertSubview:cover atIndex:0];
        }
    }
    if (selectedArray.count) {
        // 如果说有点击效果的话，加个延时，展示下点击效果,如果没有点击效果的话，直接回调
        NSDictionary *dic = [selectedArray firstObject];
        clickTextViewPartBlock block = dic[@"block"];
        if(block){
            if (dic[@"coverColor"]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    block(dic[@"content"]);
                });
            }else{
                block(dic[@"content"]);
            }
        }
    }
}

- (NSArray *)touchingSpecialWithPoint:(CGPoint)point{
    // 从所有的特殊的范围中找到点击的那个点
    for (NSArray *selecedArray in self.rectsArray) {
        for (NSDictionary *dic in selecedArray) {
            CGRect myRect = [dic[@"rect"] CGRectValue];
            if(CGRectContainsPoint(myRect, point) ){
                return selecedArray;
            }
        }
    }
    return nil;
}

/** 点击结束的时候 */
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIView *subView in self.subviews) {
            if (subView.tag == kCoverViewTag) {
                [subView removeFromSuperview];
            }
        }
    });
}

/**
 *  取消点击的时候,清除相关的阴影
 */
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UIView *subView in self.subviews) {
        if (subView.tag == kCoverViewTag) {
            [subView removeFromSuperview];
        }
    }
}

#pragma mark -- @property getter

- (NSMutableArray *)rectsArray{
    if (_rectsArray == nil) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        _rectsArray = array;
    }
    return _rectsArray;
}

@end
