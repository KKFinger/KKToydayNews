//
//  KKForwardRewindView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKForwardRewindView : UIView
@property(nonatomic,assign)BOOL isForward;
@property(nonatomic,copy)NSString *curtTime;
@property(nonatomic,copy)NSString *totalTime;
@property(nonatomic,assign)CGFloat percent;
@end
