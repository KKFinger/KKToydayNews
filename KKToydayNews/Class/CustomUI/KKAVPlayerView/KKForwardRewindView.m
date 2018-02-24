//
//  KKForwardRewindView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKForwardRewindView.h"

@interface KKForwardRewindView()
@property(nonatomic)UIButton *forwardRewindBtn;
@property(nonatomic)UILabel *curtTimeLabel;
@property(nonatomic)UILabel *totalTimeLabel;
@property(nonatomic)UIView *totalTimeSlider;
@property(nonatomic)UIView *curtTimeSlider;
@end

@implementation KKForwardRewindView

- (instancetype)init{
    self = [super init];
    if(self){
        [self initUI];
    }
    return self ;
}

- (void)initUI{
    [self setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0.8]];
    [self addSubview:self.forwardRewindBtn];
    [self addSubview:self.curtTimeLabel];
    [self addSubview:self.totalTimeLabel];
    [self addSubview:self.totalTimeSlider];
    [self addSubview:self.curtTimeSlider];
    
    [self.forwardRewindBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_centerY);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(25);
    }];
    
    [self.curtTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_centerY);
        make.right.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(20);
    }];
    
    [self.totalTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.curtTimeLabel);
        make.left.mas_equalTo(self.mas_centerX);
        make.height.mas_equalTo(20);
    }];
    
    [self.totalTimeSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.curtTimeLabel.mas_bottom).mas_offset(5);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(2);
        make.width.mas_equalTo(self).mas_offset(- 2 * kkPaddingNormal).priority(998);
    }];
    
    [self.curtTimeSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.totalTimeSlider);
        make.left.mas_equalTo(self.totalTimeSlider);
        make.height.mas_equalTo(self.totalTimeSlider);
        make.width.mas_equalTo(0);
    }];
    
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- @property setter

- (void)setIsForward:(BOOL)isForward{
    _isForward = isForward;
    self.forwardRewindBtn.selected = isForward;
}

- (void)setCurtTime:(NSString *)curtTime{
    _curtTime = curtTime;
    self.curtTimeLabel.text = curtTime;
}

- (void)setTotalTime:(NSString *)totalTime{
    _totalTime = totalTime;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"/%@",totalTime];
}

- (void)setPercent:(CGFloat)percent{
    _percent = percent;
    [self.curtTimeSlider mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.totalTimeSlider.width * percent);
    }];
}

#pragma mark -- @property getter

- (UIButton *)forwardRewindBtn{
    if(!_forwardRewindBtn){
        _forwardRewindBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setTitle:@"▶▶" forState:UIControlStateSelected];
            [view setTitle:@"◀◀" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:20]];
            view ;
        });
    }
    return _forwardRewindBtn;
}

- (UILabel*)curtTimeLabel{
    if(!_curtTimeLabel){
        _curtTimeLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor redColor];
            view.textAlignment = NSTextAlignmentCenter;
            view.font = [UIFont systemFontOfSize:13];
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view;
        });
    }
    return _curtTimeLabel;
}

- (UILabel *)totalTimeLabel{
    if(!_totalTimeLabel){
        _totalTimeLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor whiteColor];
            view.textAlignment = NSTextAlignmentCenter;
            view.font = [UIFont systemFontOfSize:13];
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view;
        });
    }
    return _totalTimeLabel;
}

- (UIView *)totalTimeSlider{
    if(!_totalTimeSlider){
        _totalTimeSlider = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _totalTimeSlider;
}

- (UIView *)curtTimeSlider{
    if(!_curtTimeSlider){
        _curtTimeSlider = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor redColor];
            view ;
        });
    }
    return _curtTimeSlider;
}

@end
