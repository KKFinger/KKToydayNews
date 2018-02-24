//
//  KKPersonalCommentView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/29.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKCommentModal.h"
#import "KKDragableNavBaseView.h"

@interface KKPersonalCommentView : KKDragableNavBaseView

@property(nonatomic,copy)void(^jumpToUserPageByItemHandler)(KKCommentObj *item);

- (instancetype)initWithCommentId:(NSString *)commentId;

@end
