//
//  KKImageDescView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKImageDescView.h"
#import "TYAttributedLabel.h"

static CGFloat topPadding = 44 ;
static CGFloat defaultHeight = 120 ;

@interface KKImageDescView ()<UIGestureRecognizerDelegate>
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)TYAttributedLabel *descLabel;
@property(nonatomic,strong)UIPanGestureRecognizer *panRecognizer;//拖动视图的手势
@end

@implementation KKImageDescView

- (instancetype)init{
    self = [super init];
    if(self){
        self.layer.masksToBounds = YES ;
        self.showsVerticalScrollIndicator = NO ;
        self.showsHorizontalScrollIndicator = NO;
        self.scrollEnabled = YES ;
        [self addGestureRecognizer:self.panRecognizer];
        [self initUI];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"dealloc --- %@",NSStringFromClass([self class]));
}

#pragma mark -- UI

- (void)initUI{
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.descLabel];
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.mas_equalTo(self);
        make.height.mas_equalTo(1);
    }];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(kkPaddingNormal);
        make.top.mas_equalTo(self.contentView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(self.contentView).mas_offset(-2 * kkPaddingNormal).priority(998);
        make.height.mas_equalTo(self.contentView).mas_offset(-2 * kkPaddingNormal).priority(998);
    }];
}

#pragma mark -- 界面刷新

- (void)refreshViewAttriData:(TYTextContainer *)data{
    self.descLabel.textContainer = data;
    
    CGFloat contentHeight = data.attriTextHeight + 2 * kkPaddingNormal ;
    
    self.contentSize = CGSizeMake(self.width, contentHeight);
    self.contentOffset = CGPointMake(0, 0);
    
    self.panRecognizer.enabled = NO ;
    
    if(contentHeight > defaultHeight){
        self.panRecognizer.enabled = YES ;
    }
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(contentHeight);
    }];
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        if(contentHeight > defaultHeight){
            make.top.mas_equalTo(self).mas_offset(topPadding);
        }else{
            make.top.mas_equalTo(self).mas_offset(0);
        }
        make.height.mas_equalTo(contentHeight);
    }];
}

#pragma mark -- 文本的宽度

+ (CGFloat)descTextWidth{
    return UIDeviceScreenWidth - 2 * kkPaddingNormal;
}

#pragma mark -- 拖动手势

- (void)panRecognizer:(UIPanGestureRecognizer *)panRecognizer{
    UIGestureRecognizerState state = panRecognizer.state;
    CGPoint point = [panRecognizer translationInView:self];
    if(state == UIGestureRecognizerStateChanged){
        CGFloat top = self.contentView.top;
        if(top >= 0 && top <= topPadding){
            self.contentView.centerY = self.contentView.centerY + point.y;
        }else{
            if(top < 0){
                if(point.y > 0){
                    self.contentView.centerY = self.contentView.centerY + point.y;
                }
            }
            if(top > topPadding){
                if(point.y < 0){
                    self.contentView.centerY = self.contentView.centerY + point.y;
                }
            }
        }
        [panRecognizer setTranslation:CGPointMake(0, 0) inView:self];
        
        self.layer.masksToBounds = NO ;
        
    }else if(state == UIGestureRecognizerStateEnded ||
             state == UIGestureRecognizerStateFailed ||
             state == UIGestureRecognizerStateCancelled){
        
        if(self.contentView.top > topPadding){
            [UIView animateWithDuration:0.3 animations:^{
                self.contentView.top = topPadding;
            }completion:^(BOOL finished) {
                self.layer.masksToBounds = YES ;
            }];
        }else if(self.contentView.top < 0){
            [UIView animateWithDuration:0.3 animations:^{
                self.contentView.top = 0;
            }completion:^(BOOL finished) {
                self.layer.masksToBounds = YES ;
            }];
        }else{
            self.layer.masksToBounds = YES ;
        }
    }else if(state == UIGestureRecognizerStateBegan){
    }
}

#pragma mark -- @property

- (UIView *)contentView{
    if(!_contentView){
        _contentView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
            view ;
        });
    }
    return _contentView;
}

- (TYAttributedLabel *)descLabel{
    if(!_descLabel){
        _descLabel = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
            view.numberOfLines = 0;
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view;
        });
    }
    return _descLabel;
}

- (UIPanGestureRecognizer *)panRecognizer{
    if(!_panRecognizer){
        _panRecognizer = ({
            UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
            recognizer.delegate = self ;
            recognizer;
        });
    }
    return _panRecognizer;
}

@end
