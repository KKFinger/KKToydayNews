//
//  KKRecordCorverSlider.m
//  KKToydayNews
//
//  Created by finger on 2017/11/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKRecordCorverSlider.h"
#import "KKVideoInfo.h"
#import "KKFetchVideoCorverTool.h"

#define baseTag 1000
#define sliderViewHeight 50

@interface KKRecordCorverSlider ()<UIGestureRecognizerDelegate>
@property(nonatomic)UILabel *descLabel;
@property(nonatomic)UIView *sliderView;
@property(nonatomic)UIImageView *selImageView;
@property(nonatomic)UIPanGestureRecognizer *panRecognizer;//拖动视图的手势
@property(nonatomic)KKVideoInfo *videoInfo ;
@end

@implementation KKRecordCorverSlider

- (instancetype)initWithVideoInfo:(KKVideoInfo *)videoInfo{
    if(self = [super init]){
        self.videoInfo  = videoInfo;
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.descLabel];
    [self addSubview:self.sliderView];
    [self.sliderView addSubview:self.selImageView];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_centerY).mas_offset(-sliderViewHeight/2.0-self.descLabel.font.lineHeight/2.0-3);
        make.width.left.mas_equalTo(self);
    }];
    [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom).mas_offset(3);
        make.left.width.mas_equalTo(self);
        make.height.mas_equalTo(sliderViewHeight);
    }];
    
    CGFloat width = UIDeviceScreenWidth / 5.0 ;
    for(NSInteger i = 0 ; i < 5 ; i++){
        UIImageView *view = [UIImageView new];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.layer.masksToBounds = YES ;
        view.tag = baseTag + i ;
        [self.sliderView insertSubview:view belowSubview:self.selImageView];
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.sliderView);
            make.left.mas_equalTo(self.sliderView).mas_offset( i * width);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(self.sliderView);
        }];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            CGFloat time = (((i * width) + width /2.0) / UIDeviceScreenWidth) * self.videoInfo.duration;
            UIImage *image = [[KKFetchVideoCorverTool sharedInstance]syncCopyCorverWithSeconds:time] ;
            dispatch_async(dispatch_get_main_queue(), ^{
                view.image = image;
            });
        });
    }
    
    self.selImageView.frame = CGRectMake(0, 0, sliderViewHeight, sliderViewHeight);
}

#pragma mark -- 拖动手势

- (void)panRecognizer:(UIPanGestureRecognizer *)panRecognizer{
    UIGestureRecognizerState state = panRecognizer.state;
    CGPoint point = [panRecognizer translationInView:self.sliderView];
    if(state == UIGestureRecognizerStateChanged){
        CGFloat centerX = self.selImageView.centerX + point.x;
        if(centerX < self.selImageView.width/2.0){
            centerX = self.selImageView.width/2.0 ;
        }else if(centerX > self.sliderView.width - self.selImageView.width/2.0){
            centerX = self.sliderView.width - self.selImageView.width/2.0;
        }
        self.selImageView.centerX = centerX;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(seekToPosition:)]){
            [self.delegate seekToPosition:(centerX / UIDeviceScreenWidth)];
        }
        
        [panRecognizer setTranslation:CGPointMake(0, 0) inView:self.sliderView];
        
    }else if(state == UIGestureRecognizerStateEnded ||
             state == UIGestureRecognizerStateFailed ||
             state == UIGestureRecognizerStateCancelled){
        
    }else if(state == UIGestureRecognizerStateBegan){
    }
}

#pragma mark -- @property setter

- (void)setSelImage:(UIImage *)selImage{
    self.selImageView.image = selImage;
}

#pragma mark -- @property getter

- (UILabel *)descLabel{
    if(!_descLabel){
        _descLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:13];
            view.textColor = [UIColor grayColor];
            view.textAlignment = NSTextAlignmentCenter;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.text = @"滑动选择一张封面";
            view ;
        });
    }
    return _descLabel;
}

- (UIView *)sliderView{
    if(!_sliderView){
        _sliderView = ({
            UIView *view = [UIView new];
            view.userInteractionEnabled = YES ;
            [view addGestureRecognizer:self.panRecognizer];
            
            @weakify(self);
            [view addTapWithGestureBlock:^(UITapGestureRecognizer *gesture) {
                @strongify(self);
                CGPoint point = [gesture locationInView:self.sliderView];
                CGFloat centerX = point.x;
                if(centerX < self.selImageView.width/2.0){
                    centerX = self.selImageView.width/2.0 ;
                }else if(centerX > self.sliderView.width - self.selImageView.width/2.0){
                    centerX = self.sliderView.width - self.selImageView.width/2.0;
                }
                self.selImageView.centerX = centerX;
                
                if(self.delegate && [self.delegate respondsToSelector:@selector(seekToPosition:)]){
                    [self.delegate seekToPosition:(centerX / UIDeviceScreenWidth)];
                }
            }];
            
            view ;
        });
    }
    return _sliderView;
}

- (UIImageView *)selImageView{
    if(!_selImageView){
        _selImageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.layer.masksToBounds = YES ;
            view.layer.borderWidth = 1.0;
            view.layer.borderColor = [UIColor redColor].CGColor;
            view.backgroundColor = [UIColor blackColor];
            view ;
        });
    }
    return _selImageView;
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
