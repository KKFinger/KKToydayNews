//
//  KKButton.h
//  KKToydayNews
//
//  Created by finger on 2017/10/9.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKButton : UIButton
@property(nonatomic,assign)CGFloat contentViewCornerRadius;
@property(nonatomic,assign)UIRectCorner cornerEdge;
- (void)layoutButtonWithEdgeInsetsStyle:(KKButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)padding;
@end
