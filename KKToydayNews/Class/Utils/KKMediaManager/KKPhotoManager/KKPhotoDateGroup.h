//
//  KKPhotoDateGroup.h
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface KKPhotoDateGroup : NSObject
@property(nonatomic,copy)NSString *dateString;
@property(nonatomic)NSMutableArray *indexArray;
@property(nonatomic)NSMutableArray *identifierArray;
@end
