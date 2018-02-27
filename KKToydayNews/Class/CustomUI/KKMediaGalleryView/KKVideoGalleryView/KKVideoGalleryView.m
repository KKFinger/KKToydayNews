//
//  KKVideoGalleryView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/29.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKVideoGalleryView.h"
#import "KKMediaGralleryNavView.h"
#import "KKMediaAlbumInfo.h"
#import "KKAlbumCell.h"
#import "KKVideoManager.h"
#import "KKBlockAlertView.h"
#import "KKGalleryVideoCell.h"
#import "KKNoDataView.h"
#import "KKGalleryVideoPreview.h"

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";
static NSString *albumCellIdentifier = @"albumCellIdentifier";
static CGFloat space = 1.0 ;

@interface KKVideoGalleryView ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,KKMediaGralleryNavViewDelegate>
@property(nonatomic)KKMediaGralleryNavView *navView;
@property(nonatomic)KKNoDataView *noDataView;
@property(nonatomic)UICollectionView *collectView;
@property(nonatomic)UIView *albumMaskView;
@property(nonatomic)UITableView *albumTableView;
@property(nonatomic)KKBlockAlertView *alertView;
@property(nonatomic,assign)CGFloat cellWH;
@property(nonatomic,assign)CGSize imageSize;
@property(nonatomic,copy)NSString *albumId;
@property(nonatomic)NSMutableArray<KKMediaAlbumInfo *> *albumInfoArray;
@property(nonatomic)NSMutableArray<KKVideoInfo *> *videoInfoArray;
@end

@implementation KKVideoGalleryView

- (instancetype)init{
    self = [super init];
    if(self){
        self.topSpace = 20 ;
        self.navContentOffsetY = 0 ;
        self.navTitleHeight = 44 ;
        self.contentViewCornerRadius = 10 ;
        self.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
        self.enableFreedomDrag = NO ;
        self.albumInfoArray = [NSMutableArray<KKMediaAlbumInfo *> arrayWithCapacity:0];
        self.videoInfoArray = [NSMutableArray<KKVideoInfo *> arrayWithCapacity:0];
        self.albumId = [[KKVideoManager sharedInstance]getCameraRollAlbumId];
        self.imageSize = CGSizeMake(130, 130);
    }
    return self ;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.cellWH = (self.dragContentView.width - 2 * space ) / 3.0;
}

#pragma mark -- 视图的显示和消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self initUI];
    [self loadAlbumInfoWithAlbumId:self.albumId];
    [self loadVideoAlbumList];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(photoLibarayChange) name:KKNotifyVideoLibraryDidChange object:nil];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark -- 初始化UI

- (void)initUI{
    [self.dragContentView addSubview:self.collectView];
    [self.dragContentView addSubview:self.albumMaskView];
    [self.dragContentView addSubview:self.albumTableView];
    [self.dragContentView addSubview:self.noDataView];
    [self.navTitleView addSubview:self.navView];
    
    [self.collectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.right.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
    }];
    [self.navView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.navTitleView);
    }];
    [self.albumMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.right.bottom.mas_equalTo(self.dragContentView);
    }];
    [self.albumTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.albumMaskView);
        make.left.right.mas_equalTo(self.albumMaskView);
        make.height.mas_equalTo(0);
    }];
    [self.noDataView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.right.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
    }];
}

#pragma mark -- 加载视频

- (void)loadAlbumInfoWithAlbumId:(NSString *)albumId{
    self.albumId = albumId;
    [self showActivityViewWithTitle:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        KKPhotoAuthorizationStatus status = [[KKVideoManager sharedInstance]authorizationStatus];
        while (status == KKPhotoAuthorizationStatusNotDetermined) {
            usleep(1.0 * 1000.0);
            status = [[KKVideoManager sharedInstance]authorizationStatus] ;
        }
        if(status == KKPhotoAuthorizationStatusAuthorized){
            if(self.albumId == nil){
                self.albumId = [[KKVideoManager sharedInstance]getCameraRollAlbumId];
            }
            [[KKVideoManager sharedInstance]initAlbumWithAlbumObj:self.albumId block:^(BOOL done, KKMediaAlbumInfo *albumInfo) {
                [[KKVideoManager sharedInstance]getVideoInfoListWithBlock:^(BOOL suc, NSArray<KKVideoInfo *> *infoArray) {
                    [self.videoInfoArray removeAllObjects];
                    if(infoArray.count){
                        [self.videoInfoArray addObjectsFromArray:infoArray];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.navView.albumName = albumInfo.albumName;
                        self.noDataView.hidden = self.videoInfoArray.count;
                        [self.collectView reloadData];
                        [self.albumTableView reloadData];
                        [self hiddenActivity];
                    });
                }];
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                KKBlockAlertView *view = [KKBlockAlertView new];
                [view showWithTitle:@"相册权限" message:@"KK头条没有相册权限" cancelButtonTitle:@"知道了" otherButtonTitles:@"去设置" block:^(NSInteger re_code, NSDictionary *userInfo) {
                    if(re_code == 1){
                        [KKAppTools jumpToSetting];
                    }
                }];
                self.alertView = view ;
                [self.navView setEnableAlbumChange:NO];
                [self.noDataView setHidden:NO];
                [self hiddenActivity];
            });
        }
    });
}

#pragma mark -- 加载视频相册列表

- (void)loadVideoAlbumList{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        KKPhotoAuthorizationStatus status = [[KKVideoManager sharedInstance]authorizationStatus];
        while (status == KKPhotoAuthorizationStatusNotDetermined) {
            usleep(1.0 * 1000.0);
            status = [[KKVideoManager sharedInstance]authorizationStatus] ;
        }
        if(status == KKPhotoAuthorizationStatusAuthorized){
            [[KKVideoManager sharedInstance]getVideoAlbumListWithBlock:^(NSArray<KKMediaAlbumInfo *> *albumList) {
                [self.albumInfoArray removeAllObjects];
                for(KKMediaAlbumInfo *info in albumList){
                    if(info.assetCount){
                        [self.albumInfoArray addObject:info];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.albumTableView reloadData];
                    [self.navView setEnableAlbumChange:self.albumInfoArray.count];
                });
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hiddenActivity];
                [self.navView setEnableAlbumChange:NO];
                [self.noDataView setHidden:NO];
            });
        }
    });
}

#pragma mark -- UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.videoInfoArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KKGalleryVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    KKVideoInfo *videoInfo = [self.videoInfoArray safeObjectAtIndex:indexPath.row];
    [cell refreshCell:videoInfo];
    [[KKVideoManager sharedInstance]getVideoCorverWithIndex:indexPath.row needImageSize:self.imageSize isNeedDegraded:YES block:^(KKVideoInfo *videoInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.corverImage = videoInfo.videoCorver;
        });
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(self.cellWH, self.cellWH);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self showPreviewWithSelIndex:indexPath.row videoArray:self.videoInfoArray];
}

//设置水平间距 (同一行的cell的左右间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return space;
}

//垂直间距 (同一列cell上下间距)
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return space;
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumInfoArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 78 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KKAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:albumCellIdentifier];
    KKMediaAlbumInfo *info = [self.albumInfoArray safeObjectAtIndex:indexPath.row];
    [cell refreshWith:info curtSelAlbumId:self.albumId cellType:KKAlbumCellVideo];
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    KKMediaAlbumInfo *info = [self.albumInfoArray safeObjectAtIndex:indexPath.row];
    [self loadAlbumInfoWithAlbumId:info.albumId];
    [self.navView setIsShowAlbumList:NO];
}

#pragma mark -- KKMediaGralleryNavViewDelegate

- (void)showOrHideAlbumList:(BOOL)isShow{
    self.enableHorizonDrag = !isShow;
    self.enableVerticalDrag = !isShow;
    [self.albumTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(isShow ? self.dragContentView.height - 150: 0);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.albumMaskView.alpha = isShow ;
        [self.dragContentView layoutIfNeeded];
    }];
}

- (void)closeGralleryView{
    if(self.selectVideoCallback){
        self.selectVideoCallback(nil);
    }
    [self startHide];
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
    
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.collectView.scrollEnabled = NO ;
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    self.collectView.scrollEnabled = YES ;
    if(hideView){
        if(self.selectVideoCallback){
            self.selectVideoCallback(nil);
        }
    }
}

#pragma mark -- 相片库发生变化

- (void)photoLibarayChange{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadAlbumInfoWithAlbumId:self.albumId];
        [self loadVideoAlbumList];
    });
}

#pragma mark -- 显示预览视图

- (void)showPreviewWithSelIndex:(NSInteger)index videoArray:(NSArray *)array{
    KKGalleryVideoCell *cell = (KKGalleryVideoCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    CGRect frame = [cell.contentBgView convertRect:cell.contentBgView.frame toView:self.collectView];
    
    KKGalleryVideoPreview *browser = [[KKGalleryVideoPreview alloc]initWithVideoArray:array selIndex:index albumId:self.albumId];
    browser.topSpace = 0 ;
    browser.frame = CGRectMake(0, 0, UIDeviceScreenWidth, UIDeviceScreenHeight);
    browser.defaultHideAnimateWhenDragFreedom = NO ;
    browser.oriView = self.collectView;
    browser.oriFrame = frame;
    
    @weakify(browser);
    [browser setHideVideoAnimate:^(UIImage *image,CGRect fromFrame,CGRect toFrame) {
        @strongify(browser);
        UIImageView *imageView = [YYAnimatedImageView new];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = fromFrame ;
        imageView.layer.masksToBounds = YES ;
        [self.collectView addSubview:imageView];
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = toFrame;
        }completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            [browser removeFromSuperview];
            for(KKGalleryVideoCell *cell in self.collectView.visibleCells){
                cell.contentBgView.alpha = 1.0 ;
            }
        }];
    }];
    
    [browser setAlphaViewIfNeed:^(BOOL shouldAlphaView,NSInteger curtSelIndex){
        for(KKGalleryVideoCell *cell in self.collectView.visibleCells){
            cell.contentBgView.alpha = 1.0 ;
        }
        KKGalleryVideoCell *cell = (KKGalleryVideoCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:curtSelIndex inSection:0]];
        cell.contentBgView.alpha = !shouldAlphaView ;
    }];
    
    [browser setVideoIndexChange:^(NSInteger imageIndex,void(^updeteOriFrame)(CGRect oriFrame)){
        [self.collectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:imageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        KKGalleryVideoCell *cell = (KKGalleryVideoCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:imageIndex inSection:0]];
        CGRect frame = [cell.contentBgView convertRect:cell.contentBgView.frame toView:self.collectView];
        if(updeteOriFrame){
            updeteOriFrame(frame);
        }
    }];
    
    [browser setSelectVideo:^(KKVideoInfo *item){
        if(self.selectVideoCallback){
            self.selectVideoCallback(item);
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:browser];
    [browser viewWillAppear];
}

#pragma mark -- @property

- (UICollectionView *)collectView{
    if(!_collectView){
        _collectView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            UICollectionView *view = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
            view.delegate= self;
            view.dataSource= self;
            view.backgroundColor = [UIColor whiteColor];
            [view registerClass:[KKGalleryVideoCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
            view;
        });
    }
    return _collectView;
}

- (KKMediaGralleryNavView *)navView{
    if(!_navView){
        _navView = ({
            KKMediaGralleryNavView *view= [KKMediaGralleryNavView new];
            view.delegate = self ;
            view.showSelCount = NO ;
            view.showDoneBtn = NO ;
            view ;
        });
    }
    return _navView;
}

- (UIView *)albumMaskView{
    if(!_albumMaskView){
        _albumMaskView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
            view.userInteractionEnabled = YES ;
            view.layer.masksToBounds = YES ;
            view.alpha = 0 ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                self.navView.isShowAlbumList = NO ;
            }];
            
            view ;
        });
    }
    return _albumMaskView;
}

- (UITableView *)albumTableView{
    if(!_albumTableView){
        _albumTableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            view.dataSource = self ;
            view.delegate = self ;
            view.backgroundColor = KKColor(244, 245, 246, 1.0);
            view.separatorStyle = UITableViewCellSeparatorStyleNone ;
            view.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, -1)];
            [view registerClass:[KKAlbumCell class] forCellReuseIdentifier:albumCellIdentifier];
            
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
    return _albumTableView;
}

- (KKNoDataView *)noDataView{
    if(!_noDataView){
        _noDataView = ({
            KKNoDataView *view = [KKNoDataView new];
            view.tipImage = [UIImage imageNamed:@"not_found_loading_226x119_"];
            view.tipText = @"在这个星球找不到你需要的信息";
            view.hidden = YES ;
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _noDataView;
}

@end
