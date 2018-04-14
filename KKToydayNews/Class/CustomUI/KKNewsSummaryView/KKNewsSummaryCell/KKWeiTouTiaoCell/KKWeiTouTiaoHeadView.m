//
//  KKWeiTouTiaoHeadView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKWeiTouTiaoHeadView.h"

#define horizSpace 5
#define headViewWH 35

@interface KKWeiTouTiaoHeadView ()
@property(nonatomic)UIImageView *headView ;
@property(nonatomic)UIImageView *vipView;
@property(nonatomic)UILabel *nameLabel;
@property(nonatomic)UILabel *descLabel;
@property(nonatomic)UIButton *followBtn;
@property(nonatomic)UIButton *shieldBtn;
@end

@implementation KKWeiTouTiaoHeadView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.headView];
    [self addSubview:self.vipView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.descLabel];
    [self addSubview:self.followBtn];
    [self addSubview:self.shieldBtn];
    
    [self.headView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(headViewWH, headViewWH));
    }];
    
    [self.vipView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.headView);
        make.bottom.mas_equalTo(self.headView);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headView.mas_right).mas_offset(8);
        make.bottom.mas_equalTo(self.headView.mas_centerY);
        make.right.mas_lessThanOrEqualTo(self.followBtn.mas_left).mas_offset(-8);
        make.height.mas_equalTo(20);
    }];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.headView.mas_centerY).mas_offset(2);
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.height.mas_equalTo(self.nameLabel);
    }];
    
    [self.shieldBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.centerY.mas_equalTo(self.nameLabel);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
    }];
    
    [self.followBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.shieldBtn.mas_left).mas_offset(-horizSpace);
        make.centerY.mas_equalTo(self.nameLabel);
        make.size.mas_equalTo(CGSizeMake(50, 20));
    }];
}

#pragma mark -- 按钮事件

- (void)followBtnClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(followBtnClicked)]){
        [self.delegate followBtnClicked];
    }
}

- (void)shieldBtnClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(shieldBtnClicked)]){
        [self.delegate shieldBtnClicked];
    }
}

#pragma mark -- @@property setter

- (void)setHeadUrl:(NSString *)headUrl{
    _headUrl = headUrl ;
    if(!_headUrl.length){
        _headUrl = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryCacheOperationForKey:_headUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            self.headView.image = image ;
        }else{
            [self.headView setCornerImageWithURL:[NSURL URLWithString:_headUrl] placeholder:[UIImage imageWithColor:[UIColor grayColor]]];
        }
    }];
}

- (void)setName:(NSString *)name{
    _name = name ;
    self.nameLabel.text = name ;
}

- (void)setDesc:(NSString *)desc{
    _desc = desc;
    self.descLabel.text = desc ;
}

- (void)setIsFollow:(BOOL)isFollow{
    _isFollow = isFollow ;
    self.followBtn.selected = isFollow ;
}

#pragma mark -- @property getter

- (UIImageView *)headView{
    if(!_headView){
        _headView = ({
            UIImageView *view = [UIImageView new];
            view.layer.masksToBounds = YES ;
            view.layer.cornerRadius = headViewWH/2.0 ;
            view.layer.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.3].CGColor;
            view.layer.borderWidth = 0.5 ;
            view.contentMode = UIViewContentModeScaleAspectFill ;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(userHeadClicked)]){
                    [self.delegate userHeadClicked];
                }
            }];
            
            view ;
        });
    }
    return _headView ;
}

- (UIImageView *)vipView{
    if(!_vipView){
        _vipView = ({
            UIImageView *view = [UIImageView new];
            view.layer.masksToBounds = YES ;
            view.contentMode = UIViewContentModeScaleAspectFill ;
            view.image = [UIImage imageNamed:@"all_v_avatar_18x18_"];
            view ;
        });
    }
    return _vipView ;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentLeft;
            view.font = [UIFont systemFontOfSize:(iPhone5)?15:16];
            view.textColor = [UIColor blackColor];
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view ;
        });
    }
    return _nameLabel;
}

- (UILabel *)descLabel{
    if(!_descLabel){
        _descLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentLeft;
            view.font = [UIFont systemFontOfSize:13];
            view.textColor = [UIColor grayColor];
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view ;
        });
    }
    return _descLabel;
}

- (UIButton *)followBtn{
    if(!_followBtn){
        _followBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"关注" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [view setTitle:@"已关注" forState:UIControlStateSelected];
            [view setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
            [view addTarget:self action:@selector(followBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            view ;
        });
    }
    return _followBtn;
}

- (UIButton *)shieldBtn{
    if(!_shieldBtn){
        _shieldBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"shield"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(shieldBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _shieldBtn;
}

@end
