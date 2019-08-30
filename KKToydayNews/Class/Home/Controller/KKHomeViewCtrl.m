//
//  KKHomeViewCtrl.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKHomeViewCtrl.h"
#import "KKSectionTopBarView.h"
#import "KKSearchBar.h"
#import "KKSectionPanelView.h"
#import "KKNewsSummaryView.h"
#import "KKFetchNewsTool.h"
#import "KKHomeSectionManager.h"
#import "KKXiaoShiPingSummaryView.h"
#import "KKNavTitleView.h"
#import "KKUserCenterView.h"
#import "KKThirdTools.h"

@interface KKHomeViewCtrl ()<UISearchBarDelegate,KKSectionTopBarViewDelegate,UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView *contentView ;
@property(nonatomic,strong)UIImageView *headView;//导航栏左侧的头像
@property(nonatomic,strong)KKSearchBar *searchBar ;
@property(nonatomic,strong)KKNavTitleView *navTitleView;
@property(nonatomic,strong)KKSectionTopBarView *sectionBarView;
@property(nonatomic,copy)NSString *preSelCatagory;
@property(nonatomic)NSMutableArray<KKBaseSummaryView *> *viewArray;
@property(nonatomic,assign)CGFloat offsetX ;
@end

@implementation KKHomeViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setupNewsCatagorys];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[[SDWebImageManager sharedManager]imageCache]clearMemory];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSInteger preSelIndex = [[KKHomeSectionManager shareInstance]fetchIndexOfCatagory:self.preSelCatagory];
    KKBaseSummaryView *view = [self.viewArray safeObjectAtIndex:preSelIndex];
    [view stopVideoIfNeed];
}

#pragma mark -- 视频播放器，屏幕旋转相关

- (BOOL)shouldAutorotate{
    return NO ;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.view addSubview:self.navTitleView];
    [self.view addSubview:self.sectionBarView];
    [self.view addSubview:self.contentView];
    
    [self setupNavBar];
    [self.navTitleView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(KKNavBarHeight);
    }];
    
    [self.sectionBarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.right.mas_equalTo(self.view);
        make.height.mas_equalTo(35);
    }];
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sectionBarView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark -- 初始化新闻频道

- (void)setupNewsCatagorys{
    [[KKHomeSectionManager shareInstance]fetchFavSectionWithComplete:^(NSArray<KKSectionItem *> *array) {
        if(!array.count){
            return  ;
        }
        for(KKBaseSummaryView *view in self.viewArray){
            [view stopVideoIfNeed];
            [view removeFromSuperview];
        }
        [self.viewArray removeAllObjects];
        
        for(UIView *view in self.contentView.subviews){
            if([view isKindOfClass:[KKBaseSummaryView class]]){
                [(KKBaseSummaryView *)view stopVideoIfNeed];
                [view removeFromSuperview];
            }
        }
        
        NSInteger index = 0 ;
        for(KKSectionItem * item in array){
            KKBaseSummaryView *view = [[KKNewsSummaryView alloc]initWithSectionItem:item];
            if([item.category isEqualToString:@"hotsoon_video"]){
                view = [[KKXiaoShiPingSummaryView alloc]initWithSectionItem:item];
            }
            [view setParentCtrl:self];
            
            [self.viewArray addObject:view];
            [self.contentView addSubview:view];
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.contentView).mas_offset(index * UIDeviceScreenWidth);
                make.top.mas_equalTo(self.contentView);
                make.width.height.mas_equalTo(self.contentView);
            }];
            index ++ ;
        }
        self.contentView.contentSize = CGSizeMake(array.count * UIDeviceScreenWidth,0);
        
        self.sectionBarView.sectionItems = array ;
        self.sectionBarView.curtSelCatagory = array.firstObject.category;
        //self.sectionBarView.curtSelCatagory = @"推荐";
        
        [self refreshData];
        
    }];
}

#pragma mark -- 初始化导航栏

- (void)setupNavBar{
    [self.headView setSize:CGSizeMake(27, 27)];
    [self.headView setCornerImageWithURL:[NSURL URLWithString:@""] placeholder:[UIImage imageNamed:@"userHead"]];
    self.navTitleView.leftBtns = @[self.headView];
    
    self.searchBar.frame = CGRectMake(50, 0, UIDeviceScreenWidth - 60, 27);
    self.navTitleView.titleView = self.searchBar;
}

#pragma mark -- 加载数据

- (void)refreshData{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @weakify(self);
        [self.viewArray enumerateObjectsUsingBlock:^(KKBaseSummaryView *view, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            if([view.sectionItem.category isEqualToString:self.sectionBarView.curtSelCatagory]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [view beginPullDownUpdate];
                });
                *stop = YES ;
            }
        }];
    });
}

#pragma mark -- KKSectionBarViewDelegate

- (void)selectedSectionItem:(KKSectionItem *)item{
    NSInteger index = [[KKHomeSectionManager shareInstance]fetchIndexOfItem:item];
    CGPoint offset = self.contentView.contentOffset;
    offset.x = index * UIDeviceScreenWidth ;
    self.contentView.contentOffset = offset;
    
    NSInteger preSelIndex = [[KKHomeSectionManager shareInstance]fetchIndexOfCatagory:self.preSelCatagory];
    if(preSelIndex != index){
        KKBaseSummaryView *view = [self.viewArray safeObjectAtIndex:preSelIndex];
        [view stopVideoIfNeed];
    }
    
    KKBaseSummaryView *view = [self.viewArray safeObjectAtIndex:index];
    [view beginPullDownUpdate];
    
    self.preSelCatagory = item.category;
}

- (void)addMoreSectionClicked{
    KKSectionPanelView *pannelView = [[KKSectionPanelView alloc]init];
    pannelView.topSpace = KKStatusBarHeight;
    pannelView.contentViewCornerRadius = 10 ;
    pannelView.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;

    @weakify(self);
    @weakify(pannelView);

    [pannelView setCloseHandler:^(BOOL sectionDataChanged){
        @strongify(pannelView);
        if(sectionDataChanged){
            [[KKHomeSectionManager shareInstance]updateFavoriteSection];
        }
        [pannelView removeFromSuperview];
        pannelView = nil ;
    }];

    [pannelView setJumpToViewByItemHandler:^(KKSectionItem *item,BOOL sectionDataChanged) {
        @strongify(pannelView);
        @strongify(self);
        if(sectionDataChanged){
            [[KKHomeSectionManager shareInstance]updateFavoriteSection];
        }
        [pannelView startHide];
        [self.sectionBarView setCurtSelCatagory:item.category];
        //滚动至相应的位置
        NSInteger index = [[KKHomeSectionManager shareInstance]fetchIndexOfCatagory:item.category];
        CGPoint offset = self.contentView.contentOffset;
        offset.x = index * UIDeviceScreenWidth ;
        self.contentView.contentOffset = offset;

        NSInteger preSelIndex = [[KKHomeSectionManager shareInstance]fetchIndexOfCatagory:self.preSelCatagory];
        if(preSelIndex != index){
            KKBaseSummaryView *view = [self.viewArray safeObjectAtIndex:preSelIndex];
            [view stopVideoIfNeed];
        }

        KKBaseSummaryView *view = [self.viewArray safeObjectAtIndex:index];
        [view beginPullDownUpdate];

        self.preSelCatagory = item.category;
    }];

    [pannelView setUserSectionOrderChangeHandler:^(NSInteger fromIndex,NSInteger  toIndex){
        @strongify(self);
        self.sectionBarView.sectionItems = [[KKHomeSectionManager shareInstance] getFavoriteSection];
        self.contentView.contentSize = CGSizeMake([[KKHomeSectionManager shareInstance]getFavoriteCount] * UIDeviceScreenWidth,0);

        //交换View，重新布局视图
        NSInteger subViewIndex = 0 ;
        KKBaseSummaryView *view = [self.viewArray objectAtIndex:fromIndex];
        [self.viewArray removeObjectAtIndex:fromIndex];
        [self.viewArray insertObject:view atIndex:toIndex];
        for(KKBaseSummaryView *view in self.viewArray){
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.contentView).mas_offset(subViewIndex * UIDeviceScreenWidth);
            }];
            subViewIndex ++ ;
        }

        //滚动至相应的位置
        NSString *catagory = self.sectionBarView.curtSelCatagory;
        NSInteger index = [[KKHomeSectionManager shareInstance]fetchIndexOfCatagory:catagory];
        CGPoint offset = self.contentView.contentOffset;
        offset.x = index * UIDeviceScreenWidth ;
        self.contentView.contentOffset = offset;
    }];

    [pannelView setAddOrRemoveSectionHandler:^(KKSectionOpType opType, KKSectionItem *item){
        @strongify(self);
        self.sectionBarView.sectionItems = [[KKHomeSectionManager shareInstance] getFavoriteSection];
        self.contentView.contentSize = CGSizeMake([[KKHomeSectionManager shareInstance]getFavoriteCount] * UIDeviceScreenWidth,0);
        if(opType == KKSectionOpTypeAddToFavSection){
            KKBaseSummaryView *view = [[KKNewsSummaryView alloc]initWithSectionItem:item];
            if([item.category isEqualToString:@"hotsoon_video"]){
                view = [[KKXiaoShiPingSummaryView alloc]initWithSectionItem:item];
            }
            [view setParentCtrl:self];

            [self.viewArray addObject:view];
            [self.contentView addSubview:view];
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.contentView).mas_offset((self.viewArray.count - 1) * UIDeviceScreenWidth);
                make.top.mas_equalTo(self.contentView);
                make.width.height.mas_equalTo(self.contentView);
            }];
        }else if(opType == KKSectionOpTypeRemoveFromFavSection){
            for(KKBaseSummaryView *view in self.viewArray){
                if([view.sectionItem.category isEqualToString:item.category]){
                    [view removeFromSuperview];
                    [self.viewArray removeObject:view];
                    break ;
                }
            }
            //重新布局视图
            NSInteger subViewIndex = 0 ;
            for(KKBaseSummaryView *view in self.viewArray){
                [view mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(self.contentView).mas_offset(subViewIndex * UIDeviceScreenWidth);
                }];
                subViewIndex ++ ;
            }

            NSString *catagory = self.sectionBarView.curtSelCatagory;
            if([catagory isEqualToString:item.category]){
                /*catagory = @"推荐" ;
                self.sectionBarView.curtSelCatagory = catagory;*/
                self.sectionBarView.curtSelCatagory = self.sectionBarView.sectionItems.firstObject.category;
            }
            //滚动至相应的位置
            NSInteger index = [[KKHomeSectionManager shareInstance]fetchIndexOfCatagory:catagory];
            CGPoint offset = self.contentView.contentOffset;
            offset.x = index * UIDeviceScreenWidth ;
            self.contentView.contentOffset = offset;
        }
    }];
    pannelView.curtSelCatagory = self.sectionBarView.curtSelCatagory;

    [[UIApplication sharedApplication].keyWindow addSubview:pannelView];
    [pannelView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [pannelView startShow];
}

#pragma mark -- UIScrollViewDelegate

//整个滚动过程都会调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CGPoint offset = scrollView.contentOffset;
//    CGFloat progress = offset.x / (CGFloat)UIDeviceScreenWidth;
//    
//    BOOL toRoght = YES ;
//    if(offset.x < self.offsetX){
//        toRoght = NO ;
//    }
//    self.offsetX = offset.x;
//    
//    [self.sectionBarView scrollToRight:toRoght percent:progress];
}

//开始拉拽视图
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.preSelCatagory = self.sectionBarView.curtSelCatagory;
}

//拉拽视图结束结束
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
}

//结束拉拽视图
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGPoint offset = scrollView.contentOffset;
    NSInteger index = (offset.x + UIDeviceScreenWidth /2 ) / UIDeviceScreenWidth;
    if(index < 0 || index >= self.sectionBarView.sectionItems.count){
        return ;
    }
    NSString *catagory = [[KKHomeSectionManager shareInstance]fetchCatagoryAtIndex:index];
    self.sectionBarView.curtSelCatagory = catagory ;
}

//即将停止滚动
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
}

//完全停止滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    NSInteger index = offset.x / UIDeviceScreenWidth;
    self.offsetX = 0 ;
    if(index < 0 || index >= self.sectionBarView.sectionItems.count){
        return ;
    }
    
    NSString *catagory = [[KKHomeSectionManager shareInstance]fetchCatagoryAtIndex:index];
    self.sectionBarView.curtSelCatagory = catagory ;
    
    if(![self.preSelCatagory isEqualToString:catagory]){
        @weakify(self);
        [self.viewArray enumerateObjectsUsingBlock:^(KKBaseSummaryView *view, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            if([view.sectionItem.category isEqualToString:self.sectionBarView.curtSelCatagory]){
                if(!view.dataArray.count){
                    [view beginPullDownUpdate];
                }
            }
            [view stopVideoIfNeed];
        }];
    }
}

#pragma mark -- @property getter & setter

- (UIScrollView *)contentView{
    if(!_contentView){
        _contentView = ({
            UIScrollView *view = [[UIScrollView alloc]init];
            view.showsVerticalScrollIndicator = NO ;
            view.showsHorizontalScrollIndicator = NO ;
            view.backgroundColor = [UIColor clearColor];
            view.delegate = self;
            view.scrollEnabled = YES ;
            view.pagingEnabled = YES ;
            view;
        });
    }
    return _contentView;
}

- (KKSearchBar *)searchBar{
    if(!_searchBar){
        _searchBar = ({
            KKSearchBar *view = [[KKSearchBar alloc]init];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.masksToBounds = YES ;
            view.layer.cornerRadius = 5 ;
            view;
        });
    }
    return _searchBar;
}

- (KKNavTitleView *)navTitleView{
    if(!_navTitleView){
        _navTitleView = ({
            KKNavTitleView *view = [KKNavTitleView new];
            view.contentOffsetY = 10 ;
            view.backgroundColor = KKColor(212, 60, 61, 1.0);
            view ;
        });
    }
    return _navTitleView;
}

- (UIImageView *)headView{
    if(!_headView){
        _headView = ({
            UIImageView *view = [[UIImageView alloc]init];
            view.layer.masksToBounds =  YES ;
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.userInteractionEnabled = YES ;
            
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                KKUserCenterView *centerView = [KKUserCenterView new];
                centerView.topSpace = 0 ;
                centerView.enableFreedomDrag = NO ;
                centerView.enableVerticalDrag = NO ;
                centerView.enableHorizonDrag = YES ;

                [[UIApplication sharedApplication].keyWindow addSubview:centerView];
                [centerView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.top.mas_equalTo(0);
                    make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
                }];
                [centerView pushIn];
            }];
            
            view;
        });
    }
    return _headView;
}

- (KKSectionTopBarView *)sectionBarView{
    if(!_sectionBarView) {
        _sectionBarView = ({
            KKSectionTopBarView *view = [[KKSectionTopBarView alloc]init];
            view.delegate = self ;
            view.borderColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
            view.borderThickness = 0.5;
            view.borderType = KKBorderTypeTop | KKBorderTypeBottom;
            view ;
        });
    }
    return _sectionBarView;
}

- (NSMutableArray *)viewArray{
    if(!_viewArray){
        _viewArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _viewArray;
}

@end
