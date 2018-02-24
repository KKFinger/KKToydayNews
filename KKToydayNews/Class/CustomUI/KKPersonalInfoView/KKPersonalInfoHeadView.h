//
//  KKPersonalInfoHeadView.h
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKPersonalInfoHeadView : UIView
@property(nonatomic,readonly)UIImageView *userHeadView;
@property(nonatomic,copy)void(^heightOffsetBlock)(CGFloat heightOffset);
@property(nonatomic)NSString *headUrl;
@property(nonatomic)NSString *userName;
@property(nonatomic)NSString *verified;
@property(nonatomic)NSString *desc;
- (void)setFans:(NSString *)fans follows:(NSString *)follows;
@end
