//
//  KKXiaoShiPingPlayView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/15.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKXiaoShiPingPlayView.h"
#import "KKAuthorInfoView.h"
#import "KKBottomBar.h"
#import "KKXiaoShiPingPlayer.h"
#import "KKNewsCommentView.h"
#import "KKPersonalInfoView.h"

#define VideoCorverHorizPading 20
#define VideoItemWith (UIDeviceScreenWidth + VideoCorverHorizPading)
#define BottomBarHeight (KKSafeAreaBottomHeight + 44)
#define VideoCorverViewBaseTag 10000

@interface KKXiaoShiPingPlayView()<UIScrollViewDelegate,KKAuthorInfoViewDelegate,KKBottomBarDelegate,KKXiaoShiPingPlayerDelegate>
@property(nonatomic)KKAuthorInfoView *navAuthorView;
@property(nonatomic)KKBottomBar *bottomBar;
@property(nonatomic)UIScrollView *videoContainer;
@property(nonatomic)UIImageView *animateImageView;//进入播放视图时的动画视图

@property(nonatomic,strong)CAGradientLayer *topGradient;
@property(nonatomic,strong)CAGradientLayer *bottomGradient;

@property(nonatomic)KKNewsBaseInfo *newsInfo;
@property(nonatomic,copy)NSArray<KKSummaryContent *> *videoArray;
@property(nonatomic,assign)NSInteger selIndex;
@property(nonatomic,assign)UIStatusBarStyle barStyle;
@property(nonatomic,assign)BOOL canHideStatusBar;

@end

@implementation KKXiaoShiPingPlayView

- (instancetype)initWithNewsBaseInfo:(KKNewsBaseInfo *)newsInfo
                          videoArray:(NSArray *)videoArray
                            selIndex:(NSInteger)selIndex{
    self = [super init];
    if(self){
        self.topSpace = 0 ;
        self.enableFreedomDrag = NO ;
        self.enableHorizonDrag = YES ;
        self.enableVerticalDrag = YES ;
        self.newsInfo = newsInfo;
        self.navContentOffsetY = 0 ;
        self.navTitleHeight = KKNavBarHeight ;
        self.videoArray = videoArray ;
        self.selIndex = selIndex ;
        self.barStyle = [[UIApplication sharedApplication]statusBarStyle];
    }
    return self ;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.topGradient.frame = CGRectMake(0, 0, self.width, 100);
    self.bottomGradient.frame = CGRectMake(0, self.height - 100, self.width, 100);
}

#pragma mark -- 视图的显示和消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self initUI];
    [self refreshData];
    [self startAnimate];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    @weakify(self);
    [self addTapGestureWithBlock:^(UIView *gestureView) {
        @strongify(self);
        
        self.topGradient.hidden = !self.topGradient.hidden;
        self.bottomGradient.hidden = !self.bottomGradient.hidden;
        
        [[UIApplication sharedApplication]setStatusBarHidden:self.topGradient.hidden withAnimation:UIStatusBarAnimationFade];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.navTitleView.alpha = 1 - self.navTitleView.alpha;
            self.bottomBar.alpha = 1 - self.bottomBar.alpha;
        }completion:^(BOOL finished) {
            
        }];
        
    }];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
    
    //关闭视频
    KKXiaoShiPingPlayer *videoView = [self.videoContainer viewWithTag:VideoCorverViewBaseTag + self.selIndex ];
    [videoView destoryVideoPlayer];
    [videoView removeFromSuperview];
    
    if(self.alphaViewIfNeed){
        self.alphaViewIfNeed(NO);
    }
}

- (void)viewDidAppear{
    [super viewDidAppear];
}

#pragma mark -- 初始化UI

- (void)initUI{
    self.videoContainer.alpha = 0.0 ;
    self.navAuthorView.alpha = 0.0 ;
    self.bottomBar.alpha = 0.0 ;
    self.dragContentView.backgroundColor = [UIColor clearColor];
    
    [self.dragContentView insertSubview:self.videoContainer belowSubview:self.navTitleView];
    [self.dragContentView insertSubview:self.bottomBar aboveSubview:self.videoContainer];
    
    [self.dragContentView.layer insertSublayer:self.topGradient below:self.navTitleView.layer];
    [self.dragContentView.layer insertSublayer:self.bottomGradient below:self.bottomBar.layer];
    
    [self initNavBar];
    
    [self.videoContainer mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dragContentView);
        make.left.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(VideoItemWith);
        make.height.mas_equalTo(self.dragContentView);
    }];
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(self.dragContentView).priority(998);
        make.height.mas_equalTo(BottomBarHeight);
    }];
    
    [self layoutIfNeeded];
    
    [self initVideoPlayView];
}

- (void)initVideoPlayView{
    NSInteger index = 0 ;
    NSInteger count = self.videoArray.count;
    for(KKSummaryContent *item in self.videoArray){
        KKXiaoShiPingPlayer *view = [KKXiaoShiPingPlayer new];
        view.playUrl = item.smallVideo.video.play_addr.url_list.firstObject;
        view.corverUrl = item.smallVideo.large_image_list.firstObject.url;
        view.delegate = self ;
        view.tag = VideoCorverViewBaseTag + index ;
        view.frame = CGRectMake(index * VideoItemWith, 0, UIDeviceScreenWidth, self.videoContainer.height);
        [self.videoContainer addSubview:view];
        index ++;
    }
    
    [self.videoContainer setContentSize:CGSizeMake(VideoItemWith * count, 0)];
    [self.videoContainer setContentOffset:CGPointMake(self.selIndex * VideoItemWith, 0) animated:NO];
    
    KKXiaoShiPingPlayer *view = [self.videoContainer viewWithTag:VideoCorverViewBaseTag + self.selIndex];
    [view setCorverImage:self.oriImage];//防止第一次播放时界面闪烁
    [view startPlayVideo];
}

#pragma mark -- 导航栏

- (void)initNavBar{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"leftbackicon_white_titlebar_24x24_"] forState:UIControlStateNormal];
    [backButton setImage:[[UIImage imageNamed:@"leftbackicon_white_titlebar_24x24_"] imageWithAlpha:0.5] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(dismissVideoPlayView) forControlEvents:UIControlEventTouchUpInside];
    self.navTitleView.leftBtns = @[backButton];
    self.navTitleView.splitView.hidden = YES ;
    self.navTitleView.contentOffsetY = 5 ;
    
    self.navAuthorView.showDetailLabel = NO ;
    self.navAuthorView.headerSize = CGSizeMake(30, 30);
    [self.navTitleView addSubview:self.navAuthorView];
    [self.navAuthorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.navTitleView);
        make.centerY.mas_equalTo(self.navTitleView).mas_offset(5);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
}

#pragma mark -- 数据刷新

- (void)refreshData{
    NSString *headUrl = self.newsInfo.userInfo.avatar_url;
    NSString *name = self.newsInfo.userInfo.name;
    
    self.navAuthorView.name = name;
    self.navAuthorView.headUrl = headUrl;
    self.navAuthorView.isConcern = NO ;
    self.navAuthorView.userId = self.newsInfo.userInfo.user_id;
    
    self.bottomBar.commentCount = [self.newsInfo.commentCount integerValue];
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.enableHorizonDrag = NO ;
    self.enableVerticalDrag = NO ;
    self.enableFreedomDrag = NO ;
    
    CGPoint offset = self.videoContainer.contentOffset;
    CGFloat progress = offset.x / (CGFloat)VideoItemWith;
    
    NSInteger nextIndex = self.selIndex + 1 ;
    if(nextIndex < self.videoArray.count){
        [[scrollView viewWithTag:VideoCorverViewBaseTag + nextIndex]setAlpha:fabs(progress-self.selIndex)];
    }
    
    [[scrollView viewWithTag:VideoCorverViewBaseTag + self.selIndex] setAlpha:1 - fabs((progress-self.selIndex))];
    
    NSInteger perIndex = self.selIndex - 1 ;
    if(perIndex >= 0){
        [[scrollView viewWithTag:VideoCorverViewBaseTag + perIndex] setAlpha:fabs((self.selIndex - progress))];
    }
}

//结束拉拽视图
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
}

//完全停止滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = self.videoContainer.contentOffset;
    NSInteger index = offset.x / VideoItemWith;
    if(index < 0 || index >= self.videoArray.count){
        return ;
    }
    
    self.enableHorizonDrag = (index == 0);
    self.enableVerticalDrag = YES ;
    self.enableFreedomDrag = NO ;
    
    if(self.selIndex != index){
        
        self.selIndex = index ;
        
        KKSummaryContent *item = [self.videoArray safeObjectAtIndex:self.selIndex];
        KKNewsBaseInfo *newsInfo = [KKNewsBaseInfo new];
        newsInfo.title = item.title;
        newsInfo.groupId = item.smallVideo.group_id;
        newsInfo.itemId = item.smallVideo.item_id;
        newsInfo.commentCount = item.smallVideo.action.comment_count;
        newsInfo.userInfo = item.smallVideo.user.info;
        newsInfo.catagory = @"hotsoon_video";
        self.newsInfo = newsInfo;
        
        KKXiaoShiPingPlayer *view = [self.videoContainer viewWithTag:VideoCorverViewBaseTag + self.selIndex];
        [view startPlayVideo];
        
        [self refreshData];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(scrollToIndex:callBack:)]){
            [self.delegate scrollToIndex:self.selIndex callBack:^(CGRect oriFrame, UIImage *oriImage) {
                self.oriFrame = oriFrame;
                self.oriImage = oriImage;
            }];
        }
        
    }
    
    NSInteger nextIndex = self.selIndex + 1 ;
    if(nextIndex < self.videoArray.count){
        [[scrollView viewWithTag:VideoCorverViewBaseTag + nextIndex]setAlpha:1.0];
    }
    
    [[scrollView viewWithTag:VideoCorverViewBaseTag + self.selIndex] setAlpha:1.0];
    
    NSInteger perIndex = self.selIndex - 1 ;
    if(perIndex >= 0){
        [[scrollView viewWithTag:VideoCorverViewBaseTag + perIndex] setAlpha:1.0];
    }
}

#pragma mark -- 显示动画

- (void)startAnimate{
    CGFloat imageW = UIDeviceScreenWidth;
    CGFloat imageH = UIDeviceScreenHeight;
    CGRect frame = CGRectMake(0, 0, imageW, imageH);
    
    CGRect fromRect = [self.oriView convertRect:self.oriFrame toView:self.dragContentView];
    self.animateImageView = [YYAnimatedImageView new];
    self.animateImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.animateImageView.layer.masksToBounds = YES ;
    self.animateImageView.image = self.oriImage;
    self.animateImageView.frame = fromRect;
    [self.dragContentView addSubview:self.animateImageView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.animateImageView.frame = frame;
    }completion:^(BOOL finished) {
        self.videoContainer.alpha = 1.0 ;
        self.navAuthorView.alpha = 1.0 ;
        self.bottomBar.alpha = 1.0 ;
        self.dragContentView.backgroundColor = [UIColor blackColor];
    }];
}

#pragma mark -- 关闭视频并退出界面

- (void)dismissVideoPlayView{
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
    
    KKXiaoShiPingPlayer *videoView = [self.videoContainer viewWithTag:VideoCorverViewBaseTag + self.selIndex];
    //关闭视频
    [videoView destoryVideoPlayer];
    [videoView setHidden:YES];
    
    CGRect frame = videoView.frame ;
    frame = [self.videoContainer convertRect:frame toView:self.dragContentView];
    frame = [self.dragContentView convertRect:frame toView:self.oriView];
    
    self.dragViewBg.alpha = 0;
    self.dragContentView.hidden = YES;
    if(self.hideImageAnimate){
        self.hideImageAnimate(self.oriImage,frame,self.oriFrame);
    }
}

#pragma mark -- KKXiaoShiPingPlayerDelegate

- (void)videoDidPlaying{
    [self.animateImageView removeFromSuperview];
}

#pragma mark -- KKAuthorInfoViewDelegate

- (void)setConcern:(BOOL)isConcern callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)clickedUserHeadWithUserId:(NSString *)userId{
    @weakify(self);
    KKPersonalInfoView *view = [[KKPersonalInfoView alloc]initWithUserId:userId willDissmissBlock:^{
        @strongify(self);
        self.canHideStatusBar = NO ;
    }];
    view.topSpace = 0 ;
    view.navContentOffsetY = KKStatusBarHeight / 2.0 ;
    view.navTitleHeight = KKNavBarHeight ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [view pushIn];
}

#pragma mark -- KKBottomBarDelegate

- (void)sendCommentWidthText:(NSString *)text{
    NSLog(@"%@",text);
}

- (void)favoriteNews:(BOOL)isFavorite callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)shareNews{
    
}

- (void)showCommentView{
    KKNewsCommentView *view = [[KKNewsCommentView alloc]initWithNewsBaseInfo:self.newsInfo];
    view.topSpace = 200 ;
    view.navContentOffsetY = 0 ;
    view.navTitleHeight = 44 ;
    view.contentViewCornerRadius = 10 ;
    view.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [view startShow];
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
    self.enableFreedomDrag = NO ;
    CGFloat offsetY = self.videoContainer.contentOffset.y;
    if(offsetY <=0 || offsetY >= self.videoContainer.contentSize.height){
        self.enableFreedomDrag = YES ;
    }
    
    if(self.alphaViewIfNeed){
        self.alphaViewIfNeed(self.enableFreedomDrag&&!self.defaultHideAnimateWhenDragFreedom);
    }
}

- (void)dragingWithPoint:(CGPoint)pt{
    KKXiaoShiPingPlayer *videoView = [self.videoContainer viewWithTag:VideoCorverViewBaseTag + self.selIndex ];
    if(self.enableFreedomDrag){
        self.navTitleView.alpha = 0;
        self.bottomBar.alpha = 0;
        videoView.layer.transform = CATransform3DMakeScale(self.dragViewBg.alpha,self.dragViewBg.alpha,0);
    }
    
    self.topGradient.hidden = YES ;
    self.bottomGradient.hidden = YES ;
    self.videoContainer.scrollEnabled = NO ;
    self.dragContentView.backgroundColor = [UIColor clearColor];
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    if(self.enableFreedomDrag){
        if(!hideView){
            KKXiaoShiPingPlayer *videoView = [self.videoContainer viewWithTag:VideoCorverViewBaseTag + self.selIndex ];
            [UIView animateWithDuration:0.3 animations:^{
                videoView.layer.transform = CATransform3DIdentity;
            }completion:^(BOOL finished) {
                self.dragContentView.backgroundColor = [UIColor blackColor];
            }];
        }else{
            [self dismissVideoPlayView];
        }
    }else{
        if(self.alphaViewIfNeed){
            self.alphaViewIfNeed(!hideView);
        }
        self.dragContentView.backgroundColor = [UIColor blackColor];
    }
    
    self.enableFreedomDrag = NO ;
    self.enableHorizonDrag = (self.selIndex == 0) ;
    self.enableVerticalDrag = YES ;
    self.videoContainer.scrollEnabled = YES ;
}

#pragma mark -- @property getter

- (UIScrollView *)videoContainer{
    if(!_videoContainer){
        _videoContainer = ({
            UIScrollView *view = [UIScrollView new];
            view.showsVerticalScrollIndicator = NO ;
            view.showsHorizontalScrollIndicator = NO ;
            view.pagingEnabled = YES ;
            view.delegate = self ;
            view.bounces = NO ;
            view.layer.masksToBounds = NO ;
            view.backgroundColor = [UIColor clearColor];
            view.userInteractionEnabled = YES ;
            view ;
        });
    }
    return _videoContainer;
}

- (KKAuthorInfoView *)navAuthorView{
    if(!_navAuthorView){
        _navAuthorView = ({
            KKAuthorInfoView *view = [KKAuthorInfoView new];
            view.delegate = self ;
            view.detailLabel.textColor = [UIColor whiteColor];
            view.nameLabel.textColor = [UIColor whiteColor];
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _navAuthorView;
}

- (KKBottomBar *)bottomBar{
    if(!_bottomBar){
        _bottomBar = ({
            KKBottomBar *view = [[KKBottomBar alloc]initWithBarType:KKBottomBarTypeNewsDetail];
            view.delegate = self ;
            view.splitView.hidden = YES ;
            view.textView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.1];
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _bottomBar;
}

- (CAGradientLayer *)topGradient{
    if(!_topGradient){
        _topGradient = [CAGradientLayer layer];
        _topGradient.colors = @[(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.5].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        _topGradient.startPoint = CGPointMake(0, 0);
        _topGradient.endPoint = CGPointMake(0.0, 1.0);
    }
    return _topGradient;
}

- (CAGradientLayer *)bottomGradient{
    if(!_bottomGradient){
        _bottomGradient = [CAGradientLayer layer];
        _bottomGradient.colors = @[(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.5].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        _bottomGradient.startPoint = CGPointMake(0, 1.0);
        _bottomGradient.endPoint = CGPointMake(0.0, 0.0);
    }
    return _bottomGradient;
}

@end
