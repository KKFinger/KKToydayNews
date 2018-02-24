//
//  KKGalleryImageCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/22.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKGalleryImageCell.h"

@interface KKGalleryImageCell()
@property(nonatomic,readwrite)UIView *contentBgView;
@property(nonatomic)UIButton *operatorBtn;
@property(nonatomic)UIButton *operatorBtnMask;
@property(nonatomic,readwrite)UIImageView *imageView;
@property(nonatomic)UIView *disableView;
@property(nonatomic,strong)CAGradientLayer *topGradient;
@property(nonatomic,assign)KKGalleryCellType cellType;
@property(nonatomic,weak)KKPhotoInfo *item;
@end

@implementation KKGalleryImageCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.topGradient.frame = self.bounds;
    [CATransaction commit];
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.contentView addSubview:self.contentBgView];
    [self.contentView addSubview:self.disableView];
    [self.contentBgView addSubview:self.imageView];
    [self.contentBgView addSubview:self.operatorBtn];
    [self.contentBgView addSubview:self.operatorBtnMask];
    [self.contentBgView.layer insertSublayer:self.topGradient below:self.operatorBtn.layer];
    
    [self.contentBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.disableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.operatorBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentBgView).mas_offset(5);
        make.right.mas_equalTo(self.contentBgView).mas_offset(-5);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.operatorBtnMask mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.operatorBtn);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentBgView);
    }];
}

#pragma mark -- 操作

- (void)operatorBtnClicked{
    if(self.cellType == KKGalleryCellTypeDelete){
        if(self.delegate && [self.delegate respondsToSelector:@selector(deleteImage:)]){
            [self.delegate deleteImage:self];
        }
    }else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(selectImage:photoItem:)]){
            [self.delegate selectImage:self photoItem:self.item];
        }
    }
}

#pragma mark -- 刷新界面

- (void)refreshCell:(KKPhotoInfo *)item cellType:(KKGalleryCellType)type disable:(BOOL)disable{
    self.item = item ;
    self.cellType = type;
    self.imageView.image = item.image;
    self.operatorBtn.hidden = item.isPlaceholderImage ;
    self.operatorBtnMask.hidden = item.isPlaceholderImage ;
    self.topGradient.hidden = item.isPlaceholderImage;
    if(type == KKGalleryCellTypeDelete){
        [self.operatorBtn setImage:[UIImage imageNamed:@"Introduction_delete"] forState:UIControlStateNormal];
        [self.operatorBtn setImage:[UIImage imageNamed:@"Introduction_delete"] forState:UIControlStateSelected];
        [self.operatorBtn setSelected:NO];
    }else{
        [self.operatorBtn setImage:[UIImage imageNamed:@"checkbox-normal-grey"] forState:UIControlStateNormal];
        [self.operatorBtn setImage:[UIImage imageNamed:@"checkbox-selected"] forState:UIControlStateSelected];
        [self.operatorBtn setSelected:item.isSelected];
    }
    self.disable = disable;
}

#pragma mark -- 选中动画

- (void)selectAnimate{
    [UIView animateWithDuration:0.1 animations:^{
        self.operatorBtn.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.operatorBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.operatorBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }];
    }];
}

#pragma mark -- @property setter

- (void)setDisable:(BOOL)disable{
    if(disable){
        self.disableView.hidden = NO;
        self.userInteractionEnabled = NO ;
    }else{
        self.disableView.hidden = YES ;
        self.userInteractionEnabled = YES ;
    }
}

#pragma mark -- @property getter

- (UIView *)contentBgView{
    if(!_contentBgView){
        _contentBgView = ({
            UIView *view = [UIView new];
            view ;
        });
    }
    return _contentBgView;
}

- (UIButton *)operatorBtn{
    if(!_operatorBtn){
        _operatorBtn = ({
            UIButton *view = [UIButton new];
            [view addTarget:self action:@selector(operatorBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [view setSelected:NO];
            view ;
        });
    }
    return _operatorBtn;
}

- (UIButton *)operatorBtnMask{
    if(!_operatorBtnMask){
        _operatorBtnMask = ({
            UIButton *view = [UIButton new];
            [view addTarget:self action:@selector(operatorBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _operatorBtnMask;
}

- (UIImageView *)imageView{
    if(!_imageView){
        _imageView = ({
            UIImageView *view = [UIImageView new];
            view.layer.masksToBounds = YES ;
            view.contentMode = UIViewContentModeScaleAspectFill;
            view ;
        });
    }
    return _imageView;
}

- (UIView *)disableView{
    if(!_disableView){
        _disableView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
            view.hidden = YES ;
            view.userInteractionEnabled = NO ;
            view ;
        });
    }
    return _disableView;
}

- (CAGradientLayer *)topGradient{
    if(!_topGradient){
        _topGradient = [CAGradientLayer layer];
        _topGradient.colors = @[(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.3].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        _topGradient.startPoint = CGPointMake(0, 0);
        _topGradient.endPoint = CGPointMake(0.0, 1.0);
    }
    return _topGradient;
}

@end
