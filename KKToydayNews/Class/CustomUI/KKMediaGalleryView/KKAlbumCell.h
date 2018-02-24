//
//  KKAlbumCell.h
//  KKToydayNews
//
//  Created by finger on 2017/10/23.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKMediaAlbumInfo.h"

typedef NS_ENUM(NSInteger, KKAlbumCellType){
    KKAlbumCellImage,
    KKAlbumCellVideo,
} ;

@interface KKAlbumCell : UITableViewCell
- (void)refreshWith:(KKMediaAlbumInfo *)albumIfo curtSelAlbumId:(NSString *)albumId cellType:(KKAlbumCellType)type;
@end
