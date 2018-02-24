//
//  KKSectionItemView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKSectionItemView.h"

@interface KKSectionItemView ()
@property(nonatomic,strong)UIButton *itemBtn;
@property(nonatomic,strong)UIButton *closeBtn;
@end

@implementation KKSectionItemView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
//    self.layer.shadowOpacity = 0.5;// 阴影透明度
//    self.layer.shadowColor = [UIColor grayColor].CGColor;// 阴影的颜色
//    self.layer.shadowRadius = 3;// 阴影扩散的范围控制
//    self.layer.shadowOffset = CGSizeMake(1, 1);// 阴影的范围
    [self setBackgroundColor:[[UIColor grayColor]colorWithAlphaComponent:0.1]];
    [self addSubview:self.itemBtn];
    [self addSubview:self.closeBtn];
    [self.itemBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(-8);
        make.right.mas_equalTo(self).mas_offset(8);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
}

#pragma mark -- 使超出视图范围的关闭按钮也能响应

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subView in self.subviews) {
            CGPoint tp = [subView convertPoint:point fromView:self];
            if (CGRectContainsPoint(subView.bounds, tp)) {
                view = subView;
            }
        }
    }
    return view;
}

#pragma mark --

- (void)setFavorite:(BOOL)favorite{
    _favorite = favorite ;
    if(!_favorite){
        [self.itemBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
//        [self.layer setShadowOpacity:0.5];// 阴影透明度
    }else{
        [self.itemBtn setImage:nil forState:UIControlStateNormal];
//        [self.layer setShadowOpacity:0.0];// 阴影透明度
    }
}

- (void)setHideCloseButton:(BOOL)hideCloseButton{
    _hideCloseButton = hideCloseButton ;
    self.closeBtn.hidden = _hideCloseButton ;
}

- (void)setSelected:(BOOL)selected{
    _selected = selected ;
    self.itemBtn.selected = selected ;
}

- (void)setSectionItem:(KKSectionItem *)sectionItem{
    _sectionItem = sectionItem ;
    [self.itemBtn setTitle:self.sectionItem.name forState:UIControlStateNormal];
}

#pragma mark -- 按钮响应

- (void)sectionBtnClicked:(id)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickSectionItemView:)]){
        [self.delegate clickSectionItemView:self];
    }
}

- (void)closeBtnClicked:(id)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeBtnClicked:)]){
        [self.delegate closeBtnClicked:self];
    }
}

#pragma mark -- UI

- (UIButton *)itemBtn{
    if(!_itemBtn){
        _itemBtn = ({
            UIButton *btn = [[UIButton alloc]init];
            [btn setTitle:self.sectionItem.name forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [btn.titleLabel sizeToFit];
            [btn.titleLabel setAdjustsFontSizeToFitWidth:YES];
            [btn addTarget:self action:@selector(sectionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            btn ;
        });
    }
    return _itemBtn ;
}

- (UIButton *)closeBtn{
    if(!_closeBtn){
        _closeBtn = ({
            UIButton *closeBtn = [[UIButton alloc]init];
            [closeBtn setImage:[UIImage imageNamed:@"recommend_cancel"] forState:UIControlStateNormal];
            [closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [closeBtn setHidden:YES];
            [closeBtn setBackgroundColor:[UIColor clearColor]];
            closeBtn ;
        });
    }
    return _closeBtn ;
}

@end
