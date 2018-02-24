//
//  KKMoreView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/20.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKMoreView.h"

@interface KKMoreView ()
@property(nonatomic)UIButton *bgView;
@property(nonatomic)UIView *contentView;
@property(nonatomic)UIButton *textBtn;
@property(nonatomic)UIButton *picBtn;
@property(nonatomic)UIButton *videoBtn;
@property(nonatomic)UIButton *questionBtn;
@property(nonatomic)UIImageView *closeView;

@property(nonatomic,assign)CGFloat contentViewHeight;
@property(nonatomic,assign)CGFloat btnWH;

@end

@implementation KKMoreView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self ;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.textBtn setEdgeInsetsStyle:KKButtonEdgeInsetsStyleTop imageTitlePadding:20];
    [self.videoBtn setEdgeInsetsStyle:KKButtonEdgeInsetsStyleTop imageTitlePadding:20];
    [self.picBtn setEdgeInsetsStyle:KKButtonEdgeInsetsStyleTop imageTitlePadding:20];
    [self.questionBtn setEdgeInsetsStyle:KKButtonEdgeInsetsStyleTop imageTitlePadding:20];
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    self.contentViewHeight = 160;
    if(iPhoneX){
        self.contentViewHeight += KKSafeAreaBottomHeight;
    }
    self.btnWH = 50 ;
    
    CGFloat space = (UIDeviceScreenWidth - 4 * self.btnWH ) / 5.0 ;
    
    [self addSubview:self.bgView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.textBtn];
    [self.contentView addSubview:self.picBtn];
    [self.contentView addSubview:self.videoBtn];
    [self.contentView addSubview:self.questionBtn];
    [self.contentView addSubview:self.closeView];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    self.contentView.frame = CGRectMake(0, [[UIScreen mainScreen]bounds].size.height, [[UIScreen mainScreen]bounds].size.width, self.contentViewHeight);
    
    UIView *lastView = nil ;
    NSArray *array = @[self.textBtn,self.picBtn,self.videoBtn,self.questionBtn];
    for(UIView *view in array){
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(lastView?(lastView.mas_right):(self)).mas_offset(space);
            make.top.mas_equalTo(self.contentView).mas_offset(35);
            make.width.height.mas_equalTo(self.btnWH);
        }];
        lastView = view ;
    }
    
    [self.closeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).mas_offset(iPhoneX ? -KKSafeAreaBottomHeight : -15);
        make.centerX.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(18);
    }];
}

#pragma mark -- 按钮点击事件

- (void)btnClicked:(id)sender{
    UIButton *btn = (UIButton *)sender;
    KKMoreViewType tag = btn.tag ;
    if(self.delegate && [self.delegate respondsToSelector:@selector(showViewWithType:)]){
        [self.delegate showViewWithType:tag];
    }
}

#pragma mark -- 分享视图的显示隐藏

- (void)showView{
    NSArray *array = @[self.textBtn,self.picBtn,self.videoBtn,self.questionBtn];
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 1.0 ;
        self.contentView.frame = CGRectMake(0, UIDeviceScreenHeight - self.contentViewHeight, UIDeviceScreenWidth, self.contentViewHeight);
    }];
    
    NSTimeInterval delay = 0.0 ;
    for(UIButton *btn in array){
        CGAffineTransform tran = CGAffineTransformMakeTranslation(0, self.contentViewHeight);
        btn.transform = tran ;
        delay += 0.04;
        [UIView animateWithDuration:0.7 delay:delay usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            btn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
    }
    
    CGAffineTransform transform = CGAffineTransformRotate(self.closeView.transform,M_PI);
    [UIView beginAnimations:@"rotate" context:nil ];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [self.closeView setTransform:transform];
    [UIView commitAnimations];
}

- (void)hideView{
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.0;
        self.contentView.frame = CGRectMake(0, UIDeviceScreenHeight, UIDeviceScreenWidth, self.contentViewHeight);
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark -- @property

- (UIButton *)bgView{
    if(!_bgView){
        _bgView = [[UIButton alloc]init];
        _bgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
        _bgView.alpha = 0.0 ;
        [_bgView addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgView;
}

- (UIView *)contentView{
    if(!_contentView){
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = KKColor(238, 238, 238, 1.0);
    }
    return _contentView;
}

- (UIButton *)textBtn{
    if(!_textBtn){
        _textBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"weitoutiao_allshare_60x60_"] forState:UIControlStateNormal];
            [view setTitle:@"文字" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view setTag:KKMoreViewTypeText];
            view ;
        });
    }
    return _textBtn;
}

- (UIButton *)picBtn{
    if(!_picBtn){
        _picBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"video_allshare_60x60_"] forState:UIControlStateNormal];
            [view setTitle:@"图片" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view setTag:KKMoreViewTypeImage];
            view ;
        });
    }
    return _picBtn;
}

- (UIButton *)videoBtn{
    if(!_videoBtn){
        _videoBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"video_allshare_60x60_"] forState:UIControlStateNormal];
            [view setTitle:@"视频" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view setTag:KKMoreViewTypeVideo];
            view ;
        });
    }
    return _videoBtn;
}

- (UIButton *)questionBtn{
    if(!_questionBtn){
        _questionBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"weitoutiao_allshare_60x60_"] forState:UIControlStateNormal];
            [view setTitle:@"提问" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view setTag:KKMoreViewTypeQuestion];
            view ;
        });
    }
    return _questionBtn;
}

- (UIImageView *)closeView{
    if(!_closeView){
        _closeView = ({
            UIImageView *view = [UIImageView new];
            view.image = [UIImage imageNamed:@"button_close"];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.layer.masksToBounds = YES ;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                [self hideView];
            }];
            
            view ;
        });
    }
    return _closeView;
}

@end
