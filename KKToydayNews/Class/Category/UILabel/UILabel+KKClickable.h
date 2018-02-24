//
//  UILabel+KKClickable.h
//
//  Created by LYB on 16/7/1.
//  Copyright © 2016年 LYB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKAttributeTapActionDelegate <NSObject>
@optional
/**
 *  KKAttributeTapActionDelegate
 *
 *  @param string  点击的字符串
 *  @param range   点击的字符串range
 *  @param index 点击的字符在数组中的index
 */
- (void)attributeTapReturnString:(NSString *)string
                           range:(NSRange)range
                           index:(NSInteger)index;
@end

/**
 可点击的字符信息
 */
@interface KKAttributeModel : NSObject
@property (nonatomic, copy) NSString *str;
@property (nonatomic, assign) NSRange range;
@end


@interface UILabel (KKClickable)


@property(nonatomic)id userData ;


/**
 *  是否打开点击效果，默认是打开
 */
@property (nonatomic, assign) BOOL enabledTapEffect;



/**
 是否设置了可点击的字符串
 */
@property (nonatomic , assign) BOOL hasTapString;

/**
 *  给文本添加点击事件Block回调
 *
 *  @param strings  需要点击功能的字符串数组
 *  @param tapClick 点击事件回调
 */
- (void)addAttributeTapActionWithStrings:(NSArray <NSString *> *)strings
                              tapClicked:(void (^) (NSString *string , NSRange range , NSInteger index))tapClick;

/**
 *  给文本添加点击事件delegate回调
 *
 *  @param strings  需要点击功能的字符串数组
 *  @param delegate delegate
 */
- (void)addAttributeTapActionWithStrings:(NSArray <NSString *> *)strings
                                delegate:(id <KKAttributeTapActionDelegate> )delegate;

@end

