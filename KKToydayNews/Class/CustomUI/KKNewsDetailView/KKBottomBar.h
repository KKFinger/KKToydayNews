//
//  KKBottomBar.h
//  KKToydayNews
//
//  Created by finger on 2017/9/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKTextView.h"

@protocol KKBottomBarDelegate <NSObject>
@optional
- (void)sendCommentWidthText:(NSString *)text;
- (void)favoriteNews:(BOOL)isFavorite callback:(void(^)(BOOL suc))callback;
- (void)diggComment:(BOOL)isDigg callback:(void(^)(BOOL suc))callback;
- (void)shareNews;
- (void)showCommentView;
@end

@interface KKBottomBar : UIView
@property(nonatomic,weak)id<KKBottomBarDelegate>delegate;
@property(nonatomic,assign)NSInteger commentCount;
@property(nonatomic,assign)BOOL isDigg;//是否已经点赞
@property(nonatomic,readonly)UIView *splitView;
@property(nonatomic,readonly)KKTextView *textView;
@property(nonatomic,readonly)CGFloat offsetY;
- (instancetype)initWithBarType:(KKBottomBarType)barType;

@end
