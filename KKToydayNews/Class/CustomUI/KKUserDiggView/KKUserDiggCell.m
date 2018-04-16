//
//  KKUserDiggCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKUserDiggCell.h"

#define ImageWH 35
#define LabelHeight 20
#define HorizSpace 8
#define VeritSpace 5

@interface KKUserDiggCell()
@property(nonatomic)UIView *bgView;
@property(nonatomic)UIImageView *headImageView;
@property(nonatomic)UILabel *nameLabel;
@property(nonatomic)UILabel *detailLabel;
@end

@implementation KKUserDiggCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.headImageView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(ImageWH, ImageWH)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.headImageView.bounds;
    maskLayer.path = path.CGPath;
    self.headImageView.layer.mask = maskLayer;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.headImageView];
    [self.bgView addSubview:self.detailLabel];
    [self.bgView addSubview:self.nameLabel];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.headImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.centerY.mas_equalTo(self.bgView);
        make.size.mas_equalTo(CGSizeMake(ImageWH, ImageWH));
    }];
    
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headImageView.mas_centerY).mas_offset(-LabelHeight/2.0);
        make.left.mas_equalTo(self.headImageView.mas_right).mas_offset(HorizSpace);
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.nameLabel);
        make.centerY.mas_equalTo(self.headImageView.mas_centerY).mas_offset(LabelHeight/2.0);
        make.left.mas_equalTo(self.nameLabel);
        make.height.mas_equalTo(LabelHeight);
    }];
}

#pragma mark -- 界面刷新

- (void)refreshWithUserInfo:(KKUserInfoNew *)info{
    NSString *headUrl = info.avatar_url;
    if(!headUrl){
        headUrl = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryCacheOperationForKey:headUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            self.headImageView.image = image;
        }else{
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"head_default"]];
        }
    }];
    
    self.nameLabel.text = info.screen_name;
    
    NSString *desc = info.description_;
    self.detailLabel.text = desc ;
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headImageView.mas_centerY).mas_offset(desc.length ? LabelHeight/2.0 : 0);
        make.height.mas_equalTo(desc.length ? LabelHeight : 0);
    }];
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headImageView.mas_centerY).mas_offset(desc.length ? -LabelHeight/2.0 : 0);
    }];
}

#pragma mark -- @property getter

- (UIView *)bgView{
    if(!_bgView){
        _bgView = ({
            UIView *view = [UIView new];
            view ;
        });
    }
    return _bgView;
}

- (UIImageView *)headImageView{
    if(!_headImageView){
        _headImageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view ;
        });
    }
    return _headImageView;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.font = [UIFont systemFontOfSize:14];
            view;
        });
    }
    return _nameLabel;
}

- (UILabel *)detailLabel{
    if(!_detailLabel){
        _detailLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.font = [UIFont systemFontOfSize:12];
            view;
        });
    }
    return _detailLabel;
}

@end
