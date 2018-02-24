//
//  KKSectionCollectionCell.h
//  KKToydayNews
//
//  Created by finger on 2017/8/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSectionItem.h"

@interface KKSectionCollectionCell : UICollectionViewCell

@property(nonatomic)KKSectionItem *item ;
@property(nonatomic)BOOL isSelected;//是否选择
@property(nonatomic,strong)UILabel *titleLabel ;

+ (CGSize)titleSize:(KKSectionItem *)item;
+ (CGFloat)normalFontSize;
+ (CGFloat)selectedFontSize;
+ (UIColor *)normalColor;
+ (UIColor *)selectedColor;

@end
