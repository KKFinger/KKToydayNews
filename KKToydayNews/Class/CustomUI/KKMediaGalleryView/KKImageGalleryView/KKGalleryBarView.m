//
//  KKGalleryBarView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKGalleryBarView.h"

@interface KKGalleryBarView()
@property(nonatomic)UIButton *previewBtn;
@end

@implementation KKGalleryBarView

- (instancetype)init{
    if(self = [super init]){
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.previewBtn];
    [self.previewBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.centerY.mas_equalTo(self);
    }];
}

#pragma mark -- 预览

- (void)previewClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(previewImage)]){
        [self.delegate previewImage];
    }
}

- (void)setEnablePreview:(BOOL)enablePreview{
    self.previewBtn.enabled = enablePreview;
}

#pragma mark -- @property

- (UIButton *)previewBtn{
    if(!_previewBtn){
        _previewBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"预览" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor grayColor]colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
            [view addTarget:self action:@selector(previewClicked) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _previewBtn;
}

@end
