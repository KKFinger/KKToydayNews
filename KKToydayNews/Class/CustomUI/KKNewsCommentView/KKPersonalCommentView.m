//
//  KKPersonalCommentView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/29.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPersonalCommentView.h"
#import "KKFetchNewsTool.h"
#import "KKUserCommentDetail.h"
#import "KKLoadingView.h"
#import "KKPersonalCommentCell.h"
#import "KKNewsCommentCell.h"
#import "KKUserDiggView.h"
#import "KKBottomBar.h"
#import "KKPersonalInfoView.h"

#define BottomBarHeight (KKSafeAreaBottomHeight + 44)

static NSString *detailCellReuseIdentifier = @"detailCellReuseIdentifier";
static NSString *replyCellReuseIdentifier = @"replyCellReuseIdentifier";
static NSString *hotReplyCellReuseIdentifier = @"hotReplyCellReuseIdentifier";
static NSString *headerReuseIdentifier = @"headerReuseIdentifier";

@interface KKTableSectionHeaderView:UITableViewHeaderFooterView
@property(nonatomic)UILabel *titleLabel;
@end

@implementation KKTableSectionHeaderView

- (instancetype)initWithReuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if(self){
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(13);
        make.left.mas_equalTo(self.contentView).mas_offset(kkPaddingNormal);
        make.bottom.mas_equalTo(self.contentView).mas_offset(-5);
    }];
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _titleLabel;
}

@end


@interface KKPersonalCommentView()<UITableViewDelegate,UITableViewDataSource,KKCommentDelegate,KKBottomBarDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)KKLoadingView *loadingView;
@property(nonatomic,strong)KKBottomBar *bottomBar;

@property(nonatomic)KKUserCommentDetail *userComment;
@property(nonatomic)KKCommentDigg *commentDigg;

@property(nonatomic,copy)NSString *commentId;
@property(nonatomic,copy)NSMutableArray<KKCommentObj*> *replayArray;
@property(nonatomic,copy)NSMutableArray<KKCommentObj*> *hostReplyArray;

@property(nonatomic)dispatch_queue_t fetchDataQueue;
@property(nonatomic)dispatch_group_t fetchDataGroup;

@end

@implementation KKPersonalCommentView

- (instancetype)initWithCommentId:(NSString *)commentId{
    self = [super init];
    if(self){
        _commentId = commentId ;
        [self initUI];
    }
    return self ;
}

#pragma mark -- 视图显示/消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self loadData];
}

#pragma mark -- 初始化UI

- (void)initUI{
    self.backgroundColor = [UIColor clearColor];
    self.topSpace = KKStatusBarHeight;
    self.navContentOffsetY = 0 ;
    self.navTitleHeight = 44 ;
    self.contentViewCornerRadius = 10 ;
    self.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
    
    [self.dragContentView addSubview:self.tableView];
    [self.dragContentView insertSubview:self.loadingView aboveSubview:self.tableView];
    [self.dragContentView addSubview:self.bottomBar];
    [self initNavBar];
    
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(self.dragContentView).priority(998);
        make.height.mas_equalTo(BottomBarHeight);
    }];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.right.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
    }];
    
    [self.loadingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
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
}

#pragma mark -- 数据加载

- (void)loadData{
    [self loadUserDigg];
    [self loadUserReply];
    [self loadCommentDetail];
    
    dispatch_group_notify(self.fetchDataGroup, self.fetchDataQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView setHidden:(self.userComment || self.replayArray.count)];
            [self.tableView reloadData];
            
            NSString *commentCount = [[NSNumber numberWithInteger:[self.userComment.detail.comment_count longLongValue]]convert];
            self.navTitleView.titleLabel.hidden = NO ;
            if([commentCount isEqualToString:@"0"]){
                self.navTitleView.title = @"暂无评论";
            }else{
                self.navTitleView.title = [NSString stringWithFormat:@"%@评论",commentCount];
            }
        });
    });
}

- (void)loadCommentDetail{
    dispatch_group_async(self.fetchDataGroup, self.fetchDataQueue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[KKFetchNewsTool shareInstance]fetchPersonalCommentWithCommentId:self.commentId success:^(KKUserCommentDetail *modal) {
            self.userComment = modal;
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}

- (void)loadUserReply{
    dispatch_group_async(self.fetchDataGroup, self.fetchDataQueue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[KKFetchNewsTool shareInstance]fetchReplyWithCommentId:self.commentId offset:self.replayArray.count success:^(KKCommentReply *model) {
            if(model.replyData.replyArray.count){
                [self.replayArray addObjectsFromArray:model.replyData.replyArray];
            }
            if(model.replyData.hot_comments.count){
                [self.hostReplyArray addObjectsFromArray:model.replyData.hot_comments];
            }
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}

- (void)loadMoreUserReply{
    [[KKFetchNewsTool shareInstance]fetchReplyWithCommentId:self.commentId offset:self.replayArray.count success:^(KKCommentReply *model) {
        if(model.replyData.replyArray.count){
            [self.replayArray addObjectsFromArray:model.replyData.replyArray];
        }
        if(model.replyData.hot_comments.count){
            [self.hostReplyArray addObjectsFromArray:model.replyData.hot_comments];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView setHidden:(self.userComment || self.replayArray.count)];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView setHidden:(self.userComment || self.replayArray.count)];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        });
    }];
}

- (void)loadUserDigg{
    dispatch_group_async(self.fetchDataGroup, self.fetchDataQueue, ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[KKFetchNewsTool shareInstance]fetchCommentDiggWithCommentId:self.commentId offset:0 count:10 success:^(KKCommentDigg *modal) {
            self.commentDigg = modal;
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark -- UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        if(self.userComment){
            return 1 ;
        }
        return 0;
    }else if(section == 1){
        return self.hostReplyArray.count;
    }else if(section == 2){
        return self.replayArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0){
        return 10;
    }else if(section == 1){
        return self.hostReplyArray.count ? 30 : 0.001f ;
    }else if(section == 2){
        return 30 ;
    }
    
    return 0 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return [KKPersonalCommentCell fetchHeightWithUserComment:self.userComment];
    }else if(indexPath.section == 1){
        KKCommentObj *obj = [self.hostReplyArray safeObjectAtIndex:indexPath.row];
        return [KKNewsCommentCell fetchHeightWithObj:obj];
    }else if(indexPath.section == 2){
        KKCommentObj *obj = [self.replayArray safeObjectAtIndex:indexPath.row];
        return [KKNewsCommentCell fetchHeightWithObj:obj];
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    KKTableSectionHeaderView *header = (KKTableSectionHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    header.frame = CGRectMake(0, 0, UIDeviceScreenWidth, 30);
    if(section == 0){
        header.titleLabel.text = @"";
    }else if(section == 1){
        header.titleLabel.text = self.hostReplyArray.count ? @"热门评论" : @"";
    }else if(section == 2){
        header.titleLabel.text =  self.replayArray.count ? @"全部评论" : @"抢先评论";
    }
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if(indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:detailCellReuseIdentifier];
        [(KKPersonalCommentCell *)cell refreshWithUserComment:self.userComment userDigg:self.commentDigg];
        [(KKPersonalCommentCell *)cell setDelegate:self];
    }else if(indexPath.section == 1){
        KKCommentObj *obj = [self.hostReplyArray safeObjectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:hotReplyCellReuseIdentifier];
        [(KKNewsCommentCell *)cell refreshWithObj:obj];
        [(KKNewsCommentCell *)cell setDelegate:self];
    }else if(indexPath.section == 2){
        KKCommentObj *obj = [self.replayArray safeObjectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:replyCellReuseIdentifier];
        [(KKNewsCommentCell *)cell refreshWithObj:obj];
        [(KKNewsCommentCell *)cell setDelegate:self];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:replyCellReuseIdentifier];
    }
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark -- KKCommentDelegate

- (void)diggBtnClick:(NSString *)commemtId callback:(void (^)(BOOL))callback{
    NSLog(@"commentId:%@",commemtId);
}

- (void)showAllComment:(NSString *)commentId{
    NSLog(@"commentId:%@",commentId);
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

- (void)reportUser:(NSString *)userId{
    NSLog(@"userId:%@",userId);
}

- (void)showAllDiggUser:(NSString *)commemtId{
    KKUserDiggView *view = [[KKUserDiggView alloc]initWithCommentId:commemtId totalDiggCount:self.userComment.detail.digg_count];
    view.topSpace = 0;
    view.navContentOffsetY = self.navContentOffsetY ;
    view.navTitleHeight = self.navTitleHeight ;
    view.contentViewCornerRadius = self.contentViewCornerRadius ;
    view.cornerEdge = self.cornerEdge;
    view.delegate = self;
    
    [self.dragContentView addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.dragContentView);
    }];
    [view pushIn];
}

#pragma mark -- KKBottomBarDelegate

- (void)sendCommentWidthText:(NSString *)text{
    NSLog(@"%@",text);
}

- (void)diggComment:(BOOL)isDigg callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)shareNews{
    
}

#pragma mark -- 开始、结束拖拽

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
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            view.delegate = self;
            view.dataSource = self ;
            view.backgroundColor = [UIColor whiteColor];
            [view registerClass:[KKPersonalCommentCell class] forCellReuseIdentifier:detailCellReuseIdentifier];
            [view registerClass:[KKNewsCommentCell class] forCellReuseIdentifier:hotReplyCellReuseIdentifier];
            [view registerClass:[KKNewsCommentCell class] forCellReuseIdentifier:replyCellReuseIdentifier];
            [view registerClass:[KKTableSectionHeaderView class] forHeaderFooterViewReuseIdentifier:headerReuseIdentifier];
            view.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            @weakify(self);
            MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                @strongify(self);
                [self loadMoreUserReply];
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
    return _tableView;
}

- (KKLoadingView *)loadingView{
    if(!_loadingView){
        _loadingView = ({
            KKLoadingView *view = [KKLoadingView new];
            view ;
        });
    }
    return _loadingView;
}

- (KKBottomBar *)bottomBar{
    if(!_bottomBar){
        _bottomBar = ({
            KKBottomBar *view = [[KKBottomBar alloc]initWithBarType:KKBottomBarTypePersonalComment];
            view.delegate = self ;
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _bottomBar;
}

- (NSMutableArray<KKCommentObj *> *)replayArray{
    if(!_replayArray){
        _replayArray = [NSMutableArray new];
    }
    return _replayArray;
}

- (NSMutableArray<KKCommentObj *> *)hostReplyArray{
    if(!_hostReplyArray){
        _hostReplyArray = [NSMutableArray new];
    }
    return _hostReplyArray;
}

- (dispatch_group_t)fetchDataGroup{
    if(!_fetchDataGroup){
        _fetchDataGroup = dispatch_group_create();
    }
    return _fetchDataGroup;
}

- (dispatch_queue_t)fetchDataQueue{
    if(!_fetchDataQueue){
        _fetchDataQueue = dispatch_queue_create("fetchCommentQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _fetchDataQueue;
}

@end
