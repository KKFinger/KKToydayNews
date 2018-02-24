//
//  KKGalleryVideoPreviewCell.h
//  KKToydayNews
//
//  Created by finger on 2017/10/27.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKXiaoShiPingPlayer.h"
#import "KKVideoInfo.h"

@interface KKGalleryVideoPreviewCell : UICollectionViewCell
@property(nonatomic,readonly)KKXiaoShiPingPlayer *videoPlayView;
@property(nonatomic,weak)UIImage *corverImage;
@property(nonatomic,weak)NSString *playUrl;
@end
