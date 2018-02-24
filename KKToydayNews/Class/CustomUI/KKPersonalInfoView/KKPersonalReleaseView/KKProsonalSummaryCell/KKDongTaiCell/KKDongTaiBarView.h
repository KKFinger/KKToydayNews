//
//  KKDongTaiBarView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKDongTaiBarView : UIView
@property(nonatomic,weak)id<KKCommonDelegate>delegate;
@property(nonatomic,copy)NSString *upVoteCount;
@property(nonatomic,copy)NSString *commentCount;
@property(nonatomic,copy)NSString *shareCount;
@end
