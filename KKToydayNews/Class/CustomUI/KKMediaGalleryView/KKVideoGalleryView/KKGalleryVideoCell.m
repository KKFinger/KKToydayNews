//
//  KKGalleryVideoCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/22.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKGalleryVideoCell.h"
#import "KKVideoInfo.h"

#define durationLabelHeight 20

@interface KKGalleryVideoCell()
@property(nonatomic,readwrite)UIView *contentBgView;
@property(nonatomic)UIImageView *imageView;
@property(nonatomic)UILabel *durationLabel;
@property(nonatomic,weak)KKVideoInfo *item;
@end

@implementation KKGalleryVideoCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.contentView addSubview:self.contentBgView];
    [self.contentBgView addSubview:self.imageView];
    [self.contentBgView addSubview:self.durationLabel];
    
    [self.contentBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentBgView);
    }];
    
    [self.durationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentBgView).mas_offset(-5);
        make.bottom.mas_equalTo(self.contentBgView).mas_offset(-5);
        make.height.mas_equalTo(durationLabelHeight);
    }];
}

#pragma mark -- 刷新界面

- (void)refreshCell:(KKVideoInfo *)item{
    self.item = item ;
    self.durationLabel.text = item.formatDuration;
    CGSize size = [self.durationLabel.text sizeWithAttributes:@{NSFontAttributeName:self.durationLabel.font}];
    [self.durationLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width + 10);
    }];
}

#pragma mark -- @property getter

- (void)setCorverImage:(UIImage *)corverImage{
    self.imageView.image = corverImage;
}

#pragma mark -- @property getter

- (UIView *)contentBgView{
    if(!_contentBgView){
        _contentBgView = ({
            UIView *view = [UIView new];
            view ;
        });
    }
    return _contentBgView;
}

- (UIImageView *)imageView{
    if(!_imageView){
        _imageView = ({
            UIImageView *view = [UIImageView new];
            view.layer.masksToBounds = YES ;
            view.contentMode = UIViewContentModeScaleAspectFill;
            view ;
        });
    }
    return _imageView;
}

- (UILabel *)durationLabel{
    if(!_durationLabel){
        _durationLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentCenter;
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:10];
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
            view.layer.masksToBounds = YES ;
            view.layer.cornerRadius = durationLabelHeight / 2.0;
            view ;
        });
    }
    return _durationLabel;
}

@end
