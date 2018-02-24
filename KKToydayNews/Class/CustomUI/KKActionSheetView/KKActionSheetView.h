//
//  KKActionSheetView.h
//  KKToydayNews
//
//  Created by finger on 2017/11/27.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^selectedCallback)(NSString *content);

@interface KKActionSheetView : UIView
- (instancetype)initWithTitle:(NSString *)title contentArray:(NSArray *)contentArray callback:(selectedCallback)callback;

#pragma mark -- 显示&消失

- (void)showActionSheet;
- (void)hideActionSheet;

@end
