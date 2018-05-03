//
//  KKNormalNewsDetailView.m
//  KKToydayNews
//
//  Created by finger on 2017/8/12.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKNormalNewsDetailView.h"
#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "KKCommonDevice.h"
#import "KKLoadingView.h"
#import "KKDetialHeadView.h"
#import "KKFetchNewsTool.h"
#import "KKBottomBar.h"
#import "KKNewsCommentCell.h"
#import "KKPersonalCommentView.h"
#import "KKNewsAnalyzeTool.h"
#import "KKPersonalInfoView.h"
#import "KKShareView.h"

#define BottomBarHeight 44

static NSString *commentCellReuseable = @"commentCellReuseable";
static NSString *webViewCellReuseable = @"webViewCellReuseable";

@interface KKNormalNewsDetailView ()<WKNavigationDelegate,WKUIDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,KKAuthorInfoViewDelegate,KKBottomBarDelegate,KKCommentDelegate, UIGestureRecognizerDelegate,KKShareViewDelegate>
@property(nonatomic)UITableView *tableView;//tableView，新闻展示，第一个section加载infoWebView，第二个section加载评论
@property(nonatomic)UIScrollView *scrollView;//infoWebView的父容器，必须使用UIScrollView，否则WKWebView的内容会显示不全
@property(nonatomic)WKWebView *infoWebView;//新闻正文显示
@property(nonatomic)KKLoadingView *loadingView;//加载等待视图
@property(nonatomic)KKDetialHeadView *detialHeadView;//tableView的头部，包含了KKAuthorInfoView，用于展示作者等信息
@property(nonatomic)KKAuthorInfoView *navAuthorView;//导航栏上的作者信息
@property(nonatomic)KKBottomBar *bottomBar;//视图的底部视图，评论、转发、收藏等

@property(nonatomic)KKNewsBaseInfo *newsInfo;
@property(nonatomic,assign) UIStatusBarStyle barStyle;//用于退出新闻详情页时恢复父视图的状态栏颜色
@property(nonatomic,assign)CGFloat webViewHeight;//记录infoWebView的高度
@property(nonatomic)NSMutableArray *commentArray;//评论数组

@end

@implementation KKNormalNewsDetailView

- (instancetype)initWithNewsBaseInfo:(KKNewsBaseInfo *)newsInfo{
    self = [super init];
    if(self){
        self.topSpace = 0 ;
        self.newsInfo = newsInfo;
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
    [self.infoWebView removeObserver:self forKeyPath:@"title"];
    [self.infoWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.infoWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
    
    [self.infoWebView removeFromSuperview];
    self.infoWebView = nil ;;
}

#pragma mark -- 初始化UI

- (void)initUI{
    [self.dragContentView addSubview:self.tableView];
    [self.dragContentView insertSubview:self.loadingView aboveSubview:self.tableView];
    [self.dragContentView addSubview:self.bottomBar];
    
    self.detialHeadView.frame = CGRectMake(0, 0, UIDeviceScreenWidth, 200);
    self.tableView.tableHeaderView = self.detialHeadView;
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
    
    [self.scrollView addSubview:self.infoWebView];
    
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
    NSString *publishTime = [NSString stringIntervalSince1970RuleOne:self.newsInfo.publicTime.longLongValue];
    NSString *articleUrl = self.newsInfo.articalUrl;
    NSString *headUrl = self.newsInfo.userInfo.avatar_url;
    NSString *name = self.newsInfo.userInfo.name;
    NSString *userId = self.newsInfo.userInfo.user_id;
    
    self.detialHeadView.authorView.detail = [NSString stringWithFormat:@"%@  %@",publishTime,self.newsInfo.source];
    self.detialHeadView.title = self.newsInfo.title;
    self.detialHeadView.authorView.headUrl = headUrl;
    self.detialHeadView.authorView.name = name;
    self.detialHeadView.authorView.isConcern = NO ;
    self.detialHeadView.authorView.userId = userId;
    
    self.navAuthorView.name = name;
    self.navAuthorView.headUrl = headUrl;
    self.navAuthorView.isConcern = NO ;
    self.navAuthorView.userId = userId;
    
    self.bottomBar.commentCount = [self.newsInfo.commentCount integerValue];
    
    //不能直接使用文章的url来展示新闻，需要进一步解析新闻的正文
    [KKNewsAnalyzeTool fetchHtmlStringWithUrl:articleUrl complete:^(NSString *htmlString) {
        [self loadWebWithHtmlString:htmlString baseUrl:nil];
    }];
    [self loadCommentData];
}

#pragma mark -- 加载评论

- (void)loadCommentData{
    [[KKFetchNewsTool shareInstance]fetchCommentWithCatagory:self.newsInfo.catagory groupId:self.newsInfo.groupId itemId:self.newsInfo.itemId offset:self.commentArray.count sortIndex:0 success:^(KKCommentModal *model){
        if(model.commentArray.count){
            [self.commentArray addObjectsFromArray:model.commentArray];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
            //[self.loadingView setHidden:self.commentArray.count];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
            //[self.loadingView setHidden:self.commentArray.count];
        });
    }];
}

#pragma mark -- UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 1;
    }
    return self.commentArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return self.webViewHeight ;
    }
    KKCommentItem *item = [self.commentArray safeObjectAtIndex:indexPath.row];
    return [KKNewsCommentCell fetchHeightWithItem:item] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    if(indexPath.section == 0){
        cell = [tableView dequeueReusableCellWithIdentifier:webViewCellReuseable];
        [cell.contentView addSubview:self.scrollView];
    }else{
        KKCommentItem *item = [self.commentArray safeObjectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:commentCellReuseable];
        [((KKNewsCommentCell *)cell) refreshWithItem:item];
        [((KKNewsCommentCell *)cell) setDelegate:self];
    }
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    KKCommentItem *item = [self.commentArray safeObjectAtIndex:indexPath.row];
    [self showPersonalCommentWithId:item.comment.Id];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 30;
}

#pragma mark -- 显示个人评论详情视图

- (void)showPersonalCommentWithId:(NSString *)commentId{
    KKPersonalCommentView *view = [[KKPersonalCommentView alloc]initWithCommentId:commentId];
    view.topSpace = KKStatusBarHeight;
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

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if(offsetY >= self.detialHeadView.height){
        self.navAuthorView.hidden = NO ;
    }else{
        self.navAuthorView.hidden = YES ;
    }
}

#pragma mark -- KKAuthorInfoViewDelegate

- (void)setConcern:(BOOL)isConcern callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)clickedUserHeadWithUserId:(NSString *)userId{
    [self jumpToUserPage:userId];
}

#pragma mark -- KKBottomBarDelegate

- (void)sendCommentWidthText:(NSString *)text{
    NSLog(@"%@",text);
}

- (void)showCommentView{
    CGPoint pt = self.tableView.contentOffset;
    pt.y = self.webViewHeight;
    [self.tableView setContentOffset:pt animated:YES];
}

- (void)favoriteNews:(BOOL)isFavorite callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)shareNews{
    KKShareView *view = [KKShareView new];
    view.shareInfos = [self createShareItems];
    view.frame = [[UIScreen mainScreen]bounds];
    view.delegate = self ;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view showShareView];
}

#pragma mark -- 创建更多视图的item

- (NSArray<NSArray<KKShareItem *> *> *)createShareItems{
    KKShareItem *itemWTT = [[KKShareItem alloc]initWithShareType:KKShareTypeWeiTouTiao iconImageName:@"bespoke_editLive_n" title:@"微头条"];
    KKShareItem *itemWX = [[KKShareItem alloc]initWithShareType:KKShareTypeWXFriend iconImageName:@"bespoke_weixin_n" title:@"微信"];
    KKShareItem *itemTime = [[KKShareItem alloc]initWithShareType:KKShareTypeWXTimesmp iconImageName:@"bespoke_pengyouquan_n" title:@"朋友圈"];
    KKShareItem *itemWeiBo = [[KKShareItem alloc]initWithShareType:KKShareTypeWeiBo iconImageName:@"bespoke_weibo_n" title:@"微博"];
    KKShareItem *itemQQ = [[KKShareItem alloc]initWithShareType:KKShareTypeQQ iconImageName:@"bespoke_qq_n" title:@"QQ"];
    KKShareItem *itemQZone = [[KKShareItem alloc]initWithShareType:KKShareTypeQZone iconImageName:@"bespoke_qzone_n" title:@"QZone"];
    KKShareItem *itemSys = [[KKShareItem alloc]initWithShareType:KKShareTypeSysShare iconImageName:@"bespoke_editLive_n" title:@"系统分享"];
    KKShareItem *itemMsg = [[KKShareItem alloc]initWithShareType:KKShareTypeMessage iconImageName:@"bespoke_editLive_n" title:@"短信"];
    KKShareItem *itemEmail = [[KKShareItem alloc]initWithShareType:KKShareTypeEmail iconImageName:@"bespoke_editLive_n" title:@"邮件"];
    KKShareItem *itemCopyLink = [[KKShareItem alloc]initWithShareType:KKShareTypeCopyLink iconImageName:@"bespoke_editLive_n" title:@"复制链接"];
    
    NSArray *array1 =@[itemWTT,itemWX,itemTime,itemWeiBo,itemQQ,itemQZone];
    NSArray *array2 =@[itemSys,itemMsg,itemEmail,itemCopyLink];
    
    return @[array1,array2];
}

#pragma mark -- KKShareViewDelegate

- (void)shareWithType:(KKShareType)shareType{
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

- (void)reportUser:(NSString *)userId{
    NSLog(@"userId:%@",userId);
}

#pragma mark-- UIWebView Delegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [self.tableView setHidden:YES] ;
    [self.loadingView setHidden:NO];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self.tableView setHidden:NO];
    [self.loadingView setHidden:YES];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"加载页面失败");
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
}

// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    decisionHandler(YES);
}

// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if(webView != self.infoWebView) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    //WKWebView默认屏蔽了外部的跳转，需要手动开启
    
    NSURL *url = navigationAction.request.URL;
    
    UIApplication *app = [UIApplication sharedApplication];
    
    if ([url.absoluteString containsString:@"itunes.apple.com"]){
        if ([app canOpenURL:url]){
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark -- 视图弹出

- (void)actionForBack{
    if (self.infoWebView.canGoBack) {
        [self.infoWebView goBack];
    }else{
        if (self.showViewType == KKShowViewTypePush) {
            [self pushOutToRight:YES];
        } else if (self.showViewType == KKShowViewTypePopup){
            [self popOutToTop:NO];
        }else {
            [self startHide];
        }
    }
    //跳转
    /*if (infoWebView.backForwardList.backList.count > 2) {
     [infoWebView goToBackForwardListItem:infoWebView.backForwardList.backList[0]];
     }*/
}

#pragma mark -- KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentSize"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        self.webViewHeight = scrollView.contentSize.height;
        self.infoWebView.frame = CGRectMake(0, 0, UIDeviceScreenWidth, self.webViewHeight);
        self.scrollView.frame = CGRectMake(0, 0, UIDeviceScreenWidth, self.webViewHeight);
        self.scrollView.contentSize = CGSizeMake(UIDeviceScreenWidth, self.webViewHeight);
        [self.tableView reloadData];
    }else if ([keyPath isEqualToString:@"title"]){
    }else if ([keyPath isEqualToString:@"estimatedProgress"]) {
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -- 网页加载

-(void)loadWebWithUrl:(NSString*)url{
    if(!url.length){
        return ;
    }
    if([[KKCommonDevice systemVersion]floatValue] >= 9){
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
                [self.infoWebView loadRequest:request];
            }];
        });
    }else{
        NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                   NSUserDomainMask, YES)[0];
        NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleIdentifier"];
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
        NSString *webKitFolderInCaches = [NSString
                                          stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
        NSString *webKitFolderInCachesfs = [NSString
                                            stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
        
        NSError *error;
        /* iOS8.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
        
        /* iOS7.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
        [self.infoWebView loadRequest:request];
    }
}

- (void)loadWebWithHtmlString:(NSString *)htmlString baseUrl:(NSURL *)baseUrl{
    if(!htmlString.length){
        return ;
    }
    if([[KKCommonDevice systemVersion]floatValue] >= 9){
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.infoWebView loadHTMLString:htmlString baseURL:baseUrl];
                });
            }];
        });
    }else{
        NSString *libraryDir = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                                   NSUserDomainMask, YES)[0];
        NSString *bundleId  =  [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleIdentifier"];
        NSString *webkitFolderInLib = [NSString stringWithFormat:@"%@/WebKit",libraryDir];
        NSString *webKitFolderInCaches = [NSString
                                          stringWithFormat:@"%@/Caches/%@/WebKit",libraryDir,bundleId];
        NSString *webKitFolderInCachesfs = [NSString
                                            stringWithFormat:@"%@/Caches/%@/fsCachedData",libraryDir,bundleId];
        
        NSError *error;
        /* iOS8.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCaches error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:webkitFolderInLib error:nil];
        
        /* iOS7.0 WebView Cache的存放路径 */
        [[NSFileManager defaultManager] removeItemAtPath:webKitFolderInCachesfs error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.infoWebView loadHTMLString:htmlString baseURL:baseUrl];
        });
    }
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
    
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.tableView.scrollEnabled = NO ;
    self.infoWebView.scrollView.scrollEnabled = NO ;
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    self.tableView.scrollEnabled = YES ;
    self.infoWebView.scrollView.scrollEnabled = YES ;
}

#pragma mark -- 处理isSecureTextEntry崩溃问题

- (void)progressWKContentViewCrash{
    if (([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)) {
        const char *className = @"WKContentView".UTF8String;
        Class WKContentViewClass = objc_getClass(className);
        SEL isSecureTextEntry = NSSelectorFromString(@"isSecureTextEntry");
        SEL secureTextEntry = NSSelectorFromString(@"secureTextEntry");
        BOOL addIsSecureTextEntry = class_addMethod(WKContentViewClass, isSecureTextEntry, (IMP)isSecureTextEntryIMP, "B@:");
        BOOL addSecureTextEntry = class_addMethod(WKContentViewClass, secureTextEntry, (IMP)secureTextEntryIMP, "B@:");
        if (!addIsSecureTextEntry || !addSecureTextEntry) {
            NSLog(@"WKContentView-Crash->修复失败");
        }
    }
}

/**
 实现WKContentView对象isSecureTextEntry方法
 @return NO
 */
BOOL isSecureTextEntryIMP(id sender, SEL cmd) {
    return NO;
}

/**
 实现WKContentView对象secureTextEntry方法
 @return NO
 */
BOOL secureTextEntryIMP(id sender, SEL cmd) {
    return NO;
}

#pragma mark -- @property

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            view.delegate = self;
            view.dataSource = self ;
            view.hidden = YES ;
            view.backgroundColor = [UIColor whiteColor];
            [view registerClass:[KKNewsCommentCell class] forCellReuseIdentifier:commentCellReuseable];
            [view registerClass:[UITableViewCell class] forCellReuseIdentifier:webViewCellReuseable];
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

- (WKWebView *)infoWebView{
    if(!_infoWebView){
        _infoWebView = ({
            WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
            WKUserContentController *wkUController = [[WKUserContentController alloc] init];
            // 自适应屏幕宽度js、禁止缩放
            NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width,initial-scale=1.0,maximum-scale=1.0,minimum-scale=1.0,user-scalable=no');\
            document.getElementsByTagName('head')[0].appendChild(meta);";
            WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
            // 添加js调用
            [wkUController addUserScript:wkUserScript];
            
            wkWebConfig.userContentController = wkUController;
            wkWebConfig.suppressesIncrementalRendering = YES;
            if([[[UIDevice currentDevice]systemVersion]floatValue] >= 9.0){
                wkWebConfig.allowsAirPlayForMediaPlayback = YES;
            }
            wkWebConfig.allowsInlineMediaPlayback = YES;
            wkWebConfig.selectionGranularity = YES;
            
            //设置userAgent
            WKWebView *view = [[WKWebView alloc] initWithFrame:CGRectZero configuration:wkWebConfig];
            view.allowsBackForwardNavigationGestures = YES;
            view.userInteractionEnabled = YES ;
            view.scrollView.delegate = self ;
            view.scrollView.bounces = NO ;
            view.backgroundColor = [UIColor whiteColor];
            view.navigationDelegate = self ;
            view.opaque = NO ;
            view.UIDelegate = self ;
            [view addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
            [view addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
            [view.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            [view sizeToFit];
            view ;
        });
    }
    return _infoWebView;
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

-(UIScrollView *)scrollView{
    if(!_scrollView){
        _scrollView = ({
            UIScrollView *view = [UIScrollView new];
            view.showsVerticalScrollIndicator = NO ;
            view.showsHorizontalScrollIndicator = NO ;
            view.bounces = NO ;
            view.delegate = self ;
            view ;
        });
    }
    return _scrollView;
}

- (KKDetialHeadView *)detialHeadView{
    if(!_detialHeadView){
        _detialHeadView = ({
            KKDetialHeadView *view = [KKDetialHeadView new];
            view.authorView.delegate = self;
            
            @weakify(view);
            [view setShouldAdjustHeight:^(CGFloat height){
                @strongify(view);
                view.frame = CGRectMake(0, 0, UIDeviceScreenWidth, height);
            }];
            
            view ;
        });
    }
    return _detialHeadView;
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

- (NSMutableArray *)commentArray{
    if(!_commentArray){
        _commentArray = [NSMutableArray new];
    }
    return _commentArray;
}

@end
