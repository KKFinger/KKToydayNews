//
//  KKPersonalReleaseView.h
//  KKToydayNews
//
//  Created by finger on 2017/11/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPersonalModel.h"

@interface KKPersonalReleaseView : UIView
@property(nonatomic)NSArray<KKPersonalTopic *> *topicArray;
@property(nonatomic)BOOL canScroll;
@property(nonatomic,copy)void(^canScrollCallback)(BOOL canScroll);
- (instancetype)initWithTopicArray:(NSArray<KKPersonalTopic *> *)array userId:(NSString *)userId;
- (void)setTopicArray:(NSArray<KKPersonalTopic *> *)array userId:(NSString *)userId mediaId:(NSString *)mediaId;
@end
