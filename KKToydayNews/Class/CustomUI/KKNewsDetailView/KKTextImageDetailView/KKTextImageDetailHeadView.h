//
//  KKTextImageDetailHeadView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/10.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,KKSortCommentType){
    KKSortCommentTypeHot,
    KKSortCommentTypeTime
};

@protocol KKTextImageDetailHeadViewDelegate <NSObject>
- (void)sortCommentByType:(KKSortCommentType)type;
@end

@interface KKTextImageDetailHeadView : UIView
@property(nonatomic,weak)id<KKTextImageDetailHeadViewDelegate>delegate;
@property(nonatomic,readonly)UIImageView *contentImageView;
- (void)refreshWithItem:(KKSummaryContent *)item;
@end
