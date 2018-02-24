//
//  KKGalleryImageCell.h
//  KKToydayNews
//
//  Created by finger on 2017/10/22.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPhotoInfo.h"

typedef NS_ENUM(NSInteger, KKGalleryCellType){
    KKGalleryCellTypeDelete,
    KKGalleryCellTypeSelect,
} ;

@class KKGalleryImageCell;
@protocol KKGalleryImageCellDelegate <NSObject>
@optional
- (void)deleteImage:(KKGalleryImageCell *)cell;
- (void)selectImage:(KKGalleryImageCell *)cell photoItem:(KKPhotoInfo *)item;
@end

@interface KKGalleryImageCell : UICollectionViewCell
@property(nonatomic,weak)id<KKGalleryImageCellDelegate>delegate;
@property(nonatomic,readonly)UIView *contentBgView;
@property(nonatomic,readonly)UIImageView *imageView;
@property(nonatomic,assign)BOOL disable;
- (void)refreshCell:(KKPhotoInfo *)item cellType:(KKGalleryCellType)type disable:(BOOL)disable;
#pragma mark -- 选中动画
- (void)selectAnimate;
@end
