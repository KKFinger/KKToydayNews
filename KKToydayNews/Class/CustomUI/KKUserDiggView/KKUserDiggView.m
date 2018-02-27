//
//  KKUserDiggView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKUserDiggView.h"
#import "KKLoadingView.h"
#import "KKUserDiggCell.h"
#import "KKFetchNewsTool.h"
#import "KKUserCommentDetail.h"

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";

@interface KKUserDiggView ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)KKLoadingView *loadingView;

@property(nonatomic,copy)NSString *commentId;
@property(nonatomic,copy)NSString *diggCount;
@property(nonatomic,copy)NSMutableArray<KKUserInfoNew*> *userArray;

@end

@implementation KKUserDiggView

- (instancetype)initWithCommentId:(NSString *)commentId totalDiggCount:(NSString *)diggCount{
    self = [super init];
    if(self){
        _commentId = commentId ;
        _diggCount = diggCount ;
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
    self.topSpace = 0;
    self.navContentOffsetY = 0 ;
    self.navTitleHeight = 44 ;
    self.contentViewCornerRadius = 10 ;
    self.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
    
    [self.dragContentView addSubview:self.tableView];
    [self.dragContentView insertSubview:self.loadingView aboveSubview:self.tableView];
    [self initNavBar];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.right.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
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
    self.navTitleView.title = [NSString stringWithFormat:@"%@人赞过",self.diggCount];
}

#pragma mark -- 数据加载

- (void)loadData{
    [[KKFetchNewsTool shareInstance]fetchCommentDiggWithCommentId:self.commentId offset:self.userArray.count count:30 success:^(KKCommentDigg *model) {
        if(model.data.userList.count){
            [self.userArray addObjectsFromArray:model.data.userList];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView setHidden:self.userArray.count];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView setHidden:self.userArray.count];
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        });
    }];

}

#pragma mark -- UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.userArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KKUserInfoNew *obj = [self.userArray safeObjectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];;
    [(KKUserDiggCell *)cell refreshWithUserInfo:obj];
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    KKUserInfoNew *obj = [self.userArray safeObjectAtIndex:indexPath.row];
    if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
        [self.delegate jumpToUserPage:obj.user_id];
    }
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
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            view.delegate = self;
            view.dataSource = self ;
            [view registerClass:[KKUserDiggCell class] forCellReuseIdentifier:cellReuseIdentifier];
            view.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            @weakify(self);
            MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                @strongify(self);
                [self loadData];
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

- (NSMutableArray<KKUserInfoNew *> *)userArray{
    if(!_userArray){
        _userArray = [NSMutableArray new];
    }
    return _userArray;
}

@end
