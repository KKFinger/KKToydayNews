//
//  KKDetialHeadView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/23.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDetialHeadView.h"

@interface KKDetialHeadView()
@property(nonatomic)UILabel *titleLabel;
@end

@implementation KKDetialHeadView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self ;
}

#pragma mark -- 初始化UI

- (void)setupUI{
    [self addSubview:self.authorView];
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(UIDeviceScreenWidth - 2 * kkPaddingNormal);
        make.height.mas_equalTo(1);
    }];
    
    [self.authorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(15);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(self).priority(998);
        make.height.mas_equalTo(60);
    }];
}
#pragma mark -- @property setter

- (void)setTitle:(NSString *)title{
    self.titleLabel.text = title;
    NSDictionary *dic = @{NSFontAttributeName:self.titleLabel.font};
    CGSize size = [title boundingRectWithSize:CGSizeMake(UIDeviceScreenWidth - 2 * kkPaddingNormal, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    if(size.height > 100){
        size.height = 100 ;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }else{
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(size.height);
    }];
    
    [self layoutIfNeeded];
    
    if(self.shouldAdjustHeight){
        self.shouldAdjustHeight(self.authorView.bottom + kkPaddingNormal);
    }
}

#pragma mark -- @property getter

- (KKAuthorInfoView *)authorView{
    if(!_authorView){
        _authorView = ({
            KKAuthorInfoView *view = [KKAuthorInfoView new];
            view ;
        });
    }
    return _authorView;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.numberOfLines = 0 ;
            view.font = [UIFont systemFontOfSize:18 weight:0.3];
            view ;
        });
    }
    return _titleLabel;
}

@end
