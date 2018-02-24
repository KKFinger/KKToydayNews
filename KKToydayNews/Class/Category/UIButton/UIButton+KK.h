//
//  UIButton+KK.h
//  KKToydayNews
//
//  Created by finger on 2017/9/12.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSectionItem.h"

/*
 针对同时设置了Image和Title的场景时UIButton中的图片和文字的关系
 */
typedef NS_ENUM(NSInteger, KKButtonEdgeInsetsStyle ) {
    KKButtonEdgeInsetsStyleDefault = 0,       //图片在左，文字在右，整体居中。
    KKButtonEdgeInsetsStyleLeft  = 0,         //图片在左，文字在右，整体居中。
    KKButtonEdgeInsetsStyleRight     = 2,     //图片在右，文字在左，整体居中。
    KKButtonEdgeInsetsStyleTop  = 3,          //图片在上，文字在下，整体居中。
    KKButtonEdgeInsetsStyleBottom    = 4,     //图片在下，文字在上，整体居中。
    KKButtonEdgeInsetsStyleCenterTop = 5,     //图片居中，文字在上距离按钮顶部。
    KKButtonEdgeInsetsStyleCenterBottom = 6,  //图片居中，文字在下距离按钮底部。
    KKButtonEdgeInsetsStyleCenterUp = 7,      //图片居中，文字在图片上面。
    KKButtonEdgeInsetsStyleCenterDown = 8,    //图片居中，文字在图片下面。
    KKButtonEdgeInsetsStyleRightLeft = 9,     //图片在右，文字在左，距离按钮两边边距
    KKButtonEdgeInsetsStyleLeftRight = 10,    //图片在左，文字在右，距离按钮两边边距
};

@interface UIButton(KK)
@property(nonatomic,strong)KKSectionItem *sectionItem;
- (void)setEdgeInsetsStyle:(KKButtonEdgeInsetsStyle)style
         imageTitlePadding:(CGFloat)padding;
@end
