//
//  KKRecordPreview.h
//  KKToydayNews
//
//  Created by finger on 2017/11/5.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDragableBaseView.h"
#import "KKVideoInfo.h"

@interface KKRecordPreview : KKDragableBaseView
@property(nonatomic)void(^viewWillDisapear)();
- (instancetype)initWithVideoInfo:(KKVideoInfo *)videoInfo;
@end
