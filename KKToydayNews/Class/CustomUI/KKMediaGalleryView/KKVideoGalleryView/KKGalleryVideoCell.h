//
//  KKGalleryVideoCell.h
//  KKToydayNews
//
//  Created by finger on 2017/10/22.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KKVideoInfo;
@interface KKGalleryVideoCell : UICollectionViewCell
@property(nonatomic,readonly)UIView *contentBgView;
@property(nonatomic)UIImage *corverImage;
- (void)refreshCell:(KKVideoInfo *)videoInfo;
@end
