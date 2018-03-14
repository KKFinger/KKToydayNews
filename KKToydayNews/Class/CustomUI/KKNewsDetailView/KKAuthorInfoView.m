//
//  KKAuthorInfoView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/23.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKAuthorInfoView.h"

#define ConcernWdith 50
#define LabelHeight 20

@interface KKAuthorInfoView()
@property(nonatomic)UIImageView *header;
@property(nonatomic,readwrite)UILabel *nameLabel;
@property(nonatomic,readwrite)UILabel *detailLabel;
@property(nonatomic)UIButton *concernBtn;
@property(nonatomic)UIView *splitViewBottom;
@end

@implementation KKAuthorInfoView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self ;
}

#pragma mark -- 初始化UI

- (void)setupUI{
    [self addSubview:self.header];
    [self addSubview:self.nameLabel];
    [self addSubview:self.detailLabel];
    [self addSubview:self.concernBtn];
    [self addSubview:self.splitViewBottom];
    
    _headerSize = CGSizeMake(44, 44);
    
    self.header.layer.cornerRadius = _headerSize.height / 2.0 ;
    [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(kkPaddingNormal).priority(998);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(_headerSize);
    }];
    
    [self.concernBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal).priority(998);
        make.centerY.mas_equalTo(self.header);
        make.size.mas_equalTo(CGSizeMake(ConcernWdith, 25));
    }];
    
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.header.mas_right).mas_offset(5).priority(998);
        make.right.mas_equalTo(self.concernBtn.mas_left).mas_offset(-5).priority(998);
        make.bottom.mas_equalTo(self.header.mas_centerY).mas_offset(-2);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.header.mas_centerY).mas_offset(2);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.splitViewBottom mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
}

#pragma mark -- 关注按钮点击

- (void)concernBtnClick{
    BOOL isConcern = !self.concernBtn.selected ;
    if(self.delegate && [self.delegate respondsToSelector:@selector(setConcern:callback:)]){
        [self.delegate setConcern:isConcern callback:^(BOOL isSuc) {
            if(isSuc){
                self.isConcern = isConcern;
            }
        }];
    }
}

#pragma mark -- @property setter

- (void)setShowDetailLabel:(BOOL)showDetailLabel{
    _showDetailLabel = showDetailLabel;
    self.detailLabel.hidden = !showDetailLabel;
    if(_showDetailLabel){
        [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(LabelHeight);
        }];
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.header.mas_centerY).mas_offset(-2);
        }];
    }else{
        [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.header.mas_centerY).mas_offset(LabelHeight/2.0);
        }];
    }
}

- (void)setHeaderSize:(CGSize)headerSize{
    _headerSize = headerSize;
    self.header.layer.cornerRadius = _headerSize.height / 2.0 ;
    [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(_headerSize);
    }];
}

- (void)setName:(NSString *)name{
    self.nameLabel.text = name;
}

- (void)setHeadUrl:(NSString *)headUrl{
    if(!headUrl.length){
        headUrl = @"";
    }
    [self.header setCornerImageWithURL:[NSURL URLWithString:headUrl] placeholder:[UIImage imageNamed:@"head_default"]];
}

- (void)setDetail:(NSString *)detail{
    self.detailLabel.text = detail;
}

- (void)setIsConcern:(BOOL)isConcern{
    self.concernBtn.selected = isConcern ;
    if(isConcern){
        self.concernBtn.layer.borderColor = [UIColor grayColor].CGColor;
    }else{
        self.concernBtn.layer.borderColor = [UIColor redColor].CGColor;
    }
}

- (void)setShowBottomSplit:(BOOL)showBottomSplit{
    self.splitViewBottom.hidden = !showBottomSplit;
}

#pragma mark -- @property getter

- (UIImageView *)header{
    if(!_header){
        _header = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill ;
            view.layer.masksToBounds = YES ;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(clickedUserHeadWithUserId:)]){
                    [self.delegate clickedUserHeadWithUserId:self.userId];
                }
            }];
            
            view ;
        });
    }
    return _header;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentLeft;
            view.textColor = [UIColor blackColor];
            view.font = [UIFont systemFontOfSize:(iPhone5)?14:15];
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view ;
        });
    }
    return _nameLabel;
}

- (UILabel *)detailLabel{
    if(!_detailLabel){
        _detailLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentLeft;
            view.textColor = [UIColor grayColor];
            view.font = [UIFont systemFontOfSize:13];
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view ;
        });
    }
    return _detailLabel;
}

- (UIButton *)concernBtn{
    if(!_concernBtn){
        _concernBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setTitle:@"关注" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [view setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
            [view setTitle:@"已关注" forState:UIControlStateSelected];
            [view setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
            [view setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [view.layer setBorderWidth:0.7];
            [view.layer setBorderColor:[UIColor redColor].CGColor];
            [view addTarget:self action:@selector(concernBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [view setSelected:NO];
            [view.layer setCornerRadius:3];
            [view.layer setMasksToBounds:YES];
            view ;
        });
    }
    return _concernBtn;
}

- (UIView *)splitViewBottom{
    if(!_splitViewBottom){
        _splitViewBottom = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1.0);
            view.hidden = YES ;
            view ;
        });
    }
    return _splitViewBottom;
}

@end
