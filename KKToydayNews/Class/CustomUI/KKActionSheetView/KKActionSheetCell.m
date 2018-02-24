//
//  KKActionSheetCell.m
//  KKToydayNews
//
//  Created by finger on 2017/11/28.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKActionSheetCell.h"

@interface KKActionSheetCell()
@property(nonatomic)UIButton *itemBtn;
@end

@implementation KKActionSheetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView addSubview:self.itemBtn];
    [self.itemBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 按钮点击

- (void)btnClicked:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSString *title = btn.titleLabel.text;
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectWithTitle:)]){
        [self.delegate selectWithTitle:title];
    }
}

#pragma mark -- @property getter

- (UIButton *)itemBtn{
    if(!_itemBtn){
        _itemBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
            [btn setTitleColor:KKColor(16, 131, 254, 1.0) forState:UIControlStateNormal];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
            [btn setBackgroundColor:[UIColor whiteColor]];
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            btn ;
        });
    }
    return _itemBtn;
}

#pragma mark -- @property setter

- (void)setTitle:(NSString *)title{
    [self.itemBtn setTitle:title forState:UIControlStateNormal];
}

@end
