//
//  KKImageNewsDetail.m
//  KKToydayNews
//
//  Created by finger on 2017/9/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKImageNewsDetail.h"
#import "KKLoadingView.h"
#import "KKAuthorInfoView.h"
#import "KKBottomBar.h"
#import "KKPersonalCommentView.h"
#import "KKImageDescView.h"
#import "KKNewsAnalyzeTool.h"
#import "KKNewsCommentView.h"
#import "KKGalleryPreviewCell.h"
#import "KKPersonalInfoView.h"

#define BottomBarHeight (KKSafeAreaBottomHeight + 44)
#define ImageHorizPading 20 //每张图片之间的间距
#define ImageItemWith (UIDeviceScreenWidth + ImageHorizPading)

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";

@interface KKImageNewsDetail()<UIScrollViewDelegate,KKAuthorInfoViewDelegate,KKBottomBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,KKImageZoomViewDelegate>
@property(nonatomic)KKAuthorInfoView *navAuthorView;
@property(nonatomic)KKBottomBar *bottomBar;
@property(nonatomic)UICollectionView *collectView;
@property(nonatomic)KKImageDescView *descView;

@property(nonatomic,assign) UIStatusBarStyle barStyle;
@property(nonatomic,assign)NSInteger selIndex;

@property(nonatomic)KKNewsBaseInfo *newsInfo;

@property(nonatomic,assign)BOOL showView;

@end

@implementation KKImageNewsDetail

- (instancetype)initWithNewsBaseInfo:(KKNewsBaseInfo *)newsInfo{
    self = [super init];
    if(self){
        self.topSpace = 0 ;
        self.selIndex = 0 ;
        self.showView = YES;
        self.enableFreedomDrag = NO ;
        self.enableHorizonDrag = YES ;
        self.enableVerticalDrag = YES ;
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
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
    if(self.alphaViewIfNeed){
        self.alphaViewIfNeed(NO);
    }
}

#pragma mark -- 初始化UI

- (void)initUI{
    [self.dragContentView setBackgroundColor:[UIColor blackColor]];
    [self.dragContentView insertSubview:self.collectView belowSubview:self.navTitleView];
    [self.dragContentView insertSubview:self.bottomBar aboveSubview:self.collectView];
    [self.dragContentView insertSubview:self.descView belowSubview:self.bottomBar];
    
    [self initNavBar];
    
    [self.collectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.height.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(ImageItemWith);
    }];
    
    [self.bottomBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(self.dragContentView).priority(998);
        make.height.mas_equalTo(BottomBarHeight);
    }];
    
    [self.descView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomBar.mas_top);
        make.left.right.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(0);
    }];
    
    [self layoutIfNeeded];
}

#pragma mark -- 导航栏

- (void)initNavBar{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    [backButton setImage:[UIImage imageNamed:@"leftbackicon_white_titlebar_24x24_"] forState:UIControlStateNormal];
    [backButton setImage:[[UIImage imageNamed:@"leftbackicon_white_titlebar_24x24_"] imageWithAlpha:0.5] forState:UIControlStateHighlighted];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(dismissImageView) forControlEvents:UIControlEventTouchUpInside];
    self.navTitleView.leftBtns = @[backButton];
    self.navTitleView.splitView.hidden = YES ;
    self.navTitleView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    
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
    NSString *articleUrl = self.newsInfo.articalUrl;
    NSString *headUrl = self.newsInfo.userInfo.avatar_url;
    NSString *name = self.newsInfo.userInfo.name;
    
    self.navAuthorView.name = name;
    self.navAuthorView.headUrl = headUrl;
    self.navAuthorView.isConcern = NO ;
    self.navAuthorView.userId = self.newsInfo.userInfo.user_id;
    
    self.bottomBar.commentCount = [self.newsInfo.commentCount integerValue];
    
    [KKNewsAnalyzeTool fetchImageItemWithUrl:articleUrl complete:^(NSArray<KKImageItem *> *imageArray) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageArray = imageArray;
        });
    }];
}

#pragma mark -- 初始化图片视图

- (void)setImageArray:(NSArray *)imageArray{
    _imageArray = imageArray;
    NSInteger index = 0 ;
    NSInteger count = self.imageArray.count;
    for(KKImageItem *item in self.imageArray){
        if(!item.textContainer){
            TYTextContainer *temp = [TYTextContainer new];
            temp.font = (iPhone5)?[UIFont systemFontOfSize:15]:[UIFont systemFontOfSize:16];
            temp.linesSpacing = 2 ;
            temp.textColor = [UIColor whiteColor];
            temp.text = [NSString stringWithFormat:@"%ld/%ld %@",index+1,count,item.desc];
            temp.textAlignment = NSTextAlignmentLeft;
            
            TYTextStorage *textStorage = [[TYTextStorage alloc]init];
            textStorage.range = [temp.text rangeOfString:[NSString stringWithFormat:@"/%ld",count]];
            textStorage.font = [UIFont systemFontOfSize:13];
            [temp addTextStorage:textStorage];
            
            item.textContainer = [temp createTextContainerWithTextWidth:[KKImageDescView descTextWidth]];
        }
        index ++;
    }
    
    TYTextContainer *data = ((KKImageItem *)(self.imageArray.firstObject)).textContainer;
    [self.descView refreshViewAttriData:data];
    
    [self.collectView reloadData];
}

#pragma mark -- UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KKGalleryPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    cell.conetntImageView.zoomViewDelegate = self;
    cell.conetntImageView.layer.masksToBounds = NO ;
    KKImageItem *item = [self.imageArray safeObjectAtIndex:indexPath.row];
    NSString *url = item.url;
    if(!url.length){
        url = @"";
    }
    cell.imageUrl = url;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(ImageItemWith, self.collectView.height);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}

//设置水平间距 (同一行的cell的左右间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//垂直间距 (同一列cell上下间距)
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark -- KKImageZoomViewDelegate

- (void)tapImageZoomView{
    [self showOrHideView];
}

- (void)imageViewDidZoom:(KKImageZoomView *)zoomView{
    
    self.dragContentView.backgroundColor = [UIColor blackColor];
    
    CGFloat zoomScale = zoomView.zoomScale;
    if(zoomScale != zoomView.minimumZoomScale){
        self.enableHorizonDrag = NO ;
        self.enableVerticalDrag = NO ;
    }else{
        self.enableHorizonDrag = (self.selIndex == 0);
        self.enableVerticalDrag = YES ;
    }
    self.enableFreedomDrag = NO ;
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.enableHorizonDrag = NO ;
    self.enableVerticalDrag = NO ;
    self.enableFreedomDrag = NO ;
    
    CGPoint offset = self.collectView.contentOffset;
    CGFloat progress = offset.x / (CGFloat)ImageItemWith;
    
    //设置上下、当前三张图片的透明度
    NSInteger nextIndex = self.selIndex + 1 ;
    if(nextIndex < self.imageArray.count){
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
        [cell setAlpha:fabs(progress-self.selIndex)];
    }
    
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    [cell setAlpha:1 - fabs((progress-self.selIndex))];
    
    NSInteger perIndex = self.selIndex - 1 ;
    if(perIndex >= 0){
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:perIndex inSection:0]];
        [cell setAlpha:fabs((self.selIndex - progress))];
    }
}

//结束拉拽视图
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGPoint offset = self.collectView.contentOffset;
    NSInteger index = offset.x / ImageItemWith;
    if(index < 0 || index >= self.imageArray.count){
        return ;
    }
    KKImageItem *item = [self.imageArray safeObjectAtIndex:index];
    [self.descView refreshViewAttriData:item.textContainer];
}

//完全停止滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = self.collectView.contentOffset;
    NSInteger index = offset.x / ImageItemWith;
    if(index < 0 || index >= self.imageArray.count){
        return ;
    }
    
    self.selIndex = index ;
    
    CGFloat zoomScale = scrollView.zoomScale;
    if(zoomScale == scrollView.minimumZoomScale){
        self.enableHorizonDrag = (index == 0);
        self.enableVerticalDrag = YES ;
    }
    self.enableFreedomDrag = NO ;
    
    KKImageItem *item = [self.imageArray safeObjectAtIndex:index];
    
    [self.descView refreshViewAttriData:item.textContainer];
    
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    [cell setAlpha:1.0];
    
    NSInteger nextIndex = self.selIndex + 1 ;
    if(nextIndex < self.imageArray.count){
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
        [cell setAlpha:1.0];
    }
    
    NSInteger perIndex = self.selIndex - 1 ;
    if(perIndex >= 0){
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:perIndex inSection:0]];
        [cell setAlpha:1.0];
    }
}

#pragma mark -- KKAuthorInfoViewDelegate

- (void)setConcern:(BOOL)isConcern callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)clickedUserHeadWithUserId:(NSString *)userId{
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

#pragma mark -- KKBottomBarDelegate

- (void)sendCommentWidthText:(NSString *)text{
    NSLog(@"%@",text);
}

- (void)favoriteNews:(BOOL)isFavorite callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)shareNews{
    
}

- (void)showCommentView{
    KKNewsCommentView *view = [[KKNewsCommentView alloc]initWithNewsBaseInfo:self.newsInfo];
    view.topSpace = KKStatusBarHeight ;
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

#pragma mark -- 退出界面

- (void)dismissImageView{
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    UIImageView *imageView = cell.conetntImageView.imageView;
    imageView.hidden = YES ;
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
    
    CGRect frame = [self.dragContentView convertRect:imageView.frame toView:self.oriView];
    self.dragViewBg.alpha = 0;
    self.dragContentView.hidden = YES ;;
    if(self.hideImageAnimate){
        self.hideImageAnimate(self.oriImage,frame,self.oriFrame);
    }
}

#pragma mark --

- (void)showOrHideView{
    self.showView = !self.showView;
    [UIView animateWithDuration:0.3 animations:^{
        self.navTitleView.alpha = self.showView;
        self.bottomBar.alpha = self.showView;
        self.descView.alpha = self.showView;
    }];
    [[UIApplication sharedApplication]setStatusBarHidden:!self.showView withAnimation:UIStatusBarAnimationFade];
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
    self.enableFreedomDrag = NO ;
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    KKImageZoomView *view = cell.conetntImageView;
    UIImageView *imageView = view.imageView;
    if(view.zoomScale != view.minimumZoomScale){
        return ;
    }
    
    self.enableVerticalDrag = (view.contentSize.height <= cell.height);
    self.enableHorizonDrag = (view.contentSize.height <= cell.height);
    
    //只有选中图片且不在缩放的情况下才允许自由拖拽
    CGPoint targetPt = [self.dragContentView convertPoint:pt toView:view];
    if(CGRectContainsPoint(imageView.frame, targetPt) && (view.contentSize.height <= cell.height)){
        self.enableFreedomDrag = YES ;
        view.bounces = NO ;
        view.scrollEnabled = NO ;
    }
    
    if(self.alphaViewIfNeed){
        self.alphaViewIfNeed(self.enableFreedomDrag&&!self.defaultHideAnimateWhenDragFreedom);
    }
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.collectView.scrollEnabled = NO ;
    self.collectView.bounces = NO ;
    if(self.enableFreedomDrag){
        self.navTitleView.alpha = 0;
        self.bottomBar.alpha = 0;
        self.descView.alpha = 0;
        self.dragContentView.backgroundColor = [UIColor clearColor];
        
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
        
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
        KKImageZoomView *view = cell.conetntImageView;
        UIImageView *imageView = view.imageView;
        
        view.zoomScale = 1.0;
        imageView.layer.transform = CATransform3DMakeScale(self.dragViewBg.alpha,self.dragViewBg.alpha,0);
    }
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    KKImageZoomView *view = cell.conetntImageView;
    UIImageView *imageView = view.imageView;
    
    view.bounces = YES ;
    view.scrollEnabled = YES ;
    
    self.collectView.bounces = YES ;
    self.collectView.scrollEnabled = YES ;
    
    if(view.zoomScale != view.minimumZoomScale){
        return ;
    }
    
    if(self.enableFreedomDrag){
        if(!hideView){
            [self.dragContentView setBackgroundColor:[UIColor blackColor]];
            [[UIApplication sharedApplication]setStatusBarHidden:!self.showView withAnimation:NO];
            [UIView animateWithDuration:0.3 animations:^{
                imageView.layer.transform = CATransform3DIdentity;
                self.navTitleView.alpha = self.showView;
                self.bottomBar.alpha = self.showView;
                self.descView.alpha = self.showView;
                self.dragContentView.alpha = 1.0 ;
            }completion:^(BOOL finished) {
            }];
        }else{
            [self dismissImageView];
        }
    }else{
        if(!hideView){
            [self.dragContentView setBackgroundColor:[UIColor blackColor]];
            [[UIApplication sharedApplication]setStatusBarHidden:!self.showView withAnimation:NO];
        }
        if(self.alphaViewIfNeed){
            self.alphaViewIfNeed(!hideView);
        }
    }
    
    self.enableFreedomDrag = NO ;
    self.enableHorizonDrag = (self.selIndex == 0) ;
    self.enableVerticalDrag = YES ;
}

#pragma mark -- @property

- (UICollectionView *)collectView{
    if(!_collectView){
        _collectView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            layout.scrollDirection =  UICollectionViewScrollDirectionHorizontal;
            UICollectionView *view = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
            view.delegate= self;
            view.dataSource= self;
            view.showsHorizontalScrollIndicator = NO ;
            view.showsVerticalScrollIndicator = NO ;
            view.pagingEnabled = YES ;
            view.layer.masksToBounds = NO ;
            view.tag = KKViewTagImageDetailView;
            view.backgroundColor = [UIColor clearColor];
            [view registerClass:[KKGalleryPreviewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
            view;
        });
    }
    return _collectView;
}

- (KKAuthorInfoView *)navAuthorView{
    if(!_navAuthorView){
        _navAuthorView = ({
            KKAuthorInfoView *view = [KKAuthorInfoView new];
            view.delegate = self ;
            view.detailLabel.textColor = [UIColor whiteColor];
            view.nameLabel.textColor = [UIColor whiteColor];
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
            view.splitView.hidden = YES ;
            view.textView.backgroundColor = [[UIColor whiteColor]colorWithAlphaComponent:0.1];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
            view ;
        });
    }
    return _bottomBar;
}

- (KKImageDescView *)descView{
    if(!_descView){
        _descView = ({
            KKImageDescView *view = [KKImageDescView new];
            view.tag = KKViewTagImageDetailDescView;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _descView;
}

@end
