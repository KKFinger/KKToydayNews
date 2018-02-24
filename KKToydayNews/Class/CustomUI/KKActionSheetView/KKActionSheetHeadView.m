//
//  KKActionSheetHeadView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/28.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKActionSheetHeadView.h"

@interface KKActionSheetHeadView()
@property(nonatomic)UILabel *headViewLabel;
@end

@implementation KKActionSheetHeadView

- (instancetype)init{
    if(self = [super init]){
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@ dealloc --- ",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.headViewLabel];
    [self.headViewLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.bottom.mas_equalTo(self).mas_offset(-0.5);
    }];
}

#pragma mark -- @property setter

- (void)setTitle:(NSString *)title{
    self.headViewLabel.text = title ;
}

#pragma mark -- @property getter

- (UILabel *)headViewLabel{
    if(!_headViewLabel){
        _headViewLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.font = [UIFont systemFontOfSize:15];
            view.backgroundColor = [UIColor whiteColor];
            view.textAlignment = NSTextAlignmentCenter;
            view ;
        });
    }
    return _headViewLabel;
}

@end
