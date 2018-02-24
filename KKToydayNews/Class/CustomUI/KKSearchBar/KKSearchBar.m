//
//  KKSearchBar.m
//  KKToydayNews
//
//  Created by finger on 2017/8/9.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKSearchBar.h"
#import "UISearchBar+Custom.h"

@interface KKSearchBar ()
@property(nonatomic)UIImageView *searchIcon;
@property(nonatomic)UILabel *placeholderLabel;
@end

@implementation KKSearchBar

- (id)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.searchIcon];
    [self addSubview:self.placeholderLabel];
    [self.searchIcon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(5);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.mas_equalTo(self);
    }];
    [self.placeholderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.searchIcon.mas_right).mas_offset(5);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).mas_offset(-5);
    }];
}

#pragma mark -- @property

- (UIImageView *)searchIcon{
    if(!_searchIcon){
        _searchIcon = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.image = [UIImage imageNamed:@"searchicon_search_20x20_"];
            view ;
        });
    }
    return _searchIcon;
}

- (UILabel *)placeholderLabel{
    if(!_placeholderLabel){
        _placeholderLabel = ({
            UILabel *view = [UILabel new];
            view.text = @"输入你感兴趣的内容";
            view.textColor = [UIColor grayColor];
            view.font = [UIFont systemFontOfSize:15];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view ;
        });
    }
    return _placeholderLabel;
}

@end
