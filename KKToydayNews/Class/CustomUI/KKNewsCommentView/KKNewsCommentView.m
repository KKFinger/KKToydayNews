//
//  KKNewsCommentView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/3.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKNewsCommentView.h"
#import "KKLoadingView.h"
#import "KKBottomBar.h"
#import "KKNewsCommentCell.h"
#import "KKFetchNewsTool.h"
#import "KKPersonalCommentView.h"
#import "KKPersonalInfoView.h"

#define BottomBarHeight (KKSafeAreaBottomHeight + 44)

static NSString *commentCellReuseable = @"commentCellReuseable";

@interface KKNewsCommentView ()<UITableViewDelegate,UITableViewDataSource,KKBottomBarDelegate,KKCommentDelegate>
@property(nonatomic)UITableView *tableView;
@property(nonatomic)KKBottomBar *bottomBar;
@property(nonatomic)KKLoadingView *loadingView;

@property(nonatomic)KKNewsBaseInfo *newsInfo;
@property(nonatomic)NSMutableArray *commentArray;//评论数组

@end

@implementation KKNewsCommentView

- (instancetype)initWithNewsBaseInfo:(KKNewsBaseInfo *)newsInfo{
    self = [super init];
    if(self){
        self.topSpace = 0 ;
        self.newsInfo = newsInfo;
        self.navContentOffsetY = 0 ;
        self.navTitleHeight = 44 ;
        self.contentViewCornerRadius = 10 ;
        self.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
    }
    return self ;
}

#pragma mark -- 视图的显示和消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self initUI];
    [self loadCommentData];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
}

#pragma mark -- 初始化UI

- (void)initUI{
    [self.dragContentView addSubview:self.tableView];
    [self.dragContentView insertSubview:self.loadingView aboveSubview:self.tableView];
    [self.dragContentView insertSubview:self.bottomBar aboveSubview:self.tableView];
    
    [self initNavBar];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.width.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(self.dragContentView).mas_offset(-BottomBarHeight-self.navTitleHeight).priority(998);
    }];
    [self.loadingView mas_updateConstraints:^(MASConstraintMaker *make) {
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
}

#pragma mark -- 导航栏

- (void)initNavBar{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"button_close"] forState:UIControlStateNormal];
    [backButton setImage:[[UIImage imageNamed:@"button_close"] imageWithAlpha:0.5] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(startHide) forControlEvents:UIControlEventTouchUpInside];
    self.navTitleView.leftBtns = @[backButton];
    self.navTitleView.title = @"评论";
}

#pragma mark -- 加载评论

- (void)loadCommentData{
    NSString *group_id = self.newsInfo.groupId;
    NSString *item_id = self.newsInfo.itemId;
    [[KKFetchNewsTool shareInstance]fetchCommentWithCatagory:self.newsInfo.catagory groupId:group_id itemId:item_id offset:self.commentArray.count sortIndex:0 success:^(KKCommentModal *model){
        if(model.commentArray.count){
            [self.commentArray addObjectsFromArray:model.commentArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
            [self.loadingView setHidden:self.commentArray.count];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
            [self.loadingView setHidden:self.commentArray.count];
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
    view.navContentOffsetY = 0 ;
    view.navTitleHeight = 44 ;
    view.contentViewCornerRadius = 10 ;
    view.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
    
    [self.dragContentView addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.dragContentView);
    }];
    [view startShow];
}

#pragma mark -- KKBottomBarDelegate

- (void)sendCommentWidthText:(NSString *)text{
    NSLog(@"%@",text);
}

#pragma mark -- KKCommentDelegate

- (void)diggBtnClick:(NSString *)commemtId callback:(void (^)(BOOL))callback{
    NSLog(@"commentId:%@",commemtId);
}

- (void)showAllComment:(NSString *)commentId{
    [self showPersonalCommentWithId:commentId];
}

- (void)jumpToUserPage:(NSString *)userId{
    KKPersonalInfoView *view = [[KKPersonalInfoView alloc]initWithUserId:userId willDissmissBlock:nil];
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

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
    
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.tableView.scrollEnabled = NO ;
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    self.tableView.scrollEnabled = YES ;
}

#pragma mark -- @property

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            view.delegate = self;
            view.dataSource = self ;
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

- (KKLoadingView *)loadingView{
    if(!_loadingView){
        _loadingView = ({
            KKLoadingView *view = [KKLoadingView new];
            view;
        });
    }
    return _loadingView;
}

- (KKBottomBar *)bottomBar{
    if(!_bottomBar){
        _bottomBar = ({
            KKBottomBar *view = [[KKBottomBar alloc]initWithBarType:KKBottomBarTypePictureComment];
            view.delegate = self ;
            view ;
        });
    }
    return _bottomBar;
}

- (NSMutableArray *)commentArray{
    if(!_commentArray){
        _commentArray = [NSMutableArray new];
    }
    return _commentArray;
}

@end
