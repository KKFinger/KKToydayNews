//
//  KKSectionGroupView.h
//  KKToydayNews
//
//  Created by finger on 2017/8/9.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSectionItem.h"

@protocol KKSectionGroupViewDelegate;
@interface KKSectionGroupView : UIView

@property(nonatomic,weak)id<KKSectionGroupViewDelegate>delegate;

@property(nonatomic,assign)NSString *curtSelCatagory;//当前选择的板块
@property(nonatomic,assign)BOOL isEditState;//编辑状态

- (id)initWithFavorite:(BOOL)favorite;

#pragma mark -- 计算视图的高度

- (NSInteger)calculateViewHeight;

#pragma mark -- 删除/添加某个位置的板块

- (KKSectionItem *)removeItemAtIndex:(NSInteger)index animate:(BOOL)animate;

- (void)addItemAtIndex:(NSInteger)index item:(KKSectionItem *)item initRect:(CGRect)rect animate:(BOOL)animate;

@end

@protocol KKSectionGroupViewDelegate <NSObject>
- (void)longPressArise;
- (void)addOrRemoveItem:(KKSectionItem *)item itemOrgRect:(CGRect)rect opType:(KKSectionOpType)opType;
- (void)needJumpToSection:(KKSectionItem *)item;
- (void)userSectionOrderChangeFrom:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;//用户感兴趣的板块顺序发生改变
- (void)needAdjustView:(KKSectionGroupView *)view height:(CGFloat)height ;
@end
