//
//  KKImageGalleryView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/22.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKImageGalleryView.h"
#import "KKPhotoManager.h"
#import "KKGalleryImageCell.h"
#import "KKBlockAlertView.h"
#import "KKAlbumCell.h"
#import "KKGalleryBarView.h"
#import "KKGalleryImagePreview.h"
#import "KKNoDataView.h"

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";
static NSString *albumCellIdentifier = @"albumCellIdentifier";
static CGFloat space = 1.0 ;

@interface KKImageGalleryView()<KKGalleryImageCellDelegate,UICollectionViewDelegate,UICollectionViewDataSource,KKMediaGralleryNavViewDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,KKGalleryBarViewDelegate>
@property(nonatomic)UICollectionView *collectView;
@property(nonatomic)UIView *albumMaskView;
@property(nonatomic)UITableView *albumTableView;
@property(nonatomic)KKGalleryBarView *barView;
@property(nonatomic)KKNoDataView *noDataView;
@property(nonatomic)KKBlockAlertView *alertView;
@property(nonatomic,weak)UIImagePickerController *pickerController;
@property(nonatomic,assign)CGSize cellSize;
@property(nonatomic)KKMediaAlbumInfo *albumInfo;
@property(nonatomic,copy)NSString *albumId;
@property(nonatomic)KKPhotoInfo *placeholderItem;
@property(nonatomic)NSMutableArray *albumInfoArray;
@property(nonatomic,assign)BOOL disableSelected;
@property(nonatomic,assign)BOOL isFirstEnter;
@end

@implementation KKImageGalleryView

- (instancetype)init{
    self = [super init];
    if(self){
        self.topSpace = 20 ;
        self.navContentOffsetY = 0 ;
        self.navTitleHeight = 44 ;
        self.contentViewCornerRadius = 10 ;
        self.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
        self.enableFreedomDrag = NO ;
        self.albumInfoArray = [NSMutableArray arrayWithCapacity:0];
        self.limitSelCount = -1 ;
        self.curtSelCount = 0 ;
        self.albumId = [[KKPhotoManager sharedInstance]getCameraRollAlbumId];
        
        self.placeholderItem = [KKPhotoInfo new];
        self.placeholderItem.image = [UIImage imageNamed:@"introduct_add_picture"];
        self.placeholderItem.isPlaceholderImage = YES ;
        
        self.isFirstEnter = YES ;
    }
    return self ;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellWH = (self.dragContentView.width - 3 * space ) / 4.0;
    self.cellSize = CGSizeMake(cellWH, cellWH);
}

- (void)dealloc{
    NSLog(@"");
}

#pragma mark -- 视图的显示和消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self initUI];
    [self loadAlbumInfoWithAlbumId:self.albumId];
    [self loadImageAlbumList];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(photoLibarayChange) name:KKNotifyPhotoLibraryDidChange object:nil];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark -- 初始化UI

- (void)initUI{
    [self.dragContentView addSubview:self.collectView];
    [self.dragContentView addSubview:self.barView];
    [self.dragContentView addSubview:self.albumMaskView];
    [self.dragContentView addSubview:self.albumTableView];
    [self.dragContentView addSubview:self.noDataView];
    [self.navTitleView addSubview:self.navView];
    
    [self.collectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.right.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.barView.mas_top);
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
    [self.barView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.dragContentView);
        make.left.right.mas_equalTo(self.dragContentView);
        make.height.mas_equalTo(44);
    }];
    
    [self.noDataView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navTitleView.mas_bottom);
        make.left.right.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
    }];
    
    self.barView.enablePreview = self.curtSelCount;
    self.disableSelected = ( self.limitSelCount == self.curtSelCount ) ;
}

#pragma mark -- 加载相册信息

- (void)loadAlbumInfoWithAlbumId:(NSString *)albumId{
    self.albumId = albumId;
    [self showActivityViewWithTitle:nil];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        KKPhotoAuthorizationStatus status = [[KKPhotoManager sharedInstance]authorizationStatus];
        while (status == KKPhotoAuthorizationStatusNotDetermined) {
            usleep(1.0 * 1000.0);
            status = [[KKPhotoManager sharedInstance]authorizationStatus] ;
        }
        if(status == KKPhotoAuthorizationStatusAuthorized){
            if(self.albumId == nil){
                self.albumId = [[KKPhotoManager sharedInstance]getCameraRollAlbumId];
            }
            [[KKPhotoManager sharedInstance]initAlbumWithAlbumObj:self.albumId block:^(BOOL done, KKMediaAlbumInfo *albumInfo) {
                self.albumInfo = albumInfo;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navView setAlbumName:self.albumInfo.albumName];
                    [self.noDataView setHidden:self.albumInfo.assetCount];
                    [self.collectView reloadData];
                    [self.albumTableView reloadData];
                    [self hiddenActivity];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if(self.isFirstEnter){
                            self.isFirstEnter = NO ;
                            [self scrollViewDidEndDecelerating:self.collectView];
                        }
                    });
                });
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hiddenActivity];
                KKBlockAlertView *view = [KKBlockAlertView new];
                [view showWithTitle:@"相册权限" message:@"KK头条没有相册权限" cancelButtonTitle:@"知道了" otherButtonTitles:@"去设置" block:^(NSInteger re_code, NSDictionary *userInfo) {
                    if(re_code == 1){
                        [KKAppTools jumpToSetting];
                    }
                }];
                self.alertView = view ;
                [self.navView setEnableAlbumChange:NO];
                [self.noDataView setHidden:NO];
            });
        }
    });
}

#pragma mark -- 加载相册列表

- (void)loadImageAlbumList{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        KKPhotoAuthorizationStatus status = [[KKPhotoManager sharedInstance]authorizationStatus];
        while (status == KKPhotoAuthorizationStatusNotDetermined) {
            usleep(1.0 * 1000.0);
            status = [[KKPhotoManager sharedInstance]authorizationStatus] ;
        }
        if(status == KKPhotoAuthorizationStatusAuthorized){
            [[KKPhotoManager sharedInstance]getImageAlbumList:^(NSArray<KKMediaAlbumInfo *> *array) {
                [self.albumInfoArray removeAllObjects];
                for(KKMediaAlbumInfo *info in array){
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
    return self.albumInfo.assetCount + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KKGalleryImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    [cell setDelegate:self];
    [cell.contentBgView setAlpha:1.0];
    if(indexPath.row == 0){
        [cell refreshCell:self.placeholderItem cellType:KKGalleryCellTypeSelect disable:self.disableSelected];
    }else{
        //先加载低分辨的图片，提高加载速度，当视图完全停止滚动的时候，再加载高分辨率的缩略图
        [[KKPhotoManager sharedInstance]getThumbnailImageWithIndex:indexPath.row - 1 needImageSize:CGSizeMake(30, 30) isNeedDegraded:NO block:^(KKPhotoInfo *item) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL disable = (self.disableSelected && (!item.isSelected));
                [cell refreshCell:item cellType:KKGalleryCellTypeSelect disable:disable];
            });
        }];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.cellSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        [self showImagePickerView];
    }else{
        [[KKPhotoManager sharedInstance]getAlbumImageIdentifierWithAlbumId:self.albumId
                                                                      sort:NSOrderedDescending
                                                                     block:^(NSArray *array)
         {
             [self showPreviewWithSelIndex:indexPath.row-1 useDefaultAimate:NO imageArray:array];
         }];
    }
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
    [cell refreshWith:info curtSelAlbumId:self.albumId cellType:KKAlbumCellImage];
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    KKMediaAlbumInfo *info = [self.albumInfoArray safeObjectAtIndex:indexPath.row];
    [self loadAlbumInfoWithAlbumId:info.albumId];
    [self.navView setIsShowAlbumList:NO];
}

#pragma mark -- KKGalleryImageCellDelegate

- (void)selectImage:(KKGalleryImageCell *)cell photoItem:(KKPhotoInfo *)item{
    if(self.limitSelCount != -1){
        if(!item.isSelected){
            BOOL falg = ((self.curtSelCount + 1) == self.limitSelCount);
            if(self.disableSelected != falg){
                self.disableSelected = falg;
                [UIView performWithoutAnimation:^{
                    [self.collectView reloadData];
                }];
            }
        }else{
            BOOL falg = (self.curtSelCount == self.limitSelCount);
            if(self.disableSelected != falg){
                self.disableSelected = falg;
                [UIView performWithoutAnimation:^{
                    [self.collectView reloadData];
                }];
            }
        }
    }
    if(self.selectImageCallback){
        @weakify(self);
        self.selectImageCallback(item, !item.isSelected, ^(BOOL canSelect,NSInteger selCount) {
            @strongify(self);
            self.curtSelCount = selCount;
            if(self.limitSelCount != -1){
                BOOL falg = (self.curtSelCount == self.limitSelCount);
                if(self.disableSelected != falg){
                    self.disableSelected = falg;
                    [UIView performWithoutAnimation:^{
                        [self.collectView reloadData];
                    }];
                }
            }
            if(canSelect){
                self.navView.selCount = [NSString stringWithFormat:@"%ld",selCount];
                self.barView.enablePreview = selCount;
                item.isSelected = !item.isSelected;
                
                BOOL disable = (self.disableSelected && (!item.isSelected));
                [cell refreshCell:item cellType:KKGalleryCellTypeSelect disable:disable];
                [cell selectAnimate];
            }
        });
    }
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

- (void)selectComplete{
    [self startHide];
    if(self.showShareCtrlWhenDismiss){
        self.showShareCtrlWhenDismiss();
    }
}

- (void)closeGralleryView{
    [self startHide];
}

#pragma mark -- KKGalleryBarViewDelegate

- (void)previewImage{
    NSMutableArray *array = [NSMutableArray new];
    if(self.getCurtSelArray){
        NSArray *curtSelArray = self.getCurtSelArray();
        for(KKPhotoInfo *item in curtSelArray){
            if(item.identifier.length){
                [array addObject:item.identifier];
            }
        }
        [self showPreviewWithSelIndex:0 useDefaultAimate:YES imageArray:array];
    }
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
    
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.collectView.scrollEnabled = NO ;
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    self.collectView.scrollEnabled = YES ;
}

#pragma mark -- UIScrollViewDelegate

//完全停止滚动，加载高分辨率的缩略图
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [[KKPhotoManager sharedInstance]cancelAllThumbnailTask];
    
    NSArray *array = self.collectView.indexPathsForVisibleItems;
    for(NSIndexPath *indexPath in array){
        KKGalleryImageCell *cell = (KKGalleryImageCell *)[self.collectView cellForItemAtIndexPath:indexPath];
        [cell setDelegate:self];
        [cell.contentBgView setAlpha:1.0];
        if(indexPath.row == 0){
            [cell refreshCell:self.placeholderItem cellType:KKGalleryCellTypeSelect disable:self.disableSelected];
        }else{
            [[KKPhotoManager sharedInstance]getThumbnailImageWithIndex:indexPath.row - 1 needImageSize:self.cellSize isNeedDegraded:YES block:^(KKPhotoInfo *item) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL disable = (self.disableSelected && (!item.isSelected));
                    [cell refreshCell:item cellType:KKGalleryCellTypeSelect disable:disable];
                });
            }];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {//手指离开时不会继续滚动
        
        [[KKPhotoManager sharedInstance]cancelAllThumbnailTask];
        
        NSArray *array = self.collectView.indexPathsForVisibleItems;
        for(NSIndexPath *indexPath in array){
            KKGalleryImageCell *cell = (KKGalleryImageCell *)[self.collectView cellForItemAtIndexPath:indexPath];
            [cell setDelegate:self];
            [cell.contentBgView setAlpha:1.0];
            if(indexPath.row == 0){
                [cell refreshCell:self.placeholderItem cellType:KKGalleryCellTypeSelect disable:self.disableSelected];
            }else{
                [[KKPhotoManager sharedInstance]getThumbnailImageWithIndex:indexPath.row - 1 needImageSize:self.cellSize isNeedDegraded:YES block:^(KKPhotoInfo *item) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BOOL disable = (self.disableSelected && (!item.isSelected));
                        [cell refreshCell:item cellType:KKGalleryCellTypeSelect disable:disable];
                    });
                }];
            }
        }
    }
}

#pragma mark -- 相片库发生变化

- (void)photoLibarayChange{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self loadAlbumInfoWithAlbumId:self.albumId];
        [self loadImageAlbumList];
    });
}

#pragma mark -- 拍照视图

- (void)showImagePickerView{
    [UIView animateWithDuration:0.2 animations:^{
        self.dragViewBg.alpha = 0.0 ;
        self.dragContentView.top = UIDeviceScreenHeight;
    } completion:^(BOOL finished) {
        self.hidden = YES ;
    }];
    
    UIViewController *topRootViewController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
    while (topRootViewController.presentedViewController){
        topRootViewController = topRootViewController.presentedViewController;
    }
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.pickerController = pickerController;
    
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 8.0) {
        topRootViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    [topRootViewController presentViewController:pickerController animated:YES completion:^{
    }];
}

#pragma mark -- UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage] ;
    KKPhotoInfo *item = [KKPhotoInfo new];
    item.image = image;
    if(self.selectImageCallback){
        self.selectImageCallback(item, !item.isSelected, ^(BOOL canSelect,NSInteger selCount) {
        });
    }
    
    [self startHide];
    
    [self.pickerController dismissViewControllerAnimated:YES completion:nil];
    
    if(self.showShareCtrlWhenDismiss){
        self.showShareCtrlWhenDismiss();
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.pickerController dismissViewControllerAnimated:YES completion:^{
    }];
    
    self.hidden = NO ;
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.85
          initialSpringVelocity:5.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.dragViewBg.alpha = 1.0 ;
                         self.dragContentView.top = self.topSpace;
                     }completion:^(BOOL finished) {
                         [self viewDidAppear];
                     }];
}

#pragma mark -- 显示预览视图

- (void)showPreviewWithSelIndex:(NSInteger)index useDefaultAimate:(BOOL)useDefaultAimate imageArray:(NSArray *)array{
    KKGalleryImageCell *cell = (KKGalleryImageCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index + 1 inSection:0]];
    CGRect frame = [cell.contentBgView convertRect:cell.contentBgView.frame toView:self.collectView];
    
    KKGalleryImagePreview *browser = [[KKGalleryImagePreview alloc]initWithImageArray:array selIndex:index albumId:self.albumId selCount:[self.navView.selCount integerValue]];
    browser.topSpace = 0 ;
    browser.frame = CGRectMake(0, 0, UIDeviceScreenWidth, UIDeviceScreenHeight);
    browser.defaultHideAnimateWhenDragFreedom = useDefaultAimate ;
    browser.oriView = self.collectView;
    browser.oriFrame = frame;
    browser.zoomAnimateWhenShowAndHide = !useDefaultAimate;
    
    @weakify(browser);
    [browser setHideImageAnimate:^(UIImage *image,CGRect fromFrame,CGRect toFrame) {
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
            for(KKGalleryImageCell *cell in self.collectView.visibleCells){
                cell.contentBgView.alpha = 1.0 ;
            }
        }];
    }];
    
    [browser setAlphaViewIfNeed:^(BOOL shouldAlphaView,NSInteger curtSelIndex){
        for(KKGalleryImageCell *cell in self.collectView.visibleCells){
            cell.contentBgView.alpha = 1.0 ;
        }
        KKGalleryImageCell *cell = (KKGalleryImageCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:curtSelIndex + 1 inSection:0]];
        cell.contentBgView.alpha = !shouldAlphaView ;
    }];
    
    [browser setImageIndexChange:^(NSInteger imageIndex,void(^updeteOriFrame)(CGRect oriFrame)){
        [self.collectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:imageIndex+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
        KKGalleryImageCell *cell = (KKGalleryImageCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:imageIndex + 1 inSection:0]];
        CGRect frame = [cell.contentBgView convertRect:cell.contentBgView.frame toView:self.collectView];
        if(updeteOriFrame){
            updeteOriFrame(frame);
        }
    }];
    
    [browser setSelectImage:^(KKPhotoInfo *item,BOOL isSelect,NSInteger selIndex,void(^selectCallback)(BOOL canSelect,NSInteger selCount)){
        if(self.selectImageCallback){
            @weakify(self);
            self.selectImageCallback(item, !item.isSelected, ^(BOOL canSelect,NSInteger selCount) {
                @strongify(self);
                self.curtSelCount = selCount;
                if(self.limitSelCount != -1){
                    BOOL falg = (self.curtSelCount == self.limitSelCount);
                    if(self.disableSelected != falg){
                        self.disableSelected = falg;
                        [UIView performWithoutAnimation:^{
                            [self.collectView reloadData];
                        }];
                    }
                }
                if(canSelect){
                    self.navView.selCount = [NSString stringWithFormat:@"%ld",selCount];
                    item.isSelected = !item.isSelected;
                    
                    KKGalleryImageCell *cell = (KKGalleryImageCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:selIndex + 1 inSection:0]];
                    
                    BOOL disable = (self.disableSelected && (!item.isSelected));
                    [cell refreshCell:item cellType:KKGalleryCellTypeSelect disable:disable];
                    [cell selectAnimate];
                    
                    if(selectCallback){
                        selectCallback(canSelect,selCount);
                    }
                }
            });
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:browser];
    if(useDefaultAimate){
        [browser startShow];
    }else{
        [browser viewWillAppear];
    }
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
            [view registerClass:[KKGalleryImageCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
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

- (KKGalleryBarView *)barView{
    if(!_barView){
        _barView = ({
            KKGalleryBarView *view = [KKGalleryBarView new];
            view.delegate = self;
            view.borderType = KKBorderTypeTop;
            view.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.3];
            view.borderThickness = 0.3;
            view ;
        });
    }
    return _barView;
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
