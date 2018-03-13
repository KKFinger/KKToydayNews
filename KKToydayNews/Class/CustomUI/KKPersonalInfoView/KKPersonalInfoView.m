//
//  KKPersonalInfoView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPersonalInfoView.h"
#import "KKPersonalInfoHeadView.h"
#import "KKFetchNewsTool.h"
#import "KKAuthorInfoView.h"
#import "KKPersonalReleaseView.h"
#import "KKRecognizeSimultaneousTableView.h"

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";

@interface KKPersonalInfoView()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,KKAuthorInfoViewDelegate,UIGestureRecognizerDelegate>
@property(nonatomic)KKRecognizeSimultaneousTableView *tableView ;
@property(nonatomic)KKPersonalInfoHeadView *headerView;
@property(nonatomic)KKAuthorInfoView *navAuthorView;
@property(nonatomic)KKPersonalReleaseView *releaseView ;

@property(nonatomic)NSString *userId;
@property(nonatomic)NSString *mediaId;
@property(nonatomic)UIStatusBarStyle barStyle;
@property(nonatomic,assign)CGFloat headerViewHeight ;
@property(nonatomic,assign)CGFloat footerViewHeight;
@property(nonatomic,assign)BOOL canScroll;

@property(nonatomic)KKPersonalInfo *personalInfo;
@property(nonatomic,copy)willDissmissBlock willDissmissBlock;

@end

@implementation KKPersonalInfoView

- (instancetype)initWithUserId:(NSString *)userId willDissmissBlock:(void(^)(void))willDissmissBlock{
    self = [super init];
    if(self){
        self.userId = userId;
        self.barStyle = [[UIApplication sharedApplication]statusBarStyle];
        self.canScroll = YES ;
        self.enableFreedomDrag = NO ;
        self.enableVerticalDrag = NO ;
        self.enableHorizonDrag = NO ;
        self.willDissmissBlock = willDissmissBlock;
    }
    return self;
}

#pragma mark -- 视图的显示和消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self initUI];
    [self loadUserInfo];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
    if(self.willDissmissBlock){
        self.willDissmissBlock();
    }
}

#pragma mark -- 初始化UI

- (void)initUI{
    self.headerViewHeight = 280 ;
    self.footerViewHeight = UIDeviceScreenHeight - self.navTitleHeight;
    
    [self.navTitleView setBackgroundColor:[[UIColor whiteColor]colorWithAlphaComponent:0]];
    [self.dragContentView insertSubview:self.tableView belowSubview:self.navTitleView];
    
    self.headerView.frame = CGRectMake(0, -self.headerViewHeight, UIDeviceScreenWidth, self.headerViewHeight);
    [self.tableView addSubview:self.headerView];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dragContentView);
        make.left.width.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(self.dragContentView);
    }];
    
    [self initNavBar];
}

#pragma mark -- 导航栏

- (void)initNavBar{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"leftbackicon_white_titlebar_24x24_"] forState:UIControlStateNormal];
    [backButton setImage:[[UIImage imageNamed:@"leftbackicon_white_titlebar_24x24_"] imageWithAlpha:0.5] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(actionForBack) forControlEvents:UIControlEventTouchUpInside];
    self.navTitleView.leftBtns = @[backButton];
    self.navTitleView.splitView.hidden = YES ;
    
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

#pragma mark -- 加载个人基本信息

- (void)loadUserInfo{
    [[KKFetchNewsTool shareInstance]fetchPersonalInfoWithUserId:self.userId success:^(KKPersonalModel *modal) {
        self.personalInfo = modal.info;
        self.headerView.userName = self.personalInfo.screen_name;
        self.headerView.headUrl = self.personalInfo.avatar_url;
        self.headerView.verified = self.personalInfo.verified_content;
        self.headerView.desc = self.personalInfo.desc;
        [self.headerView setFans:self.personalInfo.followings_count follows:self.personalInfo.followers_count];
        
        self.navAuthorView.headUrl = self.personalInfo.avatar_url;
        self.navAuthorView.name = self.personalInfo.screen_name;
        self.navAuthorView.detail = self.personalInfo.verified_content;
        
        [self.releaseView setTopicArray:self.personalInfo.topic userId:self.userId mediaId:self.personalInfo.media_id];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
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

#pragma mark -- UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.footerViewHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    [cell.contentView addSubview:self.releaseView];
    return cell ;
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
//    self.tableView.scrollEnabled = NO ;
}

- (void)dragingWithPoint:(CGPoint)pt{
//    self.tableView.scrollEnabled = NO ;
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
//    self.tableView.scrollEnabled = YES ;
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < - self.headerViewHeight) {
        CGRect frame = self.headerView.frame;
        frame.origin.y = offsetY;
        frame.size.height = -offsetY;
        self.headerView.frame = frame;
    }
    
    offsetY += self.headerViewHeight;
    
    [self setEnableScrollWithOffsetY:scrollView.contentOffset.y];
    [self setNavBarWithOffsetY:offsetY];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self setEnableScrollWithOffsetY:scrollView.contentOffset.y];
}

#pragma mark -- 设置导航栏的显示样式

- (void)setNavBarWithOffsetY:(CGFloat)offsetY{
    if(offsetY < 0){
        offsetY = 0 ;
    }
    CGFloat alpha = labs((NSInteger)offsetY) / self.navTitleHeight;
    
    self.navTitleView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:alpha];
    
    if(offsetY >= self.headerView.userHeadView.bottom - self.navTitleHeight){
        self.navAuthorView.hidden = NO ;
    }else{
        self.navAuthorView.hidden = YES ;
    }
    
    if(alpha >= 0.7){
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
        UIButton *backBtn = (UIButton *)self.navTitleView.leftBtns.firstObject;
        [backBtn setImage:[UIImage imageNamed:@"lefterbackicon_titlebar_24x24_"] forState:UIControlStateNormal];
        [backBtn setImage:[[UIImage imageNamed:@"lefterbackicon_titlebar_24x24_"] imageWithAlpha:0.5] forState:UIControlStateHighlighted];
        [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [backBtn setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    }
    if(alpha <= 0.3){
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
        UIButton *backBtn = (UIButton *)self.navTitleView.leftBtns.firstObject;
        [backBtn setImage:[UIImage imageNamed:@"leftbackicon_white_titlebar_24x24_"] forState:UIControlStateNormal];
        [backBtn setImage:[[UIImage imageNamed:@"leftbackicon_white_titlebar_24x24_"] imageWithAlpha:0.5] forState:UIControlStateHighlighted];
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    }
}

#pragma mark -- 设置ScrollView是否可以滚动

- (void)setEnableScrollWithOffsetY:(CGFloat)offsetY{
    if(!self.canScroll){
        self.tableView.contentOffset = CGPointMake(0, - self.navTitleHeight);
        return ;
    }
    if(offsetY >= - self.navTitleHeight){
        self.tableView.contentOffset = CGPointMake(0, - self.navTitleHeight);
        self.releaseView.canScroll = YES ;
    }else{
        self.releaseView.canScroll = NO ;
    }
}

#pragma mark -- @property

- (KKRecognizeSimultaneousTableView *)tableView{
    if(!_tableView){
        _tableView = ({
            KKRecognizeSimultaneousTableView *view = [[KKRecognizeSimultaneousTableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            view.separatorStyle = UITableViewCellSeparatorStyleNone;
            view.separatorInset = UIEdgeInsetsZero;
            view.layoutMargins = UIEdgeInsetsZero;
            view.contentInset = UIEdgeInsetsMake(self.headerViewHeight, 0, 0, 0);
            view.contentOffset = CGPointMake(0, -self.headerViewHeight);
            [view registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
            view.delegate = self ;
            view.dataSource = self ;
            view.tag = KKViewTagRecognizeSimultaneousTableView ;
            view.showsVerticalScrollIndicator = NO ;
            view.showsHorizontalScrollIndicator = NO ;
            view.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIDeviceScreenWidth, -1)];
            if(IOS11_OR_LATER){
                KKAdjustsScrollViewInsets(view);
            }
            view ;
        });
    }
    return _tableView;
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

- (KKPersonalInfoHeadView *)headerView{
    if(!_headerView){
        _headerView = ({
            KKPersonalInfoHeadView *view = [KKPersonalInfoHeadView new];
            
            @weakify(self);
            @weakify(view);
            [view setHeightOffsetBlock:^(CGFloat hightOffset) {
                @strongify(self);
                @strongify(view);
                self.headerViewHeight = view.height + hightOffset ;
                view.frame = CGRectMake(0, -self.headerViewHeight, UIDeviceScreenWidth, self.headerViewHeight);
                [self.tableView setContentInset:UIEdgeInsetsMake(self.headerViewHeight, 0, 0, 0)];
                [self.tableView reloadData];
            }];
            
            view ;
        });
    }
    return _headerView;
}

- (KKPersonalReleaseView *)releaseView{
    if(!_releaseView){
        _releaseView = ({
            KKPersonalReleaseView *view = [[KKPersonalReleaseView alloc]initWithTopicArray:nil userId:self.userId];
            
            @weakify(self);
            [view setCanScrollCallback:^(BOOL canScroll) {
                @strongify(self);
                self.canScroll = canScroll;
            }];
            
            view.frame = CGRectMake(0, 0, UIDeviceScreenWidth, self.footerViewHeight);
            view ;
        });
    }
    return _releaseView;
}

@end
