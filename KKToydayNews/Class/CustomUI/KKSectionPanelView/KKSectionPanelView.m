//
//  KKSectionPanelView.m
//  KKToydayNews
//
//  Created by finger on 2017/8/8.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKSectionPanelView.h"
#import "KKSectionHeaderView.h"
#import "KKSectionGroupView.h"

@interface KKSectionPanelView()<KKSectionGroupViewDelegate,UIScrollViewDelegate>
@property(nonatomic,strong)UIButton *closeBtn ;
@property(nonatomic,strong)UIView *splitView ;
@property(nonatomic,strong)UIScrollView *sectionContentView ;//板块部分视图
@property(nonatomic,strong)KKSectionHeaderView *headerView1;//已选择的板块头部
@property(nonatomic,strong)KKSectionHeaderView *headerView2;//推荐的板块头部
@property(nonatomic,strong)KKSectionGroupView *favSectionView ;
@property(nonatomic,strong)KKSectionGroupView *recommonSectionView ;

@property(nonatomic,assign)BOOL sectionDataChanged;

@end

@implementation KKSectionPanelView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
        [self bandingEvent];
    }
    return self ;
}

#pragma mark -- 视图显示/消失

- (void)viewDidAppear{
    self.sectionContentView.contentSize = CGSizeMake(UIDeviceScreenWidth, self.recommonSectionView.bottom + 180);
}

- (void)viewDidDisappear{
    if(self.closeHandler){
        self.closeHandler(self.sectionDataChanged);
    }
}

#pragma mark -- 初始化UI

- (void)setupUI{
    self.backgroundColor = [UIColor clearColor];
    self.topSpace = KKStatusBarHeight;
    
    [self.dragContentView addSubview:self.closeBtn];
    [self.dragContentView addSubview:self.splitView];
    [self.dragContentView insertSubview:self.sectionContentView belowSubview:self.splitView];
    [self.sectionContentView addSubview:self.headerView1];
    [self.sectionContentView addSubview:self.favSectionView];
    [self.sectionContentView addSubview:self.headerView2];
    [self.sectionContentView addSubview:self.recommonSectionView];
    
    [self.closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dragContentView).mas_offset(10);
        make.left.mas_equalTo(self.dragContentView).mas_offset(5);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.closeBtn.mas_bottom).mas_offset(10);
        make.left.right.mas_equalTo(self.dragContentView).priority(998);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, 0.6));
    }];
    
    [self.sectionContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.splitView.mas_bottom);
        make.left.right.mas_equalTo(self.dragContentView).priority(998);
        make.width.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(self.dragContentView);
    }];
    
    [self.headerView1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sectionContentView);
        make.top.mas_equalTo(self.sectionContentView);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(self.sectionContentView);
    }];
    
    [self.favSectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView1.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(self.sectionContentView);
        make.width.mas_equalTo(self.sectionContentView.mas_width);
        make.height.mas_equalTo(0);
    }];
    
    [self.headerView2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sectionContentView);
        make.top.mas_equalTo(self.favSectionView.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(self.sectionContentView);
    }];
    
    [self.recommonSectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView2.mas_bottom).mas_offset(5).priority(998);
        make.left.mas_equalTo(self.sectionContentView);
        make.width.mas_equalTo(self.sectionContentView.mas_width);
        make.height.mas_equalTo(0);
    }];
}

#pragma mark -- 事件绑定

- (void)bandingEvent{
    [self.closeBtn addTarget:self action:@selector(startHide) forControlEvents:UIControlEventTouchUpInside];
    
    @weakify(self);
    [self.headerView1 setEnditBtnClickHandler:^(BOOL isEdit){
        @strongify(self);
        self.favSectionView.isEditState = isEdit;
    }];
}

#pragma mark -- KKSectionGroupViewDelegate

- (void)longPressArise{
    self.headerView1.isEdit = YES ;
}

- (void)addOrRemoveItem:(KKSectionItem *)item itemOrgRect:(CGRect)rect opType:(KKSectionOpType)opType{
    
    self.sectionDataChanged = YES ;
    
    if(opType == KKSectionOpTypeAddToFavSection){
        CGRect frame = [self.recommonSectionView convertRect:rect toView:self.favSectionView];
        [self.favSectionView addItemAtIndex:-1 item:item initRect:frame animate:YES];
    }else if(opType == KKSectionOpTypeRemoveFromFavSection){
        CGRect frame = [self.favSectionView convertRect:rect toView:self.recommonSectionView];
        [self.recommonSectionView addItemAtIndex:0 item:item initRect:frame animate:YES];
    }
    
    if(self.addOrRemoveSectionHandler){
        self.addOrRemoveSectionHandler(opType,item);
    }
    
    NSInteger height = [self.favSectionView calculateViewHeight];
    [self.favSectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [self.headerView2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.favSectionView.mas_bottom).mas_offset(5);
    }];
    
    height = [self.recommonSectionView calculateViewHeight];
    [self.recommonSectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.dragContentView layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.sectionContentView.contentSize = CGSizeMake(UIDeviceScreenWidth, self.recommonSectionView.bottom + 180);
    }];
}

- (void)needJumpToSection:(KKSectionItem *)item{
    if(self.jumpToViewByItemHandler){
        self.jumpToViewByItemHandler(item,self.sectionDataChanged);
    }
}

- (void)userSectionOrderChangeFrom:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    self.sectionDataChanged = YES ;
    if(self.userSectionOrderChangeHandler){
        self.userSectionOrderChangeHandler(fromIndex,toIndex);
    }
}

- (void)needAdjustView:(KKSectionGroupView *)view height:(CGFloat)height{
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [view layoutIfNeeded];
    
    self.sectionContentView.contentSize = CGSizeMake(UIDeviceScreenWidth, self.recommonSectionView.bottom + 180);
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint offset = scrollView.contentOffset;
    
    self.splitView.alpha = offset.y > 0 ? 1.0 :0.0 ;
    
    if(offset.y < 0 ){
        offset.y = 0 ;
        scrollView.contentOffset = offset ;
    }
}

#pragma mark -- 开始、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.sectionContentView.scrollEnabled = NO ;
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    self.sectionContentView.scrollEnabled = YES ;
}

#pragma mark -- @property

- (void)setCurtSelCatagory:(NSString *)curtSelCatagory{
    _curtSelCatagory = curtSelCatagory ;
    self.favSectionView.curtSelCatagory = curtSelCatagory ;
}

- (UIScrollView *)sectionContentView{
    if(!_sectionContentView){
        _sectionContentView = ({
            UIScrollView *view = [[UIScrollView alloc]init];
            view.scrollEnabled = YES ;
            view.delegate = self ;
            view.showsVerticalScrollIndicator = NO ;
            view.showsHorizontalScrollIndicator = NO ;
            view ;
        });
    }
    return _sectionContentView;
}

- (UIButton *)closeBtn{
    if(!_closeBtn){
        _closeBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"button_close"] forState:UIControlStateNormal];
            view ;
        });
    }
    return _closeBtn ;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [[UIView alloc]init];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.1];
            view.alpha = 0.0 ;
            view ;
        });
    }
    return _splitView;
}

- (KKSectionHeaderView *)headerView1{
    if(!_headerView1){
        _headerView1 = ({
            KKSectionHeaderView *view = [[KKSectionHeaderView alloc]init];
            view.titleText = @"我的频道";
            view.detailText = @"点击进入频道";
            view.hiddenEditBtn = NO ;
            view ;
        });
    }
    return _headerView1 ;
}

- (KKSectionHeaderView *)headerView2{
    if(!_headerView2){
        _headerView2 = ({
            KKSectionHeaderView *view = [[KKSectionHeaderView alloc]init];
            view.titleText = @"频道推荐";
            view.detailText = @"点击添加频道";
            view.hiddenEditBtn = YES ;
            view ;
        });
    }
    return _headerView2 ;
}

- (KKSectionGroupView *)favSectionView{
    if(!_favSectionView){
        _favSectionView = [[KKSectionGroupView alloc]initWithFavorite:YES];
        _favSectionView.delegate = self ;
    }
    return _favSectionView;
}

- (KKSectionGroupView *)recommonSectionView{
    if(!_recommonSectionView){
        _recommonSectionView = [[KKSectionGroupView alloc]initWithFavorite:NO];
        _recommonSectionView.delegate = self ;
    }
    return _recommonSectionView;
}

@end
