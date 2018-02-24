//
//  KKWeiTouTiaoHeadView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKWeiTouTiaoHeadViewDelegate <NSObject>
- (void)shieldBtnClicked;
- (void)followBtnClicked;
- (void)userHeadClicked;
@end

@interface KKWeiTouTiaoHeadView : UIView
@property(nonatomic,weak)id<KKWeiTouTiaoHeadViewDelegate>delegate;
@property(nonatomic,copy)NSString *headUrl;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *desc;
@property(nonatomic,assign)BOOL isFollow;
@end

