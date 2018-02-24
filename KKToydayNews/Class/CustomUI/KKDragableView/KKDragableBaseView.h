//
//  KKDragableBaseView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/29.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKDragableBaseView : UIView
@property(nonatomic,readonly)UIView *dragViewBg ;//用户设置整个视图的背景
@property(nonatomic,readonly)UIView *dragContentView ;//需要显示的视图都加到dragContentView里面

@property(nonatomic,assign)CGFloat topSpace ;//dragContentView的顶部距离屏幕上方的距离
@property(nonatomic,assign)CGFloat contentViewCornerRadius;//dragContentView的圆角
@property(nonatomic,assign)UIRectCorner cornerEdge;//设定dragContentView的哪些边需要圆角
@property(nonatomic,assign,readonly)KKMoveDirection dragDirection;//拖动的方向
@property(nonatomic)BOOL enableHorizonDrag;//是否允许水平拖拽，默认为YES
@property(nonatomic)BOOL enableVerticalDrag;//是否允许垂直拖拽，默认为YES
@property(nonatomic)BOOL enableFreedomDrag;//允许自由拖拽,默认为NO,设为YES，则enableHorizonDrag、enableVerticalDrag自动失效
@property(nonatomic)BOOL defaultHideAnimateWhenDragFreedom;//自由拖拽时，是否使用默认的隐藏动画，默认为YES
@property(nonatomic)KKShowViewType showViewType;//pop push

#pragma mark -- 显示与隐藏动画

- (void)startShow;
- (void)startHide;

- (void)popIn;
- (void)popOutToTop:(BOOL)toTop;
- (void)pushIn;
- (void)pushOutToRight:(BOOL)toRight;

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt;
- (void)dragingWithPoint:(CGPoint)pt;
- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView;

#pragma mark -- 视图显示/消失

- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;

@end
