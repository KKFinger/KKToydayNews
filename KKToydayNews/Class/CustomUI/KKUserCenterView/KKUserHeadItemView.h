//
//  KKUserHeadItemView.h
//  KKToydayNews
//
//  Created by finger on 2017/12/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKUserHeadItemView : UIView
@property(nonatomic,readonly)UILabel *titleLabel;
@property(nonatomic,readonly)UILabel *detailLabel;
@property(nonatomic,readonly)UIImageView *imageView;
@property(nonatomic,assign)CGSize imageSize;
- (instancetype)initWithShowImage:(BOOL)showImage;
@end
