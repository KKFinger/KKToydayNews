//
//  KKXiaoShiPingCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKXiaoShiPingCell.h"
#import "TYAttributedLabel.h"

@interface KKXiaoShiPingCell ()
@property(nonatomic,readwrite)UIView *contentBgView;
@property(nonatomic,readwrite)UIImageView *corverView;
@property(nonatomic)TYAttributedLabel *titleLabel;
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

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
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
    
    if(!item.smallVideo.textContainer){
        item.smallVideo.textContainer = [self createAttriDataWithText:item.smallVideo.title];
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
    [self.corverView setImageWithUrl:url placeholder:[UIImage imageWithColor:[UIColor grayColor]] circleImage:NO completed:nil];

    self.titleLabel.textContainer = item.smallVideo.textContainer;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(item.smallVideo.textContainer.attriTextHeight);
    }];
    
    NSString *playCount = [NSString stringWithFormat:@"%@次播放",[[NSNumber numberWithInteger:[item.smallVideo.action.play_count integerValue]]convert]];
    self.playCountLabel.text = playCount;
    
    NSString *diggCount = [NSString stringWithFormat:@"%@赞",[[NSNumber numberWithInteger:[item.smallVideo.action.digg_count integerValue]]convert]];
    self.diggLabel.text = diggCount;
}

#pragma mark -- 创建文本数据

- (TYTextContainer *)createAttriDataWithText:(NSString *)text{
    TYTextContainer *data = [TYTextContainer new];
    data.font = [UIFont systemFontOfSize:17];
    data.linesSpacing = 2 ;
    data.textColor = [UIColor whiteColor];
    data.text = text;
    data.textAlignment = NSTextAlignmentLeft;
    data.lineBreakMode = NSLineBreakByTruncatingTail;
    data.numberOfLines = 2 ;
    return [data createTextContainerWithTextWidth:UIDeviceScreenWidth/2.0 - 2 * kkPaddingNormal];
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
            view.layer.borderWidth = 0.5;
            view.layer.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.1].CGColor;
            view ;
        });
    }
    return _corverView;
}

- (TYAttributedLabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
            view.numberOfLines = 0 ;
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:17];
            view.backgroundColor = [UIColor clearColor];
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
