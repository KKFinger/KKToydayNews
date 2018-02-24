//
//  NSArray+Safe.h
//  KKToydayNews
//
//  Created by finger on 2017/8/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType>(Safe)

- (ObjectType)safeObjectAtIndex:(NSInteger)index;

- (NSArray *)safeSubarrayWithRange:(NSRange)range;

- (NSArray *)head:(NSUInteger)count;

@end

@interface NSMutableArray<ObjectType> (Safe)

- (void)safeAddObject:(ObjectType)aObj;
- (void)safeInsertObj:(id)aObj atIndex:(NSInteger)index;
- (void)safeRemoveObjectAtIndex:(NSInteger)index;

@end
