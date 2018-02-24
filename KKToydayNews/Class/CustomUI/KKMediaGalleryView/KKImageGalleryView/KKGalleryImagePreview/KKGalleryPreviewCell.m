//
//  KKGalleryPreviewCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/27.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKGalleryPreviewCell.h"

@interface KKGalleryPreviewCell()
@property(nonatomic,readwrite)KKImageZoomView *conetntImageView;
@end

@implementation KKGalleryPreviewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.contentView addSubview:self.conetntImageView];
    [self.conetntImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(UIDeviceScreenWidth);
    }];
}

#pragma mark -- @property setter

- (void)setImage:(UIImage *)image{
    self.conetntImageView.image = image;
}

- (void)setImageUrl:(NSString *)imageUrl{
    self.conetntImageView.imageUrl = imageUrl;
}

- (void)showImageWithUrl:(NSString *)url placeHolder:(UIImage *)image {
    [self.conetntImageView showImageWithUrl:url placeHolder:image];
}

#pragma mark -- @property getter

- (KKImageZoomView *)conetntImageView{
    if(!_conetntImageView){
        _conetntImageView = ({
            KKImageZoomView *view = [[KKImageZoomView alloc]initWithFrame:CGRectZero];
            view ;
        });
    }
    return _conetntImageView;
}

@end
