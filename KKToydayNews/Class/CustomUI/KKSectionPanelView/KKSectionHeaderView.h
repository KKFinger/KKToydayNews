//
//  KKSectionHeaderView.h
//  KKToydayNews
//
//  Created by finger on 2017/8/8.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKSectionHeaderView : UIView
@property(nonatomic,copy)NSString *titleText;
@property(nonatomic,copy)NSString *detailText;
@property(nonatomic,assign)BOOL isEdit ;
@property(nonatomic,assign)BOOL hiddenEditBtn;
@property(nonatomic,copy)void(^enditBtnClickHandler)(BOOL isEdit);
@end
