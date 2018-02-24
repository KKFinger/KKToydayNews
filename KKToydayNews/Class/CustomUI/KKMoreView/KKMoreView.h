//
//  KKMoreView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/20.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KKMoreViewType){
    KKMoreViewTypeText,
    KKMoreViewTypeImage,
    KKMoreViewTypeVideo,
    KKMoreViewTypeQuestion
} ;

@protocol KKMoreViewDelegate <NSObject>
- (void)showViewWithType:(KKMoreViewType)type;
@end

@interface KKMoreView : UIView
@property(nonatomic,weak)id<KKMoreViewDelegate>delegate;
- (void)showView;
- (void)hideView;
@end
