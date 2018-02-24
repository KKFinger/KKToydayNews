//
//  KKRecognizeSimultaneousTableView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKRecognizeSimultaneousTableView.h"

@implementation KKRecognizeSimultaneousTableView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
