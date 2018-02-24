//
//  KKIndicatorView.h
//  KKToydayNews
//
//  Created by finger on 2017/8/17.
//  Copyright © 2017年 finger All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKIndicatorViewDelegate <NSObject>
- (void)selectIndex:(NSInteger)index title:(NSString *)title;
@end

@interface KKIndicatorView : UIView
@property(nonatomic,weak)id<KKIndicatorViewDelegate>delegate;
@property(nonatomic)NSArray *titleArray;
@property(nonatomic)UIColor *selectedColor;//选中的颜色
@property(nonatomic)UIColor *normalColor;//未选中颜色
@property(nonatomic)UIColor *bottomLineColor;//下划线颜色，默认跟选择颜色一样
@property(nonatomic)UIFont *titleFont;//
@property(nonatomic)CGFloat btnWith;
@property(nonatomic,assign)CGFloat bottomLineWidth;//下划线的宽度
@property(nonatomic,assign)CGFloat bottomLineHeight;//下划线的高度
@property(nonatomic,assign)CGFloat bottomLinePadding;//下划线距离底部的高度
@property(nonatomic,assign)NSInteger selectedIndex;//选择的索引

- (instancetype)initWithTitleArray:(NSArray *)titleArray;
- (NSInteger)fetchTitleCount;

@end
