//
//  KKNavTitleView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/30.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKNavTitleView.h"

@interface KKNavTitleView ()
@property(nonatomic,readwrite) UILabel *titleLabel;
@property(nonatomic,readwrite)UIView *splitView;
@end

@implementation KKNavTitleView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                     leftBtns:(NSArray *)leftBtns
                    rightBtns:(NSArray *)rightBtns{
    self = [super init];
    if(self){
        _title = title;
        _leftBtns = leftBtns;
        _rightBtns = rightBtns;
        _contentOffsetY = KKStatusBarHeight / 2.0 ;
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.layer setMasksToBounds:YES];
    [self addSubview:self.titleLabel];
    [self addSubview:self.splitView];
    
    UIButton *lastBtn = nil ;
    for(UIButton *btn in self.leftBtns){
        [self addSubview:btn];
        [btn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(btn.size); make.centerY.mas_equalTo(self).mas_offset(self.contentOffsetY);
            if(lastBtn == nil){
                make.left.mas_equalTo(self).mas_offset(kkPaddingNormal);
            }else{
                make.left.mas_equalTo(lastBtn.mas_right).mas_offset(5);
            }
        }];
        lastBtn = btn ;
    }
    
    self.titleLabel.text = self.title;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(2 * kkPaddingNormal);
        make.centerY.mas_equalTo(self).mas_offset(self.contentOffsetY);
        make.width.mas_equalTo(self).mas_offset(-4 * kkPaddingNormal).priority(998);
        make.height.mas_equalTo(20);
    }];
    
    lastBtn = nil ;
    for(NSInteger i = self.rightBtns.count - 1 ; i >=0 ; i--){
        UIButton *btn = [self.rightBtns safeObjectAtIndex:i];
        [self addSubview:btn];
        [btn mas_updateConstraints:^(MASConstraintMaker *make) {
           make.size.mas_equalTo(btn.size); make.centerY.mas_equalTo(self).mas_offset(self.contentOffsetY);
            if(lastBtn == nil){
                make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
            }else{
                make.right.mas_equalTo(lastBtn.mas_left).mas_offset(-5);
            }
        }];
        lastBtn = btn ;
    }
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_bottom).mas_offset(-1);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
}

#pragma mark -- @property setter

- (void)setLeftBtns:(NSArray *)leftBtns{
    _leftBtns = leftBtns;
    
    UIButton *lastBtn = nil ;
    for(UIButton *btn in _leftBtns){
        [self addSubview:btn];
        [btn mas_updateConstraints:^(MASConstraintMaker *make) {
           make.size.mas_equalTo(btn.size); make.centerY.mas_equalTo(self).mas_offset(self.contentOffsetY);
            if(lastBtn == nil){
                make.left.mas_equalTo(self).mas_offset(kkPaddingNormal);
            }else{
                make.left.mas_equalTo(lastBtn.mas_right).mas_offset(5);
            }
        }];
        lastBtn = btn ;
    }
}

- (void)setRightBtns:(NSArray *)rightBtns{
    _rightBtns = rightBtns;
    
    UIButton *lastBtn = nil ;
    for(NSInteger i = _rightBtns.count - 1 ; i >=0 ; i--){
        UIButton *btn = [_rightBtns safeObjectAtIndex:i];
        [self addSubview:btn];
        [btn mas_updateConstraints:^(MASConstraintMaker *make) {
           make.size.mas_equalTo(btn.size); make.centerY.mas_equalTo(self).mas_offset(self.contentOffsetY);
            if(lastBtn == nil){
                make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
            }else{
                make.right.mas_equalTo(lastBtn.mas_left).mas_offset(-5);
            }
        }];
        lastBtn = btn ;
    }
}

- (void)setTitleView:(UIView *)titleView{
    _titleView = titleView ;
    
    if(!titleView){
        return ;
    }
    
    self.titleLabel.hidden = YES ;
    
    [self addSubview:titleView];
    [_titleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(titleView.size); make.centerY.mas_equalTo(self).mas_offset(self.contentOffsetY);
        make.left.mas_equalTo(self).mas_offset(titleView.left);
    }];
}

- (void)setTitle:(NSString *)title{
    _title = title ;
    self.titleLabel.text = title;
}

- (void)setContentOffsetY:(CGFloat)contentOffsetY{
    _contentOffsetY = contentOffsetY;
    
    for(UIButton *btn in _leftBtns){
        [btn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self).mas_offset(self.contentOffsetY);
        }];
    }
    for(NSInteger i = _rightBtns.count - 1 ; i >=0 ; i--){
        UIButton *btn = [_rightBtns safeObjectAtIndex:i];
        [btn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self).mas_offset(self.contentOffsetY);
        }];
    }
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self).mas_offset(self.contentOffsetY);
    }];
}

#pragma mark -- @property getter

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.backgroundColor = [UIColor clearColor];
            view.textAlignment = NSTextAlignmentCenter;
            view.font = [UIFont systemFontOfSize:16];
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view ;
        });
    }
    return _titleLabel;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1.0);;
            view ;
        });
    }
    return _splitView;
}

@end
