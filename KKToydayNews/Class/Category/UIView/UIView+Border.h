//
//  UIView+Border.h
//  KKToydayNews
//
//  Created by finger on 2017/10/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KKBorderType){
    KKBorderTypeNone = 0,
    KKBorderTypeLeft = 1 << 0,
    KKBorderTypeTop = 1 << 1,
    KKBorderTypeRight = 1 << 2,
    KKBorderTypeBottom = 1 << 3,
    KKBorderTypeAll = 1 << 4,
} ;


@interface UIView(Border)
@property(nonatomic)UIColor *borderColor;
@property(nonatomic,assign)KKBorderType borderType;
@property(nonatomic,assign)CGFloat borderThickness;
@end
