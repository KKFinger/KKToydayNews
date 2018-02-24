//
//  KKAddMoreView.m
//  KKToydayNews
//
//  Created by finger on 2017/8/9.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKAddMoreView.h"

@interface KKAddMoreView ()
@property(nonatomic,strong)UIButton *addBtn;
@property(nonatomic,strong)UIView *splitView ;
@property(nonatomic,strong)CAGradientLayer *gradientLayer;
@end

@implementation KKAddMoreView

- (id)init{
    self = [super init];
    if(self){
        [self setupUI];
        [self bandingEvent];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.layer insertSublayer:self.gradientLayer atIndex:0];
    [self addSubview:self.addBtn];
    [self addSubview:self.splitView];
    
    [self.addBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.centerY.mas_equalTo(self.centerY);
        make.width.mas_equalTo(0.3);
        make.height.mas_equalTo(20);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.gradientLayer.frame = self.bounds;
}

#pragma mark -- 绑定事件

- (void)bandingEvent{
    [self.addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addBtnClicked{
    if(self.addBtnClickHandler){
        self.addBtnClickHandler();
    }
}

#pragma mark -- @property

- (UIButton *)addBtn{
    if(!_addBtn){
        _addBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            [view setImage:[[UIImage imageNamed:@"add"]imageWithAlpha:0.5] forState:UIControlStateHighlighted];
            view ;
        });
    }
    return _addBtn ;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [[UIView alloc]init];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
            view ;
        });
    }
    return _splitView ;
}

- (CAGradientLayer *)gradientLayer{
    if(!_gradientLayer){
        _gradientLayer = ({
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            //注意:设置透明色，系统按黑色来处理
            gradientLayer.colors = [NSArray arrayWithObjects:
                                    (id)[[[UIColor whiteColor]colorWithAlphaComponent:0.7] CGColor],
                                    (id)[[UIColor whiteColor] CGColor],nil];
            //startPoint和endPoint设置方向
            gradientLayer.startPoint = CGPointMake(0.0, 0.0);
            gradientLayer.endPoint = CGPointMake(1.0, 0.0);
            gradientLayer.locations = @[@(0.0),@(0.6)];//各个渐变颜色对应的起始位置
            gradientLayer;
        });
    }
    return _gradientLayer;
}

@end
