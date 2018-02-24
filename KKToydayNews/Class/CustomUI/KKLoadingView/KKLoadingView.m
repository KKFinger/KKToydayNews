//
//  KKLoadingView.h
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//
#import "KKLoadingView.h"


@interface KKLoadingView ()
@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,strong) UIImageView *maskImageView;
@end

@implementation KKLoadingView

-(instancetype)init{
    if(self=[super init]){
        [self setupUI];
    }
    return self;
}

#pragma mark -- 初始化UI

-(void)setupUI{
    self.backgroundColor=[UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    [self addSubview:self.imageView];
    [self.imageView addSubview:self.maskImageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(180, 135));
    }];
    
    [self.maskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.imageView);
        make.left.equalTo(self.imageView).offset(-30);
        make.size.mas_equalTo(CGSizeMake(170, 100));
    }];
}

-(void)loadAnimation{
    [self.maskImageView.layer removeAllAnimations];
    
    //关键帧动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    animation.duration = 1.5;
    //配置关键帧每一帧的值
    animation.values = @[@40,@160,@170];
    //    animation.path
    //配置关键帧每一帧起始时间,范围 0 - 1
    animation.keyTimes = @[@0.2,@0.7,@1];
    // animation.additive = YES;
    
    //配置关键帧每一帧之间的线性变换
    animation.timingFunctions = @[
                                  [CAMediaTimingFunction functionWithName:
                                   kCAMediaTimingFunctionEaseIn],
                                  [CAMediaTimingFunction functionWithName:
                                   kCAMediaTimingFunctionLinear],
                                  [CAMediaTimingFunction functionWithName:
                                   kCAMediaTimingFunctionEaseOut],
                                  ];
    animation.repeatCount=MAXFLOAT;
    
    [self.maskImageView.layer addAnimation:animation forKey:@"positionx"];
}

-(void)hideAnimate{
    [self.maskImageView.layer removeAllAnimations];
}

- (void)setHidden:(BOOL)hidden{
    [super setHidden:hidden];
    if(hidden){
        [self hideAnimate];
    }else{
        [self loadAnimation];
    }
}

#pragma mark -- @property

-(UIImageView*)imageView{
    if(!_imageView){
        _imageView = ({
            UIImageView *view=[UIImageView new];
            view.image=[UIImage imageNamed:@"details_slogan01"];
            view ;
        });
    }
    return _imageView;
}

-(UIImageView *)maskImageView{
    if(!_maskImageView){
        _maskImageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleToFill;
            view.image = [UIImage imageNamed:@"details_slogan03"];
            view.alpha = 0.01;
            view ;
        });
    }
    return _maskImageView;
}

@end
