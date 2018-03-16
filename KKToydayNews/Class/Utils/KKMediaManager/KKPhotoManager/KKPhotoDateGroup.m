//
//  KKPhotoDateGroup.m
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPhotoDateGroup.h"

@implementation KKPhotoDateGroup

- (NSMutableArray *)indexArray{
    if(!_indexArray){
        _indexArray = [NSMutableArray new];
    }
    return _indexArray;
}

- (NSMutableArray *)identifierArray{
    if(!_identifierArray){
        _identifierArray = [NSMutableArray new];
    }
    return _identifierArray;
}

@end
