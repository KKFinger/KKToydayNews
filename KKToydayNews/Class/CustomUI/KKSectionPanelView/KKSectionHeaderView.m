//
//  KKSectionHeaderView.m
//  KKToydayNews
//
//  Created by finger on 2017/8/8.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKSectionHeaderView.h"

@interface KKSectionHeaderView()
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *detailLabel;
@property(nonatomic,strong)UIButton *editBtn ;
@end

@implementation KKSectionHeaderView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
        [self bandingEvent];
    }
    return self ;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.titleLabel];
    [self addSubview:self.detailLabel];
    [self addSubview:self.editBtn];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(13);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(80);
    }];
    
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).mas_offset(5);
        make.bottom.mas_equalTo(self.titleLabel);
        make.width.mas_equalTo(100);
    }];
    
    [self.editBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self).mas_offset(-13);
        make.size.mas_equalTo(CGSizeMake(50, 25));
    }];
}

#pragma mark -- 绑定事件

- (void)bandingEvent{
    [self.editBtn addTarget:self action:@selector(editBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)editBtnClick{
    self.isEdit = !self.isEdit ;
    if(self.isEdit){
        [self.editBtn setTitle:@"完成" forState:UIControlStateNormal];
    }else{
        [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    }
    if(self.enditBtnClickHandler){
        self.enditBtnClickHandler(self.isEdit);
    }
}

#pragma mark -- @property getter && setter

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [[UILabel alloc]init];
            view.textAlignment = NSTextAlignmentLeft;
            view.textColor = [UIColor blackColor];
            view.font = [UIFont systemFontOfSize:18];
            view ;
        });
    }
    return _titleLabel ;
}

- (UILabel *)detailLabel{
    if(!_detailLabel){
        _detailLabel = ({
            UILabel *view = [[UILabel alloc]init];
            view.textAlignment = NSTextAlignmentLeft;
            view.textColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
            view.font = [UIFont systemFontOfSize:12];
            view ;
        });
    }
    return _detailLabel ;
}

- (UIButton *)editBtn{
    if(!_editBtn){
        _editBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setTitle:@"编辑" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setBackgroundImage:[UIImage imageNamed:@"btn_round"] forState:UIControlStateNormal];
            [view setUserInteractionEnabled:YES];
            view ;
        });
    }
    return _editBtn ;
}

- (void)setHiddenEditBtn:(BOOL)hiddenEditBtn{
    self.editBtn.hidden = hiddenEditBtn;
}

- (void)setTitleText:(NSString *)titleText{
    self.titleLabel.text = titleText ;
}

- (void)setDetailText:(NSString *)detailText{
    self.detailLabel.text = detailText ;
}

- (void)setIsEdit:(BOOL)isEdit{
    _isEdit = isEdit ;
    if(_isEdit){
        [self.editBtn setTitle:@"完成" forState:UIControlStateNormal];
        [self.detailLabel setText:@"拖拽可以排序"];
    }else{
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [self.detailLabel setText:@"点击进入频道"];
    }
}

@end
