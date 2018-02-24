//
//  KKTextImageDetailView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/9.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKDragableNavBaseView.h"

@interface KKTextImageDetailView : KKDragableNavBaseView
- (instancetype)initWithContentItem:(__weak KKSummaryContent *)item sectionItem:(__weak KKSectionItem *)item;
@end
