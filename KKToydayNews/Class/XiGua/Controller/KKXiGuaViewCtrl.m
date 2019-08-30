//
//  KKXiGuaViewCtrl.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKXiGuaViewCtrl.h"
#import "KKBaseSummaryView.h"
#import "KKSectionTopBarView.h"
#import "KKXiGuaSectionManager.h"
#import "KKNewsSummaryView.h"

@interface KKXiGuaViewCtrl ()<KKSectionTopBarViewDelegate,UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView *contentView ;
@property(nonatomic,strong)KKSectionTopBarView *sectionBarView;
@property(nonatomic,copy)NSString *preSelCatagory;
@property(nonatomic)NSMutableArray<KKBaseSummaryView *> *viewArray;
@property(nonatomic,assign)CGFloat offsetX ;
@end

@implementation KKXiGuaViewCtrl

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
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController.navigationBar setTranslucent:NO] ;
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSInteger preSelIndex = [[KKXiGuaSectionManager shareInstance]fetchIndexOfCatagory:self.preSelCatagory];
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
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.view addSubview:self.sectionBarView];
    [self.view addSubview:self.contentView];
    
    [self.sectionBarView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).mas_offset(29);
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
    [[KKXiGuaSectionManager shareInstance]fetchSectionWithComplete:^(NSArray<KKSectionItem *> *array) {
        NSInteger index = 0 ;
        for(KKSectionItem * item in array){
            KKBaseSummaryView *view = [[KKNewsSummaryView alloc]initWithSectionItem:item];
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
        
        self.sectionBarView.sectionItems = array;
        self.sectionBarView.curtSelCatagory = @"video";//默认，对应推荐标签
        
        [self refreshData];
    }];
}

#pragma mark -- 加载数据

- (void)refreshData{
    @weakify(self);
    [self.viewArray enumerateObjectsUsingBlock:^(KKBaseSummaryView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if([view.sectionItem.category isEqualToString:self.sectionBarView.curtSelCatagory]){
            [view beginPullDownUpdate];
        }
    }];
}

#pragma mark -- KKSectionBarViewDelegate

- (void)selectedSectionItem:(KKSectionItem *)item{
    NSInteger index = [[KKXiGuaSectionManager shareInstance]fetchIndexOfItem:item];
    CGPoint offset = self.contentView.contentOffset;
    offset.x = index * UIDeviceScreenWidth ;
    self.contentView.contentOffset = offset;
    
    NSInteger preSelIndex = [[KKXiGuaSectionManager shareInstance]fetchIndexOfCatagory:self.preSelCatagory];
    if(preSelIndex != index){
        KKBaseSummaryView *view = [self.viewArray safeObjectAtIndex:preSelIndex];
        [view stopVideoIfNeed];
    }
    
    KKBaseSummaryView *view = [self.viewArray safeObjectAtIndex:index];
    [view beginPullDownUpdate];
    
    self.preSelCatagory = item.category;
}

#pragma mark -- UIScrollViewDelegate

//整个滚动过程都会调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
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
    NSString *catagory = [[KKXiGuaSectionManager shareInstance]fetchCatagoryAtIndex:index];
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
    
    NSString *catagory = [[KKXiGuaSectionManager shareInstance]fetchCatagoryAtIndex:index];
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

- (KKSectionTopBarView *)sectionBarView{
    if(!_sectionBarView) {
        _sectionBarView = ({
            KKSectionTopBarView *view = [[KKSectionTopBarView alloc]init];
            view.borderThickness = 0.5;
            view.borderType = KKBorderTypeBottom;
            view.borderColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
            view.hideAddBtn = YES ;
            view.delegate = self ;
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
