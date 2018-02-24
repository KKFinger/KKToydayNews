//
//  KKGalleryPreviewCell.h
//  KKToydayNews
//
//  Created by finger on 2017/10/27.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKImageZoomView.h"

@interface KKGalleryPreviewCell : UICollectionViewCell
@property(nonatomic,readonly)KKImageZoomView *conetntImageView;
@property(nonatomic,readwrite)UIImage *image;
@property(nonatomic,readwrite,copy)NSString *imageUrl;
- (void)showImageWithUrl:(NSString *)url placeHolder:(UIImage *)image ;
@end
