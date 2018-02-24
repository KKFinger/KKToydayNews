//
//  KKMediaAlbumInfo.h
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface KKMediaAlbumInfo : NSObject
@property(nonatomic,copy)NSString *albumId;
@property(nonatomic,copy)NSString *albumName;
@property(nonatomic,assign)NSInteger assetCount;
@property(nonatomic,assign)BOOL canDeleteItem;//是否可以删除相片
@property(nonatomic,assign)BOOL isRecentDelete;//是否是最近删除相册
@property(nonatomic,assign)BOOL canDelete;//相册是否可以被删除
@property(nonatomic,assign)BOOL canRename;//是否可以重命名
@property(nonatomic,assign)BOOL canAddItem;//是否可以添加相片
@property(nonatomic,assign)PHAssetCollectionSubtype assetSubType;
@end
