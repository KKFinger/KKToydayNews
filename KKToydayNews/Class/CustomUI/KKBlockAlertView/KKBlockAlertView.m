//
//  KKBlockAlertView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/13.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKBlockAlertView.h"

@interface KKBlockAlertView()<UIAlertViewDelegate>
{
    UIAlertView  *mAlert;
}
@property(nonatomic,strong)KKAlertBlock mAlertBlock;

@end

@implementation KKBlockAlertView
@synthesize mAlertBlock;

- (void)dealloc{
}

- (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSString *)otherButtonTitles
                block:(KKAlertBlock)handler{
    self.mAlertBlock = handler;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    [alertView show];
}

- (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSString *)otherButtonTitles
              timeout:(NSTimeInterval)timeout
                block:(KKAlertBlock)handler{
    self.mAlertBlock = handler;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
    [alertView show];
    
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:timeout];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    self.mAlertBlock(buttonIndex,nil);
}

- (void)dismissAlert:(id)sender{
    UIAlertView *alertView = (UIAlertView *)sender;
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end
