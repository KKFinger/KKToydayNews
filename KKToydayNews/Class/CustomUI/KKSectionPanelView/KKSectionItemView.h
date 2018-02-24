//
//  KKSectionItemView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSectionItem.h"

@protocol KKSectionItemViewDelegate;
@interface KKSectionItemView : UIView
@property(nonatomic,assign)BOOL favorite;
@property(nonatomic,assign)BOOL hideCloseButton;
@property(nonatomic,assign)BOOL selected;
@property(nonatomic,weak)id<KKSectionItemViewDelegate>delegate;
@property(nonatomic,strong)KKSectionItem *sectionItem;
@end

@protocol KKSectionItemViewDelegate <NSObject>
- (void)clickSectionItemView:(KKSectionItemView *)view;
- (void)closeBtnClicked:(KKSectionItemView *)view;
@end
