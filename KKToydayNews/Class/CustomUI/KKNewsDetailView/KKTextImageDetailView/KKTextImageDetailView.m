//
//  KKTextImageDetailView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/9.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKTextImageDetailView.h"
#import "KKLoadingView.h"
#import "KKBottomBar.h"
#import "KKSummaryDataModel.h"
#import "KKTextImageDetailHeadView.h"
#import "KKFetchNewsTool.h"
#import "KKNewsCommentCell.h"
#import "KKPersonalCommentView.h"
#import "KKPersonalInfoView.h"

#define BottomBarHeight 44

static NSString *commentCellReuseable = @"commentCellReuseable";

@interface KKTextImageDetailView ()<UITableViewDelegate,UITableViewDataSource,KKCommentDelegate,KKBottomBarDelegate,KKTextImageDetailHeadViewDelegate>
@property(nonatomic)UITableView *tableView;
@property(nonatomic)KKBottomBar *bottomBar;
@property(nonatomic)KKTextImageDetailHeadView *headDetailView;

@property(nonatomic,weak)KKSummaryContent *contentItem;
@property(nonatomic,weak)KKSectionItem *sectionItem;
@property(nonatomic,assign) UIStatusBarStyle barStyle;//用于退出新闻详情页时恢复父视图的状态栏颜色
@property(nonatomic)NSDictionary *commentInfo;//评论数组
@property(nonatomic)KKSortCommentType sortType;
@end

@implementation KKTextImageDetailView

- (instancetype)initWithContentItem:(__weak KKSummaryContent *)contentItem sectionItem:(__weak KKSectionItem *)sectionItem{
    self = [super init];
    if(self){
        self.topSpace = 0 ;
        self.contentItem = contentItem;
        self.sectionItem = sectionItem;
        self.navContentOffsetY = KKStatusBarHeight / 2.0 ;
        self.navTitleHeight = KKNavBarHeight ;
        self.sortType = KKSortCommentTypeHot;
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
}

#pragma mark -- 数据刷新

- (void)refreshData{
    self.bottomBar.commentCount = [self.contentItem.comment_count integerValue];
    [self.headDetailView refreshWithItem:self.contentItem];
    [self loadCommentData];
}

#pragma mark -- 加载评论

- (void)loadCommentData{
    NSMutableArray *array = [self.commentInfo objectForKey:@(self.sortType)];
    [[KKFetchNewsTool shareInstance]fetchCommentWithCatagory:self.sectionItem.category groupId:self.contentItem.group_id itemId:self.contentItem.item_id offset:array.count sortIndex:self.sortType success:^(KKCommentModal *model) {
        if(model.commentArray.count){
            [array addObjectsFromArray:model.commentArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        });
    }];
}

#pragma mark -- UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSMutableArray *array = [self.commentInfo objectForKey:@(self.sortType)];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [self.commentInfo objectForKey:@(self.sortType)];
    KKCommentItem *item = [array safeObjectAtIndex:indexPath.row];
    return [KKNewsCommentCell fetchHeightWithItem:item] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellReuseable];
    NSMutableArray *array = [self.commentInfo objectForKey:@(self.sortType)];
    KKCommentItem *item = [array safeObjectAtIndex:indexPath.row];
    [((KKNewsCommentCell *)cell) refreshWithItem:item];
    [((KKNewsCommentCell *)cell) setDelegate:self];
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = [self.commentInfo objectForKey:@(self.sortType)];
    KKCommentItem *item = [array safeObjectAtIndex:indexPath.row];
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

#pragma mark -- KKTextImageDetailHeadView

- (void)sortCommentByType:(KKSortCommentType)type{
    self.sortType = type;
    NSArray *array = [self.commentInfo objectForKey:@(self.sortType)];
    if(!array.count){
        [self loadCommentData];
    }else{
        [self.tableView reloadData];
    }
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

#pragma mark -- @property

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            view.delegate = self;
            view.dataSource = self ;
            view.backgroundColor = [UIColor whiteColor];
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

- (KKTextImageDetailHeadView *)headDetailView{
    if(!_headDetailView){
        _headDetailView = ({
            KKTextImageDetailHeadView *view = [KKTextImageDetailHeadView new];
            view.delegate = self ;
            view ;
        });
    }
    return _headDetailView;
}

- (NSDictionary *)commentInfo{
    if(!_commentInfo){
        _commentInfo = [[NSDictionary alloc]initWithObjectsAndKeys:[NSMutableArray new],@(KKSortCommentTypeHot), [NSMutableArray new],@(KKSortCommentTypeTime),nil];
    }
    return _commentInfo;
}

@end
