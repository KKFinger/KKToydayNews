//
//  KKWeiTouTiaoDetailView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/10.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKWeiTouTiaoDetailView.h"
#import "KKWeiTouTiaoDetailHeader.h"
#import "KKBottomBar.h"
#import "KKFetchNewsTool.h"
#import "KKNewsCommentCell.h"
#import "KKPersonalCommentView.h"
#import "KKAuthorInfoView.h"
#import "KKPersonalInfoView.h"

#define BottomBarHeight 44

static NSString *commentCellReuseable = @"commentCellReuseable";

@interface KKWeiTouTiaoDetailView()<UITableViewDelegate,UITableViewDataSource,KKCommentDelegate,KKBottomBarDelegate,KKAuthorInfoViewDelegate>
@property(nonatomic)UITableView *tableView;
@property(nonatomic)KKBottomBar *bottomBar;
@property(nonatomic)KKWeiTouTiaoDetailHeader *headDetailView;
@property(nonatomic)KKAuthorInfoView *navAuthorView;//导航栏上的作者信息

@property(nonatomic,weak)KKSummaryContent *contentItem;
@property(nonatomic,weak)KKSectionItem *sectionItem;
@property(nonatomic)KKWTTDetailModel *detailModel;
@property(nonatomic,assign) UIStatusBarStyle barStyle;//用于退出新闻详情页时恢复父视图的状态栏颜色
@property(nonatomic)NSMutableArray *commentArray;//评论数组
@end

@implementation KKWeiTouTiaoDetailView

- (instancetype)initWithContentItem:(__weak KKSummaryContent *)contentItem sectionItem:(__weak KKSectionItem *)sectionItem{
    self = [super init];
    if(self){
        self.topSpace = 0 ;
        self.contentItem = contentItem;
        self.sectionItem = sectionItem;
        self.navContentOffsetY = KKStatusBarHeight / 2.0 ;
        self.navTitleHeight = KKNavBarHeight ;
        self.barStyle = [[UIApplication sharedApplication]statusBarStyle];
    }
    return self ;
}

#pragma mark -- 视图的显示和消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self initUI];
    [self refreshData];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
}

- (void)dealloc{
}

#pragma mark -- 初始化UI

- (void)initUI{
    [self.dragContentView addSubview:self.tableView];
    [self.dragContentView addSubview:self.bottomBar];
    
    self.tableView.tableHeaderView = self.headDetailView;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.width.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(self.dragContentView).mas_offset(-BottomBarHeight-self.navTitleHeight).priority(998);
    }];
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(self.dragContentView).priority(998);
        make.height.mas_equalTo(BottomBarHeight);
    }];
    
    [self initNavBar];
}

#pragma mark -- 导航栏

- (void)initNavBar{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"lefterbackicon_titlebar_24x24_"] forState:UIControlStateNormal];
    [backButton setImage:[[UIImage imageNamed:@"lefterbackicon_titlebar_24x24_"] imageWithAlpha:0.5] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(actionForBack) forControlEvents:UIControlEventTouchUpInside];
    self.navTitleView.leftBtns = @[backButton];
    
    self.navAuthorView.showDetailLabel = NO ;
    self.navAuthorView.headerSize = CGSizeMake(30, 30);
    [self.navTitleView addSubview:self.navAuthorView];
    [self.navAuthorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.navTitleView);
        make.centerY.mas_equalTo(self.navTitleView).mas_offset(KKStatusBarHeight/2.0);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(44);
    }];
}

#pragma mark -- 数据刷新

- (void)refreshData{
    self.bottomBar.commentCount = [self.contentItem.comment_count integerValue];
    
    @weakify(self);
    [self.headDetailView refreshWithItem:self.contentItem callback:^(CGFloat viewHeight) {
        @strongify(self);
        [self.headDetailView setHeight:viewHeight];
        [self.tableView reloadData];
    }];
    
    self.navAuthorView.headUrl = self.contentItem.user.avatar_url;
    self.navAuthorView.name = self.contentItem.user.screen_name;
    self.navAuthorView.detail = self.contentItem.user.verified_content;
    self.navAuthorView.userId = self.contentItem.user.user_id;
    
    [self loadWTTDetail];
}

#pragma mark -- 加载详情

- (void)loadWTTDetail{
    [[KKFetchNewsTool shareInstance]fetchWTTDetailInfoWithThreadId:self.contentItem.thread_id success:^(KKWTTDetailModel *modal) {
        self.detailModel = modal;
        [self loadCommentData];
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

#pragma mark -- 加载评论

- (void)loadCommentData{
    [[KKFetchNewsTool shareInstance]fetchWTTCommentWithModal:self.detailModel offset:self.commentArray.count success:^(KKCommentModal *modal) {
        if(modal.commentArray.count){
            [self.commentArray addObjectsFromArray:modal.commentArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
        });
    }];
}

#pragma mark -- UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.commentArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    KKCommentItem *item = [self.commentArray safeObjectAtIndex:indexPath.row];
    return [KKNewsCommentCell fetchHeightWithItem:item] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellReuseable];
    KKCommentItem *item = [self.commentArray safeObjectAtIndex:indexPath.row];
    [((KKNewsCommentCell *)cell) refreshWithItem:item];
    [((KKNewsCommentCell *)cell) setDelegate:self];
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    KKCommentItem *item = [self.commentArray safeObjectAtIndex:indexPath.row];
    [self showPersonalCommentWithId:item.comment.Id];
}

#pragma mark -- 显示个人评论详情视图

- (void)showPersonalCommentWithId:(NSString *)commentId{
    KKPersonalCommentView *view = [[KKPersonalCommentView alloc]initWithCommentId:commentId];
    view.topSpace = 0;
    view.navContentOffsetY = KKStatusBarHeight / 2.0 ;
    view.navTitleHeight = KKNavBarHeight ;
    view.contentViewCornerRadius = 0 ;
    view.cornerEdge = UIRectCornerAllCorners;
    
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

- (void)showCommentView{
    //    CGPoint pt = self.tableView.contentOffset;
    //    pt.y = self.webViewHeight;
    //    [self.tableView setContentOffset:pt animated:YES];
}

- (void)favoriteNews:(BOOL)isFavorite callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)shareNews{
    
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
    
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.tableView.scrollEnabled = NO ;
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    self.tableView.scrollEnabled = YES ;
}

#pragma mark -- KKCommentDelegate

- (void)diggBtnClick:(NSString *)commemtId callback:(void (^)(BOOL))callback{
    NSLog(@"commentId:%@",commemtId);
}

- (void)showAllComment:(NSString *)commentId{
    [self showPersonalCommentWithId:commentId];
}

- (void)jumpToUserPage:(NSString *)userId{
    KKPersonalInfoView *view = [[KKPersonalInfoView alloc]initWithUserId:userId willDissmissBlock:^{
        
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

- (void)setConcern:(BOOL)isConcern userId:(NSString *)userId callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
    NSLog(@"isConcern:%d,userId:%@",isConcern,userId);
}

- (void)reportUser:(NSString *)userId{
    NSLog(@"userId:%@",userId);
}

#pragma mark -- 视图弹出

- (void)actionForBack{
    if (self.showViewType == KKShowViewTypePush) {
        [self pushOutToRight:YES];
    } else if (self.showViewType == KKShowViewTypePopup){
        [self popOutToTop:NO];
    }else {
        [self startHide];
    }
}

#pragma mark -- KKAuthorInfoViewDelegate

- (void)setConcern:(BOOL)isConcern callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)clickedUserHeadWithUserId:(NSString *)userId{
    KKPersonalInfoView *view = [[KKPersonalInfoView alloc]initWithUserId:userId willDissmissBlock:^{
        
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

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if(offsetY >= self.headDetailView.authorView.height){
        self.navAuthorView.hidden = NO ;
    }else{
        self.navAuthorView.hidden = YES ;
    }
}

#pragma mark -- @property

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            view.delegate = self;
            view.dataSource = self ;
            view.backgroundColor = [UIColor whiteColor];
            view.pagingEnabled = NO ;
            [view registerClass:[KKNewsCommentCell class] forCellReuseIdentifier:commentCellReuseable];
            view.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            @weakify(self);
            MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                @strongify(self);
                [self loadCommentData];
            }];
            [footer setTitle:@"正在努力加载" forState:MJRefreshStateIdle];
            [footer setTitle:@"正在努力加载" forState:MJRefreshStateRefreshing];
            [footer setTitle:@"正在努力加载" forState:MJRefreshStatePulling];
            [footer setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            [view setMj_footer:footer];
            
            //iOS11 reloadData界面乱跳bug
            view.estimatedRowHeight = 0;
            view.estimatedSectionHeaderHeight = 0;
            view.estimatedSectionFooterHeight = 0;
            if(IOS11_OR_LATER){
                KKAdjustsScrollViewInsets(view);
            }
            
            view ;
        });
    }
    return _tableView ;
}

- (KKBottomBar *)bottomBar{
    if(!_bottomBar){
        _bottomBar = ({
            KKBottomBar *view = [[KKBottomBar alloc]initWithBarType:KKBottomBarTypeNewsDetail];
            view.delegate = self ;
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _bottomBar;
}

- (KKWeiTouTiaoDetailHeader *)headDetailView{
    if(!_headDetailView){
        _headDetailView = ({
            KKWeiTouTiaoDetailHeader *view = [KKWeiTouTiaoDetailHeader new];
            view ;
        });
    }
    return _headDetailView;
}

- (KKAuthorInfoView *)navAuthorView{
    if(!_navAuthorView){
        _navAuthorView = ({
            KKAuthorInfoView *view = [KKAuthorInfoView new];
            view.delegate = self ;
            view.hidden = YES ;
            view ;
        });
    }
    return _navAuthorView;
}

- (NSMutableArray *)commentArray{
    if(!_commentArray){
        _commentArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _commentArray;
}

@end
