//
//  KKSectionTopBarView.h
//  KKToydayNews
//
//  Created by finger on 2017/8/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSectionItem.h"

@protocol KKSectionTopBarViewDelegate;
@interface KKSectionTopBarView : UIView
@property(nonatomic,weak)id<KKSectionTopBarViewDelegate>delegate ;
@property(nonatomic,strong)NSArray<KKSectionItem *> *sectionItems;
@property(nonatomic,assign)NSInteger selectedIndex;
@property(nonatomic,copy)NSString *curtSelCatagory;
@property(nonatomic,assign)BOOL hideAddBtn;

//#pragma mark -- 颜色渐变
//
//- (void)scrollToRight:(BOOL)toRight percent:(CGFloat)percent;

@end

@protocol KKSectionTopBarViewDelegate <NSObject>
@optional
- (void)selectedSectionItem:(KKSectionItem *)item ;
- (void)addMoreSectionClicked;
@end
