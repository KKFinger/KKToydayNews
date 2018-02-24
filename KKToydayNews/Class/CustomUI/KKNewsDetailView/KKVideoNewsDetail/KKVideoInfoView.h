//
//  KKVideoInfoView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKVideoInfoView : UIView
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *playCount;
@property(nonatomic,copy)NSString *publicTime;
@property(nonatomic,copy)NSString *descText;
@property(nonatomic,copy)NSString *diggCount;
@property(nonatomic,copy)NSString *disDiggCount;

@property(nonatomic,assign,readonly)CGFloat viewHeight;

@property(nonatomic,copy)void(^changeViewHeight)(CGFloat height) ;

@end
