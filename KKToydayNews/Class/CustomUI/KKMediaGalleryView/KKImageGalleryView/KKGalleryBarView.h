//
//  KKGalleryBarView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKGalleryBarViewDelegate <NSObject>
- (void)previewImage;
@end

@interface KKGalleryBarView : UIView
@property(nonatomic,weak)id<KKGalleryBarViewDelegate>delegate;
@property(nonatomic,assign)BOOL enablePreview;
@end
