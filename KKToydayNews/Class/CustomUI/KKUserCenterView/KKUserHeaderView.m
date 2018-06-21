//
//  KKUserHeaderView.m
//  KKToydayNews
//
//  Created by finger on 2017/12/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKUserHeaderView.h"
#import "KKUserHeadItemView.h"

static CGFloat headViewWH = 55 ;

@interface KKUserHeaderView()
@property(nonatomic)UIImageView *bgImageView;
@property(nonatomic)UIImageView *backView;
@property(nonatomic)UIImageView *headView;
@property(nonatomic)UILabel *nameLabel;
@property(nonatomic)KKUserHeadItemView *dtItemView;
@property(nonatomic)KKUserHeadItemView *concernItemView;
@property(nonatomic)KKUserHeadItemView *fansItemView;
@property(nonatomic)KKUserHeadItemView *favItemView;
@property(nonatomic)KKUserHeadItemView *historyItemView;
@property(nonatomic)KKUserHeadItemView *nightItemView;
@end

@implementation KKUserHeaderView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.bgImageView];
    [self addSubview:self.backView];
    [self addSubview:self.headView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.dtItemView];
    [self addSubview:self.concernItemView];
    [self addSubview:self.fansItemView];
    [self addSubview:self.favItemView];
    [self addSubview:self.historyItemView];
    [self addSubview:self.nightItemView];
    
    [self.bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self.favItemView.mas_top);
    }];
    
    [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.centerY.mas_equalTo(self.headView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.headView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.backView.mas_right).mas_offset(kkPaddingNormal);
        make.bottom.mas_equalTo(self.dtItemView.mas_top).mas_offset(-kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(headViewWH, headViewWH));
    }];
    
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headView.mas_right).mas_offset(kkPaddingNormal);
        make.centerY.mas_equalTo(self.headView);
    }];
    
    [self.dtItemView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.favItemView.mas_top);
        make.left.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth/3.0, 60));
    }];
    
    [self.concernItemView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.dtItemView);
        make.left.mas_equalTo(self.dtItemView.mas_right);
        make.size.mas_equalTo(self.dtItemView);
    }];
    
    [self.fansItemView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.dtItemView);
        make.left.mas_equalTo(self.concernItemView.mas_right);
        make.size.mas_equalTo(self.dtItemView);
    }];
    
    [self.favItemView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth/3.0, 60));
    }];
    
    [self.historyItemView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.favItemView);
        make.left.mas_equalTo(self.favItemView.mas_right);
        make.size.mas_equalTo(self.favItemView);
    }];
    
    [self.nightItemView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.favItemView);
        make.left.mas_equalTo(self.historyItemView.mas_right);
        make.size.mas_equalTo(self.favItemView);
    }];
}

#pragma mark -- 返回

- (void)backViewClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(backController)]){
        [self.delegate backController];
    }
}

#pragma mark -- @property getter

- (UIImageView *)bgImageView{
    if(!_bgImageView){
        _bgImageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.image = [UIImage imageNamed:@"wallpaper_profile_night"];
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _bgImageView;
}

- (UIImageView *)backView{
    if(!_backView){
        _backView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.image = [UIImage imageNamed:@"backItem"] ;
            view.userInteractionEnabled = YES ;
            
            __weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                __strongify(self);
                [self backViewClicked];
            }];
            
            view;
        });
    }
    return _backView;
}

- (UIImageView *)headView{
    if(!_headView){
        _headView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.layer.masksToBounds = YES ;
            view.layer.borderColor = [UIColor whiteColor].CGColor;
            view.layer.borderWidth = 0.5;
            view.layer.cornerRadius = headViewWH / 2.0;
            view.image = [UIImage imageNamed:@"userHead"];
            view ;
        });
    }
    return _headView;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor whiteColor];
            view.font = [UIFont systemFontOfSize:17];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.text = @"傲娇的隔壁老王";
            view ;
        });
    }
    return _nameLabel;
}

- (KKUserHeadItemView *)dtItemView{
    if(!_dtItemView){
        _dtItemView = ({
            KKUserHeadItemView *view = [[KKUserHeadItemView alloc]initWithShowImage:NO];
            view.titleLabel.text = @"0";
            view.detailLabel.text = @"动态";
            view;
        });
    }
    return _dtItemView;
}

- (KKUserHeadItemView *)concernItemView{
    if(!_concernItemView){
        _concernItemView = ({
            KKUserHeadItemView *view = [[KKUserHeadItemView alloc]initWithShowImage:NO];
            view.titleLabel.text = @"0";
            view.detailLabel.text = @"关注";
            view;
        });
    }
    return _concernItemView;
}

- (KKUserHeadItemView *)fansItemView{
    if(!_fansItemView){
        _fansItemView = ({
            KKUserHeadItemView *view = [[KKUserHeadItemView alloc]initWithShowImage:NO];
            view.titleLabel.text = @"0";
            view.detailLabel.text = @"粉丝";
            view;
        });
    }
    return _fansItemView;
}

- (KKUserHeadItemView *)favItemView{
    if(!_favItemView){
        _favItemView = ({
            KKUserHeadItemView *view = [[KKUserHeadItemView alloc]initWithShowImage:YES];
            view.imageView.image = [UIImage imageNamed:@"favoriteicon_profile_24x24_"];
            view.detailLabel.text = @"收藏";
            view;
        });
    }
    return _favItemView;
}

- (KKUserHeadItemView *)historyItemView{
    if(!_historyItemView){
        _historyItemView = ({
            KKUserHeadItemView *view = [[KKUserHeadItemView alloc]initWithShowImage:YES];
            view.imageView.image = [UIImage imageNamed:@"history_profile_24x24_"];
            view.detailLabel.text = @"历史";
            view;
        });
    }
    return _historyItemView;
}

- (KKUserHeadItemView *)nightItemView{
    if(!_nightItemView){
        _nightItemView = ({
            KKUserHeadItemView *view = [[KKUserHeadItemView alloc]initWithShowImage:YES];
            view.imageView.image = [UIImage imageNamed:@"nighticon_profile_24x24_"];
            view.detailLabel.text = @"夜间";
            view;
        });
    }
    return _nightItemView;
}

@end
