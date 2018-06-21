//
//  KKInputView.h
//  KKInputView
//
//  Created by finger on 2017/8/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKInputViewDelegate <NSObject>
- (void)endEditWithInputText:(NSString *)inputText;
@end

@interface KKInputView : UIView
@property(nonatomic,weak)id<KKInputViewDelegate>delegate;
- (void)showKeyBoard;
- (void)hideKeyBoard;
@end
