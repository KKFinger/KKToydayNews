//
//  KKDragableNavBaseView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/30.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKNavTitleView.h"
#import "KKDragableBaseView.h"

@interface KKDragableNavBaseView : KKDragableBaseView
@property(nonatomic,assign)BOOL hideNavTitleView;
@property(nonatomic,assign)CGFloat navTitleHeight;
@property(nonatomic,assign)CGFloat navContentOffsetY;
@property(nonatomic,readonly)KKNavTitleView *navTitleView;
@end
