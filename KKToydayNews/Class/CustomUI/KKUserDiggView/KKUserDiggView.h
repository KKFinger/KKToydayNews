//
//  KKUserDiggView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDragableNavBaseView.h"

@interface KKUserDiggView : KKDragableNavBaseView<KKCommentDelegate>

@property(nonatomic,weak)id<KKCommentDelegate>delegate;

- (instancetype)initWithCommentId:(NSString *)commentId totalDiggCount:(NSString *)diggCount;

@end
