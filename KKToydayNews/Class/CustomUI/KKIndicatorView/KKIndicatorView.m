//
//  KKIndicatorView.m
//  KKToydayNews
//
//  Created by finger on 2017/8/17.
//  Copyright © 2017年 finger All rights reserved.
//

#import "KKIndicatorView.h"

@interface KKIndicatorView ()
@property(nonatomic)UILabel *bottomLine;
@property(nonatomic,copy)NSMutableArray *btnArray;
@end

@implementation KKIndicatorView

- (instancetype)initWithTitleArray:(NSArray *)titleArray{
    self = [super init];
    if(self){
        self.backgroundColor = [UIColor whiteColor];
        self.normalColor = [UIColor blackColor];
        self.selectedColor = [UIColor redColor];
        self.bottomLineColor = self.selectedColor;
        self.selectedIndex = 0 ;
        self.bottomLinePadding = 3;
        self.titleFont = [UIFont systemFontOfSize:15];
        [self layoutUIWithTitleArray:titleArray];
    }
    return self;
}

- (void)layoutUIWithTitleArray:(NSArray *)array{
    if(!array.count){
        return ;
    }
    
    NSInteger btnW = UIDeviceScreenWidth / array.count ;
    if(self.btnWith <= 0){
        self.btnWith = btnW ;
    }
    
    for(NSInteger i = 0 ; i < array.count ; i++){
        NSString *title = [array objectAtIndex:i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:self.normalColor forState:UIControlStateNormal];
        [btn setTitleColor:self.selectedColor forState:UIControlStateSelected];
        [btn.titleLabel setFont:self.titleFont];
        [btn setTag:i];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [btn setSelected:i == self.selectedIndex];
        [self addSubview:btn];
        [self.btnArray addObject:btn];
        [btn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).mas_offset(i * self.btnWith);
            make.top.mas_equalTo(self);
            make.width.mas_equalTo(self.btnWith);
            make.height.mas_equalTo(self);
        }];
    }
    
    CGFloat maxTitleWidth = 0 ;
    for(UIButton *btn in self.btnArray){
        NSDictionary *dic = @{NSFontAttributeName:btn.titleLabel.font};
        CGFloat w = [btn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:dic
                                                      context:nil].size.width;
        if(w > maxTitleWidth){
            maxTitleWidth = w;
        }
    }
    
    [self layoutIfNeeded];
    
    if(self.bottomLineWidth <= 0){
        _bottomLineWidth = MIN(self.btnWith,maxTitleWidth) ;
    }
    [self addSubview:self.bottomLine];
    [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectedIndex * self.btnWith + (self.btnWith - _bottomLineWidth) / 2.0);
        make.bottom.mas_equalTo(self).mas_offset(-self.bottomLinePadding);
        make.height.mas_equalTo(self.bottomLineHeight);
        make.width.mas_equalTo(self.bottomLineWidth);
    }];
}

#pragma mark -- 按钮点击

- (void)btnClicked:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger index = btn.tag;
    NSString *title = btn.titleLabel.text;
    self.selectedIndex = index ;
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectIndex:title:)]){
        [self.delegate selectIndex:index title:title];
    }
}

#pragma mark -- 获取全部的title数量

- (NSInteger)fetchTitleCount{
    return self.btnArray.count;
}

#pragma mark -- @property getter

- (NSMutableArray *)btnArray{
    if(!_btnArray){
        _btnArray = ({
            NSMutableArray *array = [NSMutableArray new];
            array;
        });
    }
    return _btnArray;
}

- (UILabel *)bottomLine{
    if(!_bottomLine){
        _bottomLine = ({
            UILabel *view = [UILabel new];
            view.backgroundColor = self.selectedColor;
            view ;
        });
    }
    return _bottomLine;
}

#pragma mark -- @property setter

- (void)setNormalColor:(UIColor *)normalColor{
    _normalColor = normalColor;
    for(UIButton *btn in self.btnArray){
        [btn setTitleColor:_normalColor forState:UIControlStateNormal];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor = selectedColor;
    for(UIButton *btn in self.btnArray){
        [btn setTitleColor:_selectedColor forState:UIControlStateSelected];
    }
}

- (void)setBottomLineColor:(UIColor *)bottomLineColor{
    _bottomLineColor = bottomLineColor;
    self.bottomLine.backgroundColor = bottomLineColor;
}

- (void)setBottomLineWidth:(CGFloat)bottomLineWidth{
    _bottomLineWidth = bottomLineWidth ;
    if(!self.btnArray.count){
        return ;
    }
    NSInteger btnW = UIDeviceScreenWidth / self.btnArray.count ;
    if(self.btnWith <= 0){
        self.btnWith = btnW ;
    }
    if(_bottomLineWidth > self.btnWith){
        _bottomLineWidth = self.btnWith ;
    }
    [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(bottomLineWidth);
        make.left.mas_equalTo(self.selectedIndex * self.btnWith + (self.btnWith - _bottomLineWidth) / 2.0);
    }];
}

- (void)setBottomLineHeight:(CGFloat)bottomLineHeight{
    _bottomLineHeight = bottomLineHeight ;
    if(_bottomLineHeight > 3){
        _bottomLineHeight = 3 ;
    }
    if(!self.btnArray.count){
        return ;
    }
    [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_bottomLineHeight);
        make.bottom.mas_equalTo(self).mas_offset(-5);
    }];
}

- (void)setBottomLinePadding:(CGFloat)bottomLinePadding{
    _bottomLinePadding = bottomLinePadding;
    if(!self.btnArray.count){
        return ;
    }
    [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).mas_offset(-_bottomLinePadding);
    }];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    if(!self.btnArray.count){
        return ;
    }
    UIButton *lastSelBtn = [self.btnArray objectAtIndex:_selectedIndex];
    [lastSelBtn setSelected:NO];
    _selectedIndex = selectedIndex;
    lastSelBtn = [self.btnArray objectAtIndex:_selectedIndex];
    [lastSelBtn setSelected:YES];
    
    NSInteger btnW = UIDeviceScreenWidth / self.btnArray.count ;
    if(self.btnWith <= 0){
        self.btnWith = btnW ;
    }
    [self.bottomLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_selectedIndex * self.btnWith + (self.btnWith - self.bottomLineWidth) / 2.0);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)setTitleFont:(UIFont *)titleFont{
    _titleFont = titleFont;
    for(UIButton *btn in self.btnArray){
        btn.titleLabel.font = titleFont;
    }
}

- (void)setBtnWith:(CGFloat)btnWith{
    _btnWith = btnWith ;
    if(self.bottomLineWidth > btnWith){
        self.bottomLineWidth = btnWith ;
    }
    for(NSInteger i = 0 ; i < self.btnArray.count ; i++){
        UIButton *btn = [self.btnArray safeObjectAtIndex:i];
        [btn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).mas_offset(i * _btnWith);
            make.width.mas_equalTo(_btnWith);
        }];
    }
}

- (void)setTitleArray:(NSArray *)titleArray{
    [self layoutUIWithTitleArray:titleArray];
}

@end
