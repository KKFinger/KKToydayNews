//
//  KKNavTitleView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/30.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKNavTitleView : UIView
@property(nonatomic,copy)NSArray *leftBtns;
@property(nonatomic,copy)NSArray *rightBtns;
@property(nonatomic)UIView *titleView ;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,readonly)UILabel *titleLabel;
@property(nonatomic,readonly)UIView *splitView;

@property(nonatomic,assign)CGFloat contentOffsetY;

- (instancetype)initWithTitle:(NSString *)title
                     leftBtns:(NSArray *)leftBtns
                    rightBtns:(NSArray *)rightBtns;

@end
