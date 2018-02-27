//
//  KKVideoNewsDetail.m
//  KKToydayNews
//
//  Created by finger on 2017/10/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKVideoNewsDetail.h"
#import "KKAuthorInfoView.h"
#import "KKBottomBar.h"
#import "KKLoadingView.h"
#import "KKVideoInfoView.h"
#import "KKAVPlayerView.h"
#import "KKFetchNewsTool.h"
#import "KKNewsCommentCell.h"
#import "KKSummaryDataModel.h"
#import "KKPersonalCommentView.h"
#import "KKRelateVideoCell.h"
#import "KKPersonalInfoView.h"

#define AuthorViewHeight 44
#define BottomBarHeight (KKSafeAreaBottomHeight + 44)

static CGFloat videoPlayViewHeight = 0 ;
static NSString *commentCellReuseable = @"commentCellReuseable";
static NSString *relateVideoCellReuseable = @"relateVideoCellReuseable";

@interface KKVideoNewsDetail ()<UITableViewDelegate,UITableViewDataSource,KKBottomBarDelegate,KKAuthorInfoViewDelegate,KKAVPlayerViewDelegate,KKCommentDelegate>
@property(nonatomic)UIView *videoContentView;
@property(nonatomic)KKAuthorInfoView *authorView;
@property(nonatomic)UITableView *tableView;
@property(nonatomic)KKBottomBar *bottomBar;//视图的底部视图，评论、转发、收藏等
@property(nonatomic)KKLoadingView *loadingView;//加载等待视图
@property(nonatomic)KKVideoInfoView *videoInfoView;
@property(nonatomic,weak)KKAVPlayerView *videoPlayView;

@property(nonatomic)KKNewsBaseInfo *newsInfo;

@property(nonatomic,copy)NSMutableArray<KKCommentItem*> *commentArray;
@property(nonatomic,copy)NSMutableArray<KKSummaryContent*> *relateVideoArray;

@property(nonatomic,assign)UIStatusBarStyle barStyle;

@end

@implementation KKVideoNewsDetail

- (instancetype)initWithNewsBaseInfo:(KKNewsBaseInfo *)newsInfo{
    self = [super init];
    if(self){
        self.topSpace = 0 ;
        self.newsInfo = newsInfo;
        self.barStyle = [UIApplication sharedApplication].statusBarStyle;
        if(iPhoneX){
            videoPlayViewHeight = (UIDeviceScreenWidth * 4 / 7.0 ) + KKStatusBarHeight;
        }else{
            videoPlayViewHeight = (UIDeviceScreenWidth * 4 / 7.0 ) ;
        }
    }
    return self ;
}

#pragma mark -- 视图的显示和消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self initUI];
    [self refreshData];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    if(iPhoneX){
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    }else{
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:NO];
    }
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
}

- (void)viewDidDisappear{
    [super viewDidDisappear];
    [self.videoPlayView destoryVideoPlayer];
    [self.videoPlayView removeFromSuperview];
    self.videoPlayView = nil ;
}

- (void)dealloc{
}

#pragma mark -- 初始化UI

- (void)initUI{
    [self.dragContentView addSubview:self.videoContentView];
    [self.dragContentView addSubview:self.authorView];
    [self.dragContentView addSubview:self.tableView];
    [self.dragContentView insertSubview:self.loadingView aboveSubview:self.tableView];
    [self.dragContentView addSubview:self.bottomBar];
    
    [self.videoContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(videoPlayViewHeight);
    }];
    
    [self.authorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView);
        make.top.mas_equalTo(self.videoContentView.mas_bottom);
        make.width.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(AuthorViewHeight);
    }];
    
    self.videoInfoView.frame = CGRectMake(0, 0, UIDeviceScreenWidth, 1);
    self.tableView.tableHeaderView = self.videoInfoView;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authorView.mas_bottom);
        make.left.width.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(self.dragContentView).mas_offset(-BottomBarHeight-AuthorViewHeight - videoPlayViewHeight).priority(998);
    }];
    [self.loadingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.tableView);
    }];
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(self.dragContentView).priority(998);
        make.height.mas_equalTo(BottomBarHeight);
    }];
}

#pragma mark -- 数据刷新

- (void)refreshData{
    NSString *publishTime = [NSString stringIntervalSince1970RuleOne:self.newsInfo.publicTime.longLongValue];
    
    self.videoInfoView.publicTime = publishTime;
    self.videoInfoView.title = self.newsInfo.title;
    self.videoInfoView.playCount = self.newsInfo.videoWatchCount;
    self.videoInfoView.descText = self.newsInfo.title;
    self.videoInfoView.diggCount = self.newsInfo.diggCount;
    self.videoInfoView.disDiggCount = self.newsInfo.buryCount;
    self.videoInfoView.height = self.videoInfoView.viewHeight;
    
    NSString *headUrl = self.newsInfo.userInfo.avatar_url;
    NSString *name = self.newsInfo.userInfo.name;
    
    self.authorView.name = name;
    self.authorView.headUrl = headUrl;
    self.authorView.isConcern = NO ;
    self.authorView.headerSize = CGSizeMake(30, 30);
    self.authorView.userId = self.newsInfo.userInfo.user_id;
    
    self.bottomBar.commentCount = [self.newsInfo.commentCount integerValue];
    
    [self loadVideoDetailData];
    [self loadCommentData];
}

#pragma mark -- 加载视频详情信息

- (void)loadVideoDetailData{
    [[KKFetchNewsTool shareInstance]fetchDetailNewsWithCatagory:self.newsInfo.catagory groupId:self.newsInfo.groupId itemId:self.newsInfo.itemId success:^(KKArticleModal *modal) {
        if(modal.articleData.related_video_toutiao.count){
            [self.relateVideoArray addObjectsFromArray:modal.articleData.related_video_toutiao];
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

#pragma mark -- 加载评论

- (void)loadCommentData{
    [[KKFetchNewsTool shareInstance]fetchCommentWithCatagory:self.newsInfo.catagory groupId:self.newsInfo.groupId itemId:self.newsInfo.itemId offset:self.commentArray.count sortIndex:0 success:^(KKCommentModal *model) {
        if(model.commentArray.count){
            [self.commentArray addObjectsFromArray:model.commentArray];
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
    return 2 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return self.relateVideoArray.count;
    }else if(section == 1){
        return self.commentArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        KKSummaryContent *item = [self.relateVideoArray safeObjectAtIndex:indexPath.row];
        return [KKRelateVideoCell fetchHeightWithItem:item] ;
    }else if(indexPath.section == 1){
        KKCommentItem *item = [self.commentArray safeObjectAtIndex:indexPath.row];
        return [KKNewsCommentCell fetchHeightWithItem:item] ;
    }
    return 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil ;
    if(indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:relateVideoCellReuseable];
        KKSummaryContent *item = [self.relateVideoArray safeObjectAtIndex:indexPath.row];
        [((KKRelateVideoCell *)cell) refreshWithItem:item];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:commentCellReuseable];
        KKCommentItem *item = [self.commentArray safeObjectAtIndex:indexPath.row];
        [((KKNewsCommentCell *)cell) refreshWithItem:item];
        [((KKNewsCommentCell *)cell) setDelegate:self];
    }
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        KKSummaryContent *contentItem = [self.relateVideoArray safeObjectAtIndex:indexPath.row];
        [self playRelateVideo:contentItem];
    }else if(indexPath.section == 1){
        KKCommentItem *item = [self.commentArray safeObjectAtIndex:indexPath.row];
        [self showPersonalCommentWithId:item.comment.Id];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01f;
}

#pragma mark -- 播放推荐的视频

- (void)playRelateVideo:(KKSummaryContent *)contentItem{
    KKNewsBaseInfo *newsInfo = [KKNewsBaseInfo new];
    newsInfo.title = contentItem.title;
    newsInfo.groupId = contentItem.group_id;
    newsInfo.itemId = contentItem.item_id;
    newsInfo.source = contentItem.source;
    newsInfo.articalUrl = contentItem.display_url;
    newsInfo.publicTime = contentItem.publish_time;
    newsInfo.catagory = self.newsInfo.catagory;
    newsInfo.videoWatchCount = contentItem.video_detail_info.video_watch_count;
    newsInfo.diggCount = contentItem.digg_count;
    newsInfo.buryCount = contentItem.bury_count ;
    newsInfo.commentCount = contentItem.comment_count;
    newsInfo.userInfo = contentItem.user_info;
    self.newsInfo = newsInfo ;
    
    NSString *videoId = contentItem.video_detail_info.video_id;
    NSString *title = contentItem.title;
    NSString *playCount = contentItem.video_detail_info.video_watch_count;
    NSString *url = contentItem.video_detail_info.detail_video_large_image.url;
    if(!url.length){
        url = contentItem.image_list.firstObject.url;
    }
    if(!url.length){
        url = @"";
    }
    
    [self.videoPlayView destoryVideoPlayer];
    KKAVPlayerView *view = [[KKAVPlayerView alloc]initWithTitle:title playCount:playCount coverUrl:url videoId:videoId smallType:KKSamllVideoTypeDetail];
    [self addVideoPlayView:view];
    
    [self.relateVideoArray removeAllObjects];
    [self.commentArray removeAllObjects];
    
    [self refreshData];
}

#pragma mark -- 添加视频播放器

- (void)addVideoPlayView:(KKAVPlayerView *)playView{
    [playView removeFromSuperview];
    
    self.videoPlayView = playView;
    self.videoPlayView.originalFrame = CGRectMake(0, 0, UIDeviceScreenWidth, videoPlayViewHeight) ;
    self.videoPlayView.originalView = self.videoContentView;
    self.videoPlayView.delegate = self;
    self.videoPlayView.fullScreen = NO ;
    [self.videoContentView addSubview:self.videoPlayView];
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
        self.videoPlayView.canHideStatusBar = YES ;
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
    
    self.videoPlayView.canHideStatusBar = NO ;
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

#pragma mark -- KKAVPlayerViewDelegate

- (void)enterFullScreen{
    //[[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
}

- (void)quitFullScreen{
    //[[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:NO];
}

- (void)quitVideoDetailView{
    [self pushOutToRight:YES];
}

#pragma mark -- KKCommentDelegate

- (void)diggBtnClick:(NSString *)commemtId callback:(void (^)(BOOL))callback{
    NSLog(@"commentId:%@",commemtId);
}

- (void)showAllComment:(NSString *)commentId{
    [self showPersonalCommentWithId:commentId];
}

- (void)jumpToUserPage:(NSString *)userId{
    @weakify(self);
    KKPersonalInfoView *view = [[KKPersonalInfoView alloc]initWithUserId:userId willDissmissBlock:^{
        @strongify(self);
        self.videoPlayView.canHideStatusBar = YES ;
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
    
    self.videoPlayView.canHideStatusBar = NO ;
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

#pragma mark -- 显示个人评论详情视图

- (void)showPersonalCommentWithId:(NSString *)commentId{
    KKPersonalCommentView *view = [[KKPersonalCommentView alloc]initWithCommentId:commentId];
    view.navContentOffsetY = 0 ;
    view.navTitleHeight = 44 ;
    view.topSpace = 0 ;
    view.contentViewCornerRadius = 0 ;
    view.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
    
    CGFloat top = self.authorView.top ;
    CGFloat height = self.dragContentView.height - top;
    [self.dragContentView addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(top);
        make.size.mas_equalTo(CGSizeMake(self.dragContentView.width,height));
    }];
    [view startShow];
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

- (UIView *)videoContentView{
    if(!_videoContentView){
        _videoContentView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor blackColor];
            view;
        });
    }
    return _videoContentView;
}

- (KKAuthorInfoView *)authorView{
    if(!_authorView){
        _authorView = ({
            KKAuthorInfoView *view = [KKAuthorInfoView new];
            view.showDetailLabel = NO ;
            view.delegate = self ;
            view.showBottomSplit = YES ;
            view ;
        });
    }
    return _authorView;
}

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            view.delegate = self;
            view.dataSource = self ;
            view.backgroundColor = [UIColor whiteColor];
            [view registerClass:[KKNewsCommentCell class] forCellReuseIdentifier:commentCellReuseable];
            [view registerClass:[KKRelateVideoCell class] forCellReuseIdentifier:relateVideoCellReuseable];
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
            view.backgroundColor = [UIColor whiteColor];
            view.delegate = self ;
            view ;
        });
    }
    return _bottomBar;
}

- (KKLoadingView *)loadingView{
    if(!_loadingView){
        _loadingView = ({
            KKLoadingView *view = [KKLoadingView new];
            view.hidden = YES ;
            view;
        });
    }
    return _loadingView;
}

- (KKVideoInfoView *)videoInfoView{
    if(!_videoInfoView){
        _videoInfoView = ({
            KKVideoInfoView *view = [KKVideoInfoView new];
            @weakify(view)
            @weakify(self);
            [view setChangeViewHeight:^(CGFloat height){
                @strongify(view);
                @strongify(self);
                view.height = height;
                [self.tableView reloadData];
            }];
            view ;
        });
    }
    return _videoInfoView;
}

- (NSMutableArray<KKCommentItem *> *)commentArray{
    if(!_commentArray){
        _commentArray = [NSMutableArray new];
    }
    return _commentArray;
}

- (NSMutableArray<KKSummaryContent *> *)relateVideoArray{
    if(!_relateVideoArray){
        _relateVideoArray = [NSMutableArray new];
    }
    return _relateVideoArray;
}

@end
