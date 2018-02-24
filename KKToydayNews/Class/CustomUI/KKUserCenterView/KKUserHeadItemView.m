//
//  KKUserHeadItemView.m
//  KKToydayNews
//
//  Created by finger on 2017/12/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKUserHeadItemView.h"

@interface KKUserHeadItemView()
@property(nonatomic,readwrite)UILabel *titleLabel;
@property(nonatomic,readwrite)UILabel *detailLabel;
@property(nonatomic,readwrite)UIImageView *imageView;
@property(nonatomic,assign)BOOL isShowImage;
@end

@implementation KKUserHeadItemView

- (instancetype)initWithShowImage:(BOOL)showImage{
    self = [super init];
    if(self){
        self.isShowImage = showImage;
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.titleLabel];
    [self addSubview:self.detailLabel];
    [self addSubview:self.imageView];
    
    self.imageSize = CGSizeMake(25, 25);
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_centerY).mas_offset(-1);
    }];
    
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        if(self.isShowImage){
            make.bottom.mas_equalTo(self).mas_offset(-8);
        }else{
            make.top.mas_equalTo(self.mas_centerY).mas_offset(2);
        }
    }];
    
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.imageSize);
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self).mas_offset(8);
    }];
}

#pragma mark -- @property setter

- (void)setImageSize:(CGSize)imageSize{
    _imageSize = imageSize;
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(imageSize);
    }];
}

#pragma mark -- @property getter

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:17];
            view.textAlignment = NSTextAlignmentCenter;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view ;
        });
    }
    return _titleLabel;
}

- (UILabel *)detailLabel{
    if(!_detailLabel){
        _detailLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.font = [UIFont systemFontOfSize:13];
            view.textAlignment = NSTextAlignmentCenter;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view ;
        });
    }
    return _detailLabel;
}

- (UIImageView *)imageView{
    if(!_imageView){
        _imageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFit;
            view ;
        });
    }
    return _imageView;
}

@end
