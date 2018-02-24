//
//  KKShareView.m
//  KKShareView
//
//  Created by finger on 2017/8/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKShareView.h"
#import "Masonry.h"
#import "KKShareItem.h"

@interface KKShareView ()
@property(nonatomic,strong)UIButton *bgView;
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)UIScrollView *shareScrollView1;
@property(nonatomic,strong)UIView *splitLine1;
@property(nonatomic,strong)UIScrollView *shareScrollView2;
@property(nonatomic,strong)UIView *splitLine2;
@property(nonatomic,strong)UIButton *cancelBtn;

@property(nonatomic,assign)CGFloat scrollViewHeight;
@property(nonatomic,assign)CGFloat cancelBtnHeight;
@property(nonatomic,assign)CGFloat contentViewHeight;
@property(nonatomic,assign)CGSize shareBtnSize;
@property(nonatomic,assign)CGFloat shareBtnSpace;
@end

@implementation KKShareView

- (id)init{
    self = [super init];
    if(self){
        self.scrollViewHeight = 100;
        self.cancelBtnHeight = 50 ;
        self.contentViewHeight = 2 * self.scrollViewHeight + self.cancelBtnHeight + 2 ;
        self.shareBtnSize = CGSizeMake(60, 80);
        self.shareBtnSpace = 20 ;
        [self setupUI];
    }
    return self ;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.bgView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.splitLine1];
    [self.contentView addSubview:self.shareScrollView1];
    [self.contentView addSubview:self.splitLine2];
    [self.contentView addSubview:self.shareScrollView2];
    [self.contentView addSubview:self.cancelBtn];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    self.contentView.frame = CGRectMake(0, [[UIScreen mainScreen]bounds].size.height, [[UIScreen mainScreen]bounds].size.width, self.contentViewHeight);
    
    [self.shareScrollView1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.scrollViewHeight);
    }];
    
    [self.splitLine1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shareScrollView1.mas_bottom);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.8);
    }];
    
    [self.shareScrollView2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.splitLine1.mas_bottom);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.scrollViewHeight);
    }];
    
    [self.splitLine2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shareScrollView2.mas_bottom);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.8);
    }];
    
    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.splitLine2.mas_bottom);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.cancelBtnHeight);
    }];
}

#pragma mark -- 加载分享平台

- (void)setShareInfos:(NSArray<NSArray<KKShareItem *> *> *)shareInfos{
    NSInteger index = 0 ;
    for(NSArray *array in shareInfos){
        NSInteger subIndex = 0 ;
        for(KKShareItem *item in array){
            UIButton *btn = [self createShareBtnWithItem:item];
            if(index == 0){
                [self.shareScrollView1 addSubview:btn];
                [btn setFrame:CGRectMake(subIndex * (self.shareBtnSize.width + self.shareBtnSpace) + self.shareBtnSpace, (self.scrollViewHeight - self.shareBtnSize.height) / 2 , self.shareBtnSize.width, self.shareBtnSize.height)];
            }else{
                [self.shareScrollView2 addSubview:btn];
                [btn setFrame:CGRectMake(subIndex * (self.shareBtnSize.width + self.shareBtnSpace) + self.shareBtnSpace, (self.scrollViewHeight - self.shareBtnSize.height) / 2, self.shareBtnSize.width, self.shareBtnSize.height)];
            }
            [self setButtonContentCenter:btn];
            
            subIndex ++ ;
        }
        index ++ ;
    }
}

- (UIButton *)createShareBtnWithItem:(KKShareItem *)item{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:item.title forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:item.shareIconName] forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setTag:item.shareType];
    [btn addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn ;
}

-(void)setButtonContentCenter:(UIButton *) btn{
    CGSize imgViewSize,titleSize,btnSize;
    UIEdgeInsets imageViewEdge,titleEdge;
    CGFloat heightSpace = 10.0f;
    
    //设置按钮内边距
    imgViewSize = btn.imageView.bounds.size;
    titleSize = btn.titleLabel.bounds.size;
    btnSize = btn.bounds.size;
    
    imageViewEdge = UIEdgeInsetsMake(heightSpace,4.0, btnSize.height -imgViewSize.height - heightSpace, - titleSize.width);
    [btn setImageEdgeInsets:imageViewEdge];
    
    titleEdge = UIEdgeInsetsMake(imgViewSize.height +heightSpace, - imgViewSize.width, 0.0, 0.0);
    [btn setTitleEdgeInsets:titleEdge];
}

- (void)shareBtnClicked:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if(self.delegate && [self.delegate respondsToSelector:@selector(shareWithType:)]){
        [self.delegate shareWithType:btn.tag];
    }
    [self hideShareView];
}

#pragma mark -- 分享视图的显示隐藏

- (void)showShareView{
    NSMutableArray *array1 = [NSMutableArray arrayWithCapacity:0];
    [self.shareScrollView1.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[UIButton class]]){
            [array1 addObject:obj];
        }
    }];
    
    NSMutableArray *array2 = [NSMutableArray arrayWithCapacity:0];
    [self.shareScrollView2.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:[UIButton class]]){
            [array2 addObject:obj];
        }
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 1.0 ;
        self.contentView.frame = CGRectMake(0, [[UIScreen mainScreen]bounds].size.height - self.contentViewHeight, [[UIScreen mainScreen]bounds].size.width, self.contentViewHeight);
    }];
    
    NSTimeInterval delay = 0.0 ;
    for(UIButton *btn in array1){
        CGAffineTransform tran = CGAffineTransformMakeTranslation(0, self.scrollViewHeight);
        btn.transform = tran ;
        delay += 0.08;
        [UIView animateWithDuration:0.7 delay:delay usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            btn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
    }
    
    delay = 0.0;
    for(UIButton *btn in array2){
        CGAffineTransform tran = CGAffineTransformMakeTranslation(0, self.scrollViewHeight);
        btn.transform = tran ;
        delay += 0.08;
        [UIView animateWithDuration:0.7 delay:delay usingSpringWithDamping:0.7 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            btn.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
        }];
    }

}

- (void)hideShareView{
    [UIView animateWithDuration:0.3 animations:^{
        self.bgView.alpha = 0.0;
        self.contentView.frame = CGRectMake(0, [[UIScreen mainScreen]bounds].size.height, [[UIScreen mainScreen]bounds].size.width, self.contentViewHeight);
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark -- 广告视图点击

- (void)adViewClicked{
    
}

#pragma mark -- @property

- (UIButton *)bgView{
    if(!_bgView){
        _bgView = [[UIButton alloc]init];
        _bgView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
        _bgView.alpha = 0.0 ;
        [_bgView addTarget:self action:@selector(hideShareView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bgView;
}

- (UIView *)contentView{
    if(!_contentView){
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    }
    return _contentView;
}

- (UIView *)splitLine1{
    if(!_splitLine1){
        _splitLine1 = [[UIView alloc]init];
        _splitLine1.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.2];
    }
    return _splitLine1;
}

- (UIScrollView *)shareScrollView1{
    if(!_shareScrollView1){
        _shareScrollView1 = [[UIScrollView alloc]init];
        _shareScrollView1.backgroundColor = [UIColor clearColor];
        _shareScrollView1.showsVerticalScrollIndicator = NO ;
        _shareScrollView1.showsHorizontalScrollIndicator = NO ;
        _shareScrollView1.scrollEnabled = YES ;
        _shareScrollView1.clipsToBounds = YES ;
        _shareScrollView1.bounces = YES ;
    }
    return _shareScrollView1;
}

- (UIView *)splitLine2{
    if(!_splitLine2){
        _splitLine2 = [[UIView alloc]init];
        _splitLine2.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.2];
    }
    return _splitLine2;
}

- (UIScrollView *)shareScrollView2{
    if(!_shareScrollView2){
        _shareScrollView2 = [[UIScrollView alloc]init];
        _shareScrollView2.backgroundColor = [UIColor clearColor];
        _shareScrollView2.showsVerticalScrollIndicator = NO ;
        _shareScrollView2.showsHorizontalScrollIndicator = NO ;
        _shareScrollView2.clipsToBounds = YES ;
        _shareScrollView2.scrollEnabled = YES ;
        _shareScrollView2.bounces = YES ;
    }
    return _shareScrollView2;
}

- (UIButton *)cancelBtn{
    if(!_cancelBtn){
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(hideShareView) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setBackgroundColor:[UIColor clearColor]];
    }
    return _cancelBtn;
}

@end
