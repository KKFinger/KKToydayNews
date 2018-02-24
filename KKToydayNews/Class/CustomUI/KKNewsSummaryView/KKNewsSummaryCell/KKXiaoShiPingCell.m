//
//  KKXiaoShiPingCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKXiaoShiPingCell.h"

@interface KKXiaoShiPingCell ()
@property(nonatomic,readwrite)UIView *contentBgView;
@property(nonatomic,readwrite)UIImageView *corverView;
@property(nonatomic)UILabel *titleLabel;
@property(nonatomic)UILabel *playIcon;
@property(nonatomic)UILabel *playCountLabel;
@property(nonatomic)UILabel *diggLabel;
@property(nonatomic,strong)CAGradientLayer *corverGradient;
@property(nonatomic,weak)KKSummaryContent *item;
@end

@implementation KKXiaoShiPingCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.corverGradient.frame = CGRectMake(0, self.contentBgView.height - 150, self.contentBgView.width, 150);
    [CATransaction commit];
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.contentView addSubview:self.contentBgView];
    [self.contentBgView addSubview:self.corverView];
    [self.contentBgView addSubview:self.titleLabel];
    [self.contentBgView addSubview:self.playIcon];
    [self.contentBgView addSubview:self.playCountLabel];
    [self.contentBgView addSubview:self.diggLabel];
    [self.contentBgView.layer insertSublayer:self.corverGradient above:self.corverView.layer];
    
    [self.contentBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.corverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentBgView);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.playIcon.mas_top).mas_offset(-5);
        make.left.mas_equalTo(self.contentBgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(self.contentBgView).mas_offset(-2*kkPaddingNormal);
        make.height.mas_equalTo(0);
    }];
    
    [self.playIcon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentBgView).mas_offset(-10);
        make.left.mas_equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    [self.playCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.playIcon.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(self.playIcon);
    }];
    
    [self.diggLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.titleLabel);
        make.centerY.mas_equalTo(self.playIcon);
    }];
}

#pragma mark -- 界面刷新

- (void)refreshWith:(KKSummaryContent *)item{
    
    self.item = item ;
    
    self.contentBgView.alpha = 1.0 ;
    
    if(!item.smallVideo.attriTextData){
        item.smallVideo.attriTextData = [self createAttriDataWithText:item.smallVideo.title];
    }
    
    NSString *url = item.smallVideo.first_frame_image_list.firstObject.url ;
    if(!url.length){
        url = item.smallVideo.large_image_list.firstObject.url;
        if(!url.length){
            url = item.smallVideo.thumb_image_list.firstObject.url;
        }
        if(!url.length){
            url = @"";
        }
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    @weakify(imageCache);
    [imageCache diskImageExistsWithKey:url completion:^(BOOL isInCache) {
        @strongify(imageCache);
        if(isInCache){
            [self.corverView setImage:[imageCache imageFromCacheForKey:url]];
        }else{
            [self.corverView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]]];
        }
    }];

    self.titleLabel.attributedText = item.smallVideo.attriTextData.attriText;
    self.titleLabel.lineBreakMode = item.smallVideo.attriTextData.lineBreak;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(item.smallVideo.attriTextData.attriTextHeight);
    }];
    
    NSString *playCount = [NSString stringWithFormat:@"%@次播放",[[NSNumber numberWithInteger:[item.smallVideo.action.play_count integerValue]]convert]];
    self.playCountLabel.text = playCount;
    
    NSString *diggCount = [NSString stringWithFormat:@"%@赞",[[NSNumber numberWithInteger:[item.smallVideo.action.digg_count integerValue]]convert]];
    self.diggLabel.text = diggCount;
}

#pragma mark -- 创建文本数据

- (KKAttriTextData *)createAttriDataWithText:(NSString *)text{
    KKAttriTextData *data = [KKAttriTextData new];
    data.maxAttriTextWidth = self.titleLabel.width;
    data.textFont = self.titleLabel.font;
    data.lineSpace = 3 ;
    data.textColor = self.titleLabel.textColor;
    data.originalText = text;
    data.alignment = self.titleLabel.textAlignment;
    data.lineBreak = self.titleLabel.lineBreakMode;
    if(data.attriTextHeight > 2 * self.titleLabel.font.lineHeight + 3 * data.lineSpace){
        data.attriTextHeight = 2 * self.titleLabel.font.lineHeight + 3 * data.lineSpace;
    }
    return data;
}

#pragma mark -- @property

- (UIView *)contentBgView{
    if(!_contentBgView){
        _contentBgView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _contentBgView;
}

- (UIImageView *)corverView{
    if(!_corverView){
        _corverView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _corverView;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.numberOfLines = 0 ;
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:17];
            view ;
        });
    }
    return _titleLabel;
}

- (UILabel *)playIcon{
    if(!_playIcon){
        _playIcon = ({
            UILabel *view = [UILabel new];
            view.text = @"▶";
            view.font = [UIFont systemFontOfSize:17];
            view.textAlignment = NSTextAlignmentLeft;
            view.textColor = [UIColor whiteColor];
            view ;
        });
    }
    return _playIcon;
}

- (UILabel *)playCountLabel{
    if(!_playCountLabel){
        _playCountLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:12];
            view ;
        });
    }
    return _playCountLabel;
}

- (UILabel *)diggLabel{
    if(!_diggLabel){
        _diggLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentRight;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:12];
            view ;
        });
    }
    return _diggLabel;
}

- (CAGradientLayer *)corverGradient{
    if(!_corverGradient){
        _corverGradient = [CAGradientLayer layer];
        _corverGradient.colors = @[(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.5].CGColor, (__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.3].CGColor,(__bridge id)[UIColor clearColor].CGColor];
        _corverGradient.startPoint = CGPointMake(0, 1.0);
        _corverGradient.endPoint = CGPointMake(0.0, 0.0);
    }
    return _corverGradient;
}

@end
