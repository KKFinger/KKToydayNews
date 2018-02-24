//
//  KKEditRecordCorverView.h
//  KKToydayNews
//
//  Created by finger on 2017/11/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDragableBaseView.h"
#import "KKVideoInfo.h"

@protocol KKEditRecordCorverViewDelegate <NSObject>
- (void)endEditCorverWithImage:(UIImage *)image;
@end

@interface KKEditRecordCorverView : KKDragableBaseView
@property(nonatomic,weak)id<KKEditRecordCorverViewDelegate>delegate;
- (instancetype)initWithVideoInfo:(KKVideoInfo *)videoInfo;
@end
