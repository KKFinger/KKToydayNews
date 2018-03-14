//
//  KKProsonalSummaryView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKProsonalSummaryView.h"
#import "KKRefreshView.h"
#import "KKDongTaiNormalCell.h"
#import "KKDongTaiImageCell.h"
#import "KKDongTaiOriginalCell.h"
#import "KKPersonalModel.h"
#import "KKFetchNewsTool.h"
#import "KKArticleSmallCorverCell.h"
#import "KKArticleMiddleCorverCell.h"
#import "KKWenDaImageCell.h"
#import "KKWenDaNormalCell.h"
#import "KKNormalNewsDetailView.h"

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";
static NSString *dtNormalCellReuseIdentifier = @"dtNormalCellReuseIdentifier";
static NSString *dtImageCellReuseIdentifier = @"dtImageCellReuseIdentifier";
static NSString *dtOriginalCellReuseIdentifier = @"dtOriginalCellReuseIdentifier";
static NSString *smallCorverCellReuseIdentifier = @"smallCorverCellReuseIdentifier";
static NSString *middleCorverCellReuseIdentifier = @"middleCorverCellReuseIdentifier";
static NSString *wenDaImageCellReuseIdentifier = @"wenDaImageCellReuseIdentifier";
static NSString *wenDaNormalCellReuseIdentifier = @"wenDaNormalCellReuseIdentifier";

@interface KKProsonalSummaryView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic)UITableView *tableView;
@property(nonatomic)KKPersonalTopic *topic;
@property(nonatomic)NSMutableArray *dataSource ;
@property(nonatomic)NSString *userId;
@property(nonatomic)NSString *mediaId;
@property(nonatomic)NSString *cursor;
@end

@implementation KKProsonalSummaryView

- (instancetype)initWithTopic:(KKPersonalTopic *)topic userId:(NSString *)userId mediaId:(NSString *)mediaId{
    if(self = [super init]){
        self.topic = topic;
        self.userId = userId;
        self.mediaId = mediaId;
        [self setupUI];
        [self loadData];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.tableView];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark -- 数据加载

- (void)loadData{
    if([self.topic.type isEqualToString:@"dongtai"]){
        [[KKFetchNewsTool shareInstance]fetchPersonalDongTaiInfoWithUserId:self.userId cursor:self.cursor success:^(KKDongTaiModel *modal) {
            self.cursor = modal.dtData.max_cursor;
            if(modal.dtData.dtObjectArray.count){
                [self.dataSource addObjectsFromArray:modal.dtData.dtObjectArray];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
            });
        }];
    }else if([self.topic.type isEqualToString:@"all"] ||
             [self.topic.type isEqualToString:@"video"]){
        NSInteger pageType = 1 ;
        if([self.topic.type isEqualToString:@"video"]){
            pageType = 0 ;
        }
        [[KKFetchNewsTool shareInstance]fetchPersonalArticalWithPageType:pageType behotTime:self.cursor userId:self.userId mediaId:self.mediaId success:^(KKPersonalArticalModel *modal) {
            self.cursor = modal.next.max_behot_time;
            if(modal.summaryArray.count){
                [self.dataSource addObjectsFromArray:modal.summaryArray];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
            });
        }];
    }else if([self.topic.type isEqualToString:@"wenda"]){
        [[KKFetchNewsTool shareInstance]fetchPersonalWengDaWithUserId:self.userId cursor:self.cursor success:^(KKPersonalWenDaModel *modal) {
            self.cursor = modal.cursor;
            if(modal.answer_question.count){
                [self.dataSource addObjectsFromArray:modal.answer_question];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
            });
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView.mj_header endRefreshing];
                [self.tableView.mj_footer endRefreshing];
                [self.tableView reloadData];
            });
        }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        });
    }
}

#pragma mark -- UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.topic.type isEqualToString:@"dongtai"]){
        KKDongTaiObject *obj = [self.dataSource safeObjectAtIndex:indexPath.row];
        if(obj.group.item_id.length){
            return [KKDongTaiNormalCell fetchHeightWith:obj];
        }else{
            if(obj.origin_group.item_id.length){
                return [KKDongTaiOriginalCell fetchHeightWith:obj];
            }else{
                return [KKDongTaiImageCell fetchHeightWith:obj];
            }
        }
    }else if([self.topic.type isEqualToString:@"all"] ||
             [self.topic.type isEqualToString:@"video"]){
        KKPersonalSummary *obj = [self.dataSource safeObjectAtIndex:indexPath.row];
        if(obj.image_list.count > 1){
            return [KKArticleSmallCorverCell fetchHeightWithSummary:obj];
        }else{
            return [KKArticleMiddleCorverCell fetchHeightWithSummary:obj];
        }
    }else if([self.topic.type isEqualToString:@"wenda"]){
        KKPersonalQAModel *obj = [self.dataSource safeObjectAtIndex:indexPath.row];
        if(obj.answer.content_abstract.thumb_image_list.count){
            return [KKWenDaImageCell fetchHeightWithQAModal:obj];
        }else{
            return [KKWenDaNormalCell fetchHeightWithQAModal:obj];
        }
    }
    return 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil ;
    if([self.topic.type isEqualToString:@"dongtai"]){
        KKDongTaiObject *obj = [self.dataSource safeObjectAtIndex:indexPath.row];
        if(obj.group.item_id.length){
            cell = [tableView dequeueReusableCellWithIdentifier:dtNormalCellReuseIdentifier];
            [((KKDongTaiNormalCell *)cell) refreshWith:obj];
        }else{
            if(obj.origin_group.item_id.length){
                cell = [tableView dequeueReusableCellWithIdentifier:dtOriginalCellReuseIdentifier];
                [((KKDongTaiOriginalCell *)cell) refreshWith:obj];
            }else{
                cell = [tableView dequeueReusableCellWithIdentifier:dtImageCellReuseIdentifier];
                [((KKDongTaiImageCell *)cell) refreshWith:obj];
            }
        }
    }else if([self.topic.type isEqualToString:@"all"] ||
             [self.topic.type isEqualToString:@"video"]){
        KKPersonalSummary *obj = [self.dataSource safeObjectAtIndex:indexPath.row];
        if(obj.image_list.count > 1){
            cell = [tableView dequeueReusableCellWithIdentifier:smallCorverCellReuseIdentifier];
            [((KKArticleSmallCorverCell *)cell) refreshWithSummary:obj];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:middleCorverCellReuseIdentifier];
            [((KKArticleMiddleCorverCell *)cell) refreshWithSummary:obj];
        }
    }else if([self.topic.type isEqualToString:@"wenda"]){
        KKPersonalQAModel *obj = [self.dataSource safeObjectAtIndex:indexPath.row];
        if(obj.answer.content_abstract.thumb_image_list.count){
            cell = [tableView dequeueReusableCellWithIdentifier:wenDaImageCellReuseIdentifier];
            [((KKWenDaImageCell *)cell) refreshWithQAModal:obj];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:wenDaNormalCellReuseIdentifier];
            [((KKWenDaNormalCell *)cell) refreshWithQAModal:obj];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
        cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    }
    
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([self.topic.type isEqualToString:@"dongtai"]){
        KKDongTaiObject *obj = [self.dataSource safeObjectAtIndex:indexPath.row];
        if(obj.group.item_id.length){
            
        }else{
            if(obj.origin_group.item_id.length){
                
            }else{
                
            }
        }
    }else if([self.topic.type isEqualToString:@"all"] ||
             [self.topic.type isEqualToString:@"video"]){
        KKPersonalSummary *obj = [self.dataSource safeObjectAtIndex:indexPath.row];
        if(obj.image_list.count > 1){
            
        }else{
            
        }
    }else if([self.topic.type isEqualToString:@"wenda"]){
        KKPersonalQAModel *obj = [self.dataSource safeObjectAtIndex:indexPath.row];
        if(obj.answer.content_abstract.thumb_image_list.count){
            
        }else{
            
        }
    }else{
        
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if(!self.canScroll){
        self.tableView.contentOffset = CGPointMake(0, 0);
        return ;
    }
    if(offsetY <= 0){
        self.canScroll = NO ;
        if(self.canScrollCallback){
            self.canScrollCallback(YES);
        }
    }else{
        self.canScroll = YES ;
        if(self.canScrollCallback){
            self.canScrollCallback(NO);
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if(!self.canScroll){
        self.tableView.contentOffset = CGPointMake(0, 0);
        return ;
    }
    if(offsetY <= 0){
        self.canScroll = NO ;
        if(self.canScrollCallback){
            self.canScrollCallback(YES);
        }
    }else{
        self.canScroll = YES ;
        if(self.canScrollCallback){
            self.canScrollCallback(NO);
        }
    }
}

#pragma mark -- 一般格式的新闻详情

- (void)showNormalNewsWith:(KKSummaryContent *)item sectionItem:(KKSectionItem *)secItem{
    KKNewsBaseInfo *newsInfo = [KKNewsBaseInfo new];
    newsInfo.title = item.title;
    newsInfo.groupId = item.group_id;
    newsInfo.itemId = item.item_id;
    newsInfo.source = item.source;
    newsInfo.articalUrl = item.display_url;
    newsInfo.publicTime = item.publish_time;
    newsInfo.catagory = @"XX";
    newsInfo.commentCount = item.comment_count;
    newsInfo.userInfo = item.user_info;
    KKNormalNewsDetailView *view = [[KKNormalNewsDetailView alloc]initWithNewsBaseInfo:newsInfo];
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

#pragma mark -- @property getter

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            view.dataSource = self ;
            view.delegate = self ;
            view.showsVerticalScrollIndicator = NO ;
            view.showsHorizontalScrollIndicator = NO ;
            view.backgroundColor = KKColor(244, 245, 246, 1.0);
            view.separatorStyle = UITableViewCellSeparatorStyleNone ;
            view.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, -1)];
            if([self.topic.type isEqualToString:@"dongtai"]){
                [view registerClass:[KKDongTaiNormalCell class] forCellReuseIdentifier:dtNormalCellReuseIdentifier];
                [view registerClass:[KKDongTaiImageCell class] forCellReuseIdentifier:dtImageCellReuseIdentifier];
                [view registerClass:[KKDongTaiOriginalCell class] forCellReuseIdentifier:dtOriginalCellReuseIdentifier];
                [view setTag:KKViewTagPersonInfoDongTai];
            }else if([self.topic.type isEqualToString:@"all"] ||
                     [self.topic.type isEqualToString:@"video"]){
                [view registerClass:[KKArticleSmallCorverCell class] forCellReuseIdentifier:smallCorverCellReuseIdentifier];
                [view registerClass:[KKArticleMiddleCorverCell class] forCellReuseIdentifier:middleCorverCellReuseIdentifier];
                if([self.topic.type isEqualToString:@"all"]){
                    [view setTag:KKViewTagPersonInfoArtical];
                }else{
                    [view setTag:KKViewTagPersonInfoVideo];
                }
            }else if([self.topic.type isEqualToString:@"wenda"]){
                [view registerClass:[KKWenDaImageCell class] forCellReuseIdentifier:wenDaImageCellReuseIdentifier];
                [view registerClass:[KKWenDaNormalCell class] forCellReuseIdentifier:wenDaNormalCellReuseIdentifier];
                [view setTag:KKViewTagPersonInfoWenDa];
            }else if([self.topic.type isEqualToString:@"matrix_atricle_list"]){
                [view registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
                [view setTag:KKViewTagPersonInfoRelease];
            }else if([self.topic.type isEqualToString:@"matrix_media_list"]){
                [view registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
                [view setTag:KKViewTagPersonInfoMatrix];
            }else{
                [view registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
            }
            
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

- (NSMutableArray *)dataSource{
    if(!_dataSource){
        _dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

@end
