//
//  KKShareView.h
//  KKShareView
//
//  Created by finger on 2017/8/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKShareItem.h"

@protocol KKShareViewDelegate <NSObject>
@optional
- (void)shareWithType:(KKShareType)shareType;
@end

@interface KKShareView : UIView
@property(nonatomic,weak)id<KKShareViewDelegate>delegate;
@property(nonatomic,copy)NSArray<NSArray<KKShareItem*>*> *shareInfos;
- (void)showShareView;
@end
