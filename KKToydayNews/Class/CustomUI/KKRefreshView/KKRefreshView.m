//
//  KKRefreshView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKRefreshView.h"

@interface KKRefreshView()
@property(nonatomic,strong) UILabel *stateLabel;
@property(nonatomic,strong) UIView *drawView;
@property(nonatomic,strong) UIView *smallRectView;//小方框视图
@property(nonatomic,strong) UIView *shortLineView;//三条短线视图
@property(nonatomic,strong) UIView *longLineView;//三条长线视图
//控件的轮廓
@property(nonatomic,strong) CAShapeLayer *drawViewBoardLayer;
@property(nonatomic,strong) CAShapeLayer *smallRectBoardLayer;
@property(nonatomic,strong) CAShapeLayer *longLineBoardLayer;
@end

@implementation KKRefreshView

#pragma mark - 重写方法，在这里做一些初始化配置（比如添加子控件）

- (void)prepare{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 60;
    
    [self addSubview:self.stateLabel];
    [self addSubview:self.drawView];
    [self.drawView addSubview:self.smallRectView];
    [self.drawView addSubview:self.shortLineView];
    [self.drawView addSubview:self.longLineView];
    
    [self.drawView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(self).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.smallRectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.drawView).mas_offset(3);
        make.top.mas_equalTo(self.drawView).mas_offset(3);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(8);
    }];
    
    [self.shortLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.drawView).mas_offset(12);
        make.top.mas_equalTo(self.drawView).mas_offset(3);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(8);
    }];
    
    [self.longLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.drawView).mas_offset(3);
        make.top.mas_equalTo(self.drawView).mas_offset(12);
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(12);
    }];
    
    [self.stateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.drawView.mas_bottom).mas_offset(-5);
        make.size.mas_equalTo(CGSizeMake(60, 25));
    }];
    
    [self initSmallView];
}

-(void)initSmallView{
    // 带圆角边框 这样绘制 是为了矩形逆时针绘制和运动
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.borderWidth = 0.5; // 线宽
    layer.strokeColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1].CGColor; // 线的颜色
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeStart = 0;
    layer.strokeEnd = 0;
    self.drawViewBoardLayer=layer;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    [path moveToPoint:CGPointMake(25-4, 0)];
    [path addLineToPoint:CGPointMake(4, 0)];
    [path addQuadCurveToPoint:CGPointMake(0, 4) controlPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, 25-4)];
    [path addQuadCurveToPoint:CGPointMake(4, 25) controlPoint:CGPointMake(0, 25)];
    [path addLineToPoint:CGPointMake(25-4, 25)];
    [path addQuadCurveToPoint:CGPointMake(25, 25-4) controlPoint:CGPointMake(25, 25)];
    [path addLineToPoint:CGPointMake(25, 4)];
    [path addQuadCurveToPoint:CGPointMake(25-4, 0) controlPoint:CGPointMake(25, 0)];
    layer.path = path.CGPath;
    [self.drawView.layer addSublayer:layer];
    
    // 里面的小方块
    UIBezierPath *smallpath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 8, 8)];
    smallpath.lineCapStyle = kCGLineCapRound;
    smallpath.lineJoinStyle = kCGLineJoinRound;
    
    CAShapeLayer *smallLayer = [CAShapeLayer layer];
    smallLayer.borderWidth = 0.5; // 线宽
    smallLayer.strokeColor = [UIColor colorWithRed:0.78 green:0.78 blue:0.78 alpha:1].CGColor; // 线的颜色
    smallLayer.fillColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1].CGColor;
    smallLayer.strokeStart = 0;
    smallLayer.strokeEnd = 0;
    smallLayer.path = smallpath.CGPath;
    self.smallRectBoardLayer = smallLayer;
    [self.smallRectView.layer addSublayer:smallLayer];
    
    // 三条短线
    UIBezierPath *shortpath = [UIBezierPath bezierPath];
    [shortpath moveToPoint:CGPointMake(2, 1)];
    [shortpath addLineToPoint:CGPointMake(10, 1)];
    
    [shortpath moveToPoint:CGPointMake(2, 4)];
    [shortpath addLineToPoint:CGPointMake(10, 4)];
    
    [shortpath moveToPoint:CGPointMake(2, 7)];
    [shortpath addLineToPoint:CGPointMake(10, 7)];
    
    CAShapeLayer *shortLineLayer = [CAShapeLayer layer];
    shortLineLayer.borderWidth = 0.5;
    shortLineLayer.strokeColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;
    shortLineLayer.path = shortpath.CGPath;
    [self.shortLineView.layer addSublayer:shortLineLayer];
    
    // 三条长线
    UIBezierPath *longpath = [UIBezierPath bezierPath];
    [longpath moveToPoint:CGPointMake(0, 3)];
    [longpath addLineToPoint:CGPointMake(19, 3)];
    
    [longpath moveToPoint:CGPointMake(0, 6)];
    [longpath addLineToPoint:CGPointMake(19, 6)];
    
    [longpath moveToPoint:CGPointMake(0, 9)];
    [longpath addLineToPoint:CGPointMake(19, 9)];
    
    CAShapeLayer *longLineLayer = [CAShapeLayer layer];
    longLineLayer.strokeStart = 0;
    longLineLayer.strokeEnd = 0;
    longLineLayer.borderWidth=0.5;
    longLineLayer.strokeColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;
    longLineLayer.path = longpath.CGPath;
    self.longLineBoardLayer = longLineLayer;
    [self.longLineView.layer addSublayer:longLineLayer];
}

#pragma mark -- 动画

//使各个视图沿着设置的路劲运动
-(void)loadAnimation{
    [self stopAnimation];
    
    //小方块
    UIBezierPath *smallrectpath = [UIBezierPath bezierPath];
    [smallrectpath moveToPoint:CGPointMake(3+4, 3+4)];
    [smallrectpath addLineToPoint:CGPointMake(13+4, 3+4)];
    [smallrectpath addLineToPoint:CGPointMake(13+4, 13+4)];
    [smallrectpath addLineToPoint:CGPointMake(3+4, 13+4)];
    [smallrectpath addLineToPoint:CGPointMake(3+4, 3+4)];
    
    CAKeyframeAnimation *smallanimation = [CAKeyframeAnimation animation];
    smallanimation.keyPath = @"position";
    smallanimation.path=smallrectpath.CGPath;
    smallanimation.repeatCount = MAXFLOAT;
    smallanimation.calculationMode=kCAAnimationDiscrete;
    smallanimation.fillMode = kCAFillModeForwards;
    smallanimation.duration = 2.0f;
    [self.smallRectView.layer addAnimation:smallanimation forKey:@"rectrun"];
    
    //三条短线视图
    UIBezierPath *shortpath = [UIBezierPath bezierPath];
    [shortpath moveToPoint:CGPointMake(12+4, 3+4)];
    [shortpath addLineToPoint:CGPointMake(1+4, 3+4)];
    [shortpath addLineToPoint:CGPointMake(1+4, 13+4)];
    [shortpath addLineToPoint:CGPointMake(13+4, 13+4)];
    [shortpath addLineToPoint:CGPointMake(12+4, 3+4)];
    
    CAKeyframeAnimation *shortanimation = [CAKeyframeAnimation animation];
    shortanimation.keyPath = @"position";
    shortanimation.path=shortpath.CGPath;
    shortanimation.repeatCount = MAXFLOAT;
    shortanimation.calculationMode=kCAAnimationDiscrete;
    shortanimation.fillMode = kCAFillModeForwards;
    shortanimation.duration = 2.0f;
    [self.shortLineView.layer addAnimation:shortanimation forKey:@"rectrun"];
    
    //三条长线视图
    UIBezierPath *longpath = [UIBezierPath bezierPath];
    [longpath moveToPoint:CGPointMake(3+10, 12+6)];
    [longpath addLineToPoint:CGPointMake(3+10, 6)];
    [longpath addLineToPoint:CGPointMake(3+10, 12+6)];
    
    CAKeyframeAnimation *longanimation = [CAKeyframeAnimation animation];
    longanimation.keyPath = @"position";
    longanimation.path=longpath.CGPath;
    longanimation.repeatCount = MAXFLOAT;
    longanimation.calculationMode=kCAAnimationDiscrete;
    longanimation.fillMode = kCAFillModeForwards;
    longanimation.duration = 2.0f;
    [self.longLineView.layer addAnimation:longanimation forKey:@"rectrun"];
}

-(void)stopAnimation{
    [self.smallRectView.layer removeAllAnimations];
    [self.shortLineView.layer removeAllAnimations];
    [self.longLineView.layer removeAllAnimations];
    
}

#pragma mark -- 监听控件的刷新状态

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            [self stopAnimation];
            self.stateLabel.text=@"";
            break;
        case MJRefreshStatePulling:
            self.stateLabel.text=@"松开推荐";
            [self stopAnimation];
            break;
        case MJRefreshStateRefreshing:
            [self loadAnimation];
            self.stateLabel.text=@"推荐中";
            break;
        default:
            break;
    }
}

#pragma mark -- 监听scrollView的contentOffset改变

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{
    CGPoint newPoint;
    id newValue = [change valueForKey:NSKeyValueChangeNewKey ];
    [(NSValue*)newValue getValue:&newPoint ];
    
    double y = fabs(newPoint.y);
    
    self.drawViewBoardLayer.strokeEnd = y/50;
    self.smallRectBoardLayer.strokeEnd = y/50;
    self.longLineBoardLayer.strokeEnd  = y/50;
    
    [super scrollViewContentOffsetDidChange:change];
}

#pragma mark -- @property

-(UILabel *)stateLabel{
    if(!_stateLabel){
        _stateLabel=[UILabel new];
        _stateLabel.font=[UIFont systemFontOfSize:12];
        _stateLabel.text=@"下拉推荐";
        _stateLabel.textColor=[UIColor colorWithRed:0.49 green:0.49 blue:0.5 alpha:1];
        _stateLabel.textAlignment=NSTextAlignmentCenter;
    }
    return _stateLabel;
}

-(UIView *)drawView{
    if(!_drawView){
        _drawView=[UIView new];
        _drawView.backgroundColor=[UIColor clearColor];
    }
    return _drawView;
}

-(UIView *)smallRectView{
    if(!_smallRectView){
        _smallRectView=[UIView new];
        _smallRectView.backgroundColor=[UIColor clearColor];
    }
    return _smallRectView;
}

-(UIView *)shortLineView{
    if(!_shortLineView){
        _shortLineView=[UIView new];
        _shortLineView.backgroundColor=[UIColor clearColor];
    }
    return _shortLineView;
}

-(UIView *)longLineView{
    if(!_longLineView){
        _longLineView=[UIView new];
        _longLineView.backgroundColor=[UIColor clearColor];
    }
    return _longLineView;
}

@end
