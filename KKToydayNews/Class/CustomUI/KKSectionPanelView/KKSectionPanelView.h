//
//  KKSectionPanelView.h
//  KKToydayNews
//
//  Created by finger on 2017/8/8.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKDragableBaseView.h"

@class KKSectionItem;
@interface KKSectionPanelView : KKDragableBaseView

@property(nonatomic,copy)void(^closeHandler)(BOOL sectionDataChanged);
@property(nonatomic,copy)void(^jumpToViewByItemHandler)(KKSectionItem *item,BOOL sectionDataChanged);
@property(nonatomic,copy)void(^addOrRemoveSectionHandler)(KKSectionOpType opType,KKSectionItem *item);
@property(nonatomic,copy)void(^userSectionOrderChangeHandler)(NSInteger fromIndex,NSInteger toIndex);

@property(nonatomic)NSString *curtSelCatagory;

@end
